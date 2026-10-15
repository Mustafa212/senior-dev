#!/usr/bin/env bash
# Run one heavy command (a build, a test suite) at a time across every Claude Code session on this
# machine, so parallel sessions don't stall each other.
# Usage: bash heavy.sh <command> [args...]
# Env: HEAVY_LOCK_DIR (~/.claude/locks), HEAVY_LOCK_STALE_SECONDS (300),
#      HEAVY_LOCK_REFRESH_SECONDS (60), HEAVY_LOCK_POLL_SECONDS (2)
set -u

if [ "$#" -eq 0 ]; then
  echo "usage: bash heavy.sh <command> [args...]" >&2
  exit 2
fi

root="${HEAVY_LOCK_DIR:-$HOME/.claude/locks}"
lock="$root/heavy"
stale_after="${HEAVY_LOCK_STALE_SECONDS:-300}"
refresh_every="${HEAVY_LOCK_REFRESH_SECONDS:-60}"
poll="${HEAVY_LOCK_POLL_SECONDS:-2}"
me="$$-$RANDOM"
hb_pid=""
mkdir -p "$root"

# Take over a lock whose holder stopped refreshing it. The move is atomic, and the heartbeat is
# compared again after it, so a lock refreshed or replaced in between is put back, not stolen.
# A lock without a heartbeat yet was just created by its holder: never stale.
# ponytail: a waiter paused between the move and the re-check could still collide (~ms window).
take_over_if_stale() {
  [ -f "$lock/heartbeat" ] || return 1
  local seen; seen=$(cat "$lock/heartbeat" 2>/dev/null) || return 1
  [ $(( $(date +%s) - seen )) -gt "$stale_after" ] || return 1
  local moved="$root/heavy.stale.$me"
  mv "$lock" "$moved" 2>/dev/null || return 1
  if [ "$(cat "$moved/heartbeat" 2>/dev/null)" = "$seen" ]; then
    echo "heavy.sh: took over a stale lock held by $(cat "$moved/owner" 2>/dev/null)" >&2
    rm -rf "$moved"
  else
    mv "$moved" "$lock" 2>/dev/null || rm -rf "$moved"
  fi
}

acquire() {
  local waited=0
  until mkdir "$lock" 2>/dev/null; do
    take_over_if_stale && continue
    if [ $(( waited % 60 )) -eq 0 ]; then
      echo "heavy.sh: waiting for $(cat "$lock/owner" 2>/dev/null || echo 'another session')" >&2
    fi
    sleep "$poll"
    waited=$(( waited + poll ))
  done
  date +%s > "$lock/heartbeat"
  echo "$me $(hostname 2>/dev/null) $*" > "$lock/owner"
}

release() {
  [ -n "$hb_pid" ] && kill "$hb_pid" 2>/dev/null
  # Remove the lock only while it's still ours (a stale takeover may have replaced it).
  case "$(cat "$lock/owner" 2>/dev/null)" in "$me "*) rm -rf "$lock" ;; esac
}

acquire "$@"
trap release EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
# The heartbeat loop gets no stdout or stderr: a `sleep` left behind when it's stopped would
# otherwise keep the caller's output open, and the caller would hang until it ends.
( while sleep "$refresh_every"; do date +%s > "$lock/heartbeat" 2>/dev/null || exit 0; done ) > /dev/null 2>&1 &
hb_pid=$!
"$@"
exit $?
