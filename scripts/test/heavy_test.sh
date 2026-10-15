#!/usr/bin/env bash
# Self-tests for heavy.sh. Run: bash scripts/test/heavy_test.sh
set -u
here="$(cd "$(dirname "$0")" && pwd)"
heavy="$here/../heavy.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
export HEAVY_LOCK_DIR="$tmp/locks" HEAVY_LOCK_POLL_SECONDS=1
lock="$HEAVY_LOCK_DIR/heavy"
failures=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi; }
plant_lock() { mkdir -p "$lock"; echo "$1" > "$lock/heartbeat"; echo "$2" > "$lock/owner"; }
pairs_ok() {
  [ "$(wc -l < "$1" | tr -d ' ')" = 4 ] &&
  [ "$(sed -n 1p "$1" | cut -d- -f1)" = "$(sed -n 2p "$1" | cut -d- -f1)" ] &&
  [ "$(sed -n 3p "$1" | cut -d- -f1)" = "$(sed -n 4p "$1" | cut -d- -f1)" ]
}

# 1. Exit codes pass through.
bash "$heavy" bash -c 'exit 0'; code=$?
check "exit code 0 passes through" '[ "$code" -eq 0 ]'
bash "$heavy" bash -c 'exit 3'; code=$?
check "exit code 3 passes through" '[ "$code" -eq 3 ]'

# 2. The lock is released after success and after failure.
check "lock released after a failing command" '[ ! -d "$lock" ]'

# 3. A second command waits for the first.
log="$tmp/order.log"; : > "$log"
bash "$heavy" bash -c "echo A-start >> '$log'; sleep 3; echo A-end >> '$log'" & a=$!
sleep 1
bash "$heavy" bash -c "echo B-start >> '$log'; echo B-end >> '$log'" & b=$!
wait "$a" "$b"
check "second command waits for the first" '[ "$(tr "\n" " " < "$log")" = "A-start A-end B-start B-end " ]'

# 4. A stale lock is taken over, and released afterwards.
plant_lock $(( $(date +%s) - 1000 )) "ghost"
start=$(date +%s)
HEAVY_LOCK_STALE_SECONDS=5 bash "$heavy" true; code=$?
check "stale lock is taken over quickly" '[ "$code" -eq 0 ] && [ $(( $(date +%s) - start )) -lt 5 ]'
check "lock removed after the takeover run" '[ ! -d "$lock" ]'

# 5. A fresh lock is never taken over.
plant_lock "$(date +%s)" "live-holder"
HEAVY_LOCK_STALE_SECONDS=300 timeout 3 bash "$heavy" true; code=$?
check "a fresh lock makes others wait" '[ "$code" -eq 124 ]'
check "the live holder keeps its lock" '[ "$(cat "$lock/owner")" = "live-holder" ]'
rm -rf "$lock"

# 6. Two waiters on one stale lock still run one at a time.
plant_lock $(( $(date +%s) - 1000 )) "ghost"
log2="$tmp/stale-order.log"; : > "$log2"
for n in 1 2; do
  HEAVY_LOCK_STALE_SECONDS=5 bash "$heavy" bash -c "echo $n-start >> '$log2'; sleep 2; echo $n-end >> '$log2'" &
done
wait
check "two waiters on one stale lock run one at a time" 'pairs_ok "$log2"'

# 7. No arguments: usage, exit 2.
bash "$heavy" 2>/dev/null; code=$?
check "no arguments exits 2" '[ "$code" -eq 2 ]'

# 8. It returns as soon as the command ends, even when its output goes through a pipe
#    (the heartbeat loop must not keep the caller's output open).
start=$(date +%s)
bash "$heavy" sleep 2 2>&1 | cat > /dev/null
check "returns promptly when its output is piped" '[ $(( $(date +%s) - start )) -lt 10 ]'

# 9. A wrapper killed with SIGKILL frees the lock after the stale window (its heartbeat stops).
HEAVY_LOCK_REFRESH_SECONDS=1 HEAVY_LOCK_STALE_SECONDS=3 bash "$heavy" sleep 30 > /dev/null 2>&1 & w=$!
sleep 2; kill -9 "$w" 2>/dev/null
HEAVY_LOCK_STALE_SECONDS=3 timeout 20 bash "$heavy" true 2>/dev/null; code=$?
check "a wrapper killed with SIGKILL frees the lock" '[ "$code" -eq 0 ]'
rm -rf "$lock"

# 10. A new lock whose heartbeat is empty (mid-write) is not taken over.
mkdir -p "$lock"; : > "$lock/heartbeat"; echo "live-holder" > "$lock/owner"
HEAVY_LOCK_STALE_SECONDS=300 timeout 3 bash "$heavy" true 2>/dev/null; code=$?
check "an empty heartbeat on a new lock isn't taken over" '[ "$code" -eq 124 ] && [ "$(cat "$lock/owner")" = "live-holder" ]'
rm -rf "$lock"

# 11. An old lock with a garbage heartbeat is taken over, without breaking the wrapper.
mkdir -p "$lock"; echo "abc" > "$lock/heartbeat"; echo "ghost" > "$lock/owner"
touch -d "@$(( $(date +%s) - 1000 ))" "$lock"
HEAVY_LOCK_STALE_SECONDS=5 timeout 10 bash "$heavy" true 2>/dev/null; code=$?
check "an old lock with a garbage heartbeat is taken over" '[ "$code" -eq 0 ]'
rm -rf "$lock"

# 12. An old lock with no heartbeat at all is taken over.
mkdir -p "$lock"; echo "ghost" > "$lock/owner"
touch -d "@$(( $(date +%s) - 1000 ))" "$lock"
HEAVY_LOCK_STALE_SECONDS=5 timeout 10 bash "$heavy" true 2>/dev/null; code=$?
check "an old lock without a heartbeat is taken over" '[ "$code" -eq 0 ]'
rm -rf "$lock"

# 13. A command run through heavy.sh can call heavy.sh again without waiting on itself.
timeout 10 bash "$heavy" bash -c "bash '$heavy' true" 2>/dev/null; code=$?
check "a nested heavy.sh call doesn't wait on its own lock" '[ "$code" -eq 0 ]'

if [ "$failures" -eq 0 ]; then echo "all heavy.sh tests passed"; else echo "$failures heavy.sh test(s) failed"; exit 1; fi
