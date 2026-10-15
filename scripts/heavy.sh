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

# A command already running under the lock (a script that calls heavy.sh again) just runs.
if [ "${HEAVY_LOCK_HELD:-}" = 1 ]; then
  exec "$@"
fi

root="${HEAVY_LOCK_DIR:-$HOME/.claude/locks}"
lock="$root/heavy"
stale_after="${HEAVY_LOCK_STALE_SECONDS:-300}"
refresh_every="${HEAVY_LOCK_REFRESH_SECONDS:-60}"
poll="${HEAVY_LOCK_POLL_SECONDS:-2}"
me="$$-$RANDOM"
hb_pid=""
mkdir -p "$root"

# Written to a temp file and renamed, so a reader never sees a half-written heartbeat.
beat() { date +%s > "$lock/heartbeat.$me" 2>/dev/null && mv -f "$lock/heartbeat.$me" "$lock/heartbeat" 2>/dev/null; }

# When the lock was last known alive: its heartbeat, or, if that is missing or not a number, the
# lock folder's modification time. Prints nothing when neither can be read.
last_alive() {
  local hb; hb=$(cat "$1/heartbeat" 2>/dev/null)
  case "$hb" in ''|*[!0-9]*) stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null ;; *) echo "$hb" ;; esac
}

# Take over a lock whose holder stopped refreshing it. The move is atomic, and the lock is checked
# again after it, so a lock refreshed in between is put back, not stolen.
# ponytail: a waiter paused between the move and the put-back could still collide (~ms window).
take_over_if_stale() {
  local seen; seen=$(last_alive "$lock")
  [ -n "$seen" ] || return 1
  [ $(( $(date +%s) - seen )) -gt "$stale_after" ] || return 1
  local moved="$root/heavy.stale.$me"
  mv "$lock" "$moved" 2>/dev/null || return 1
  if [ "$(last_alive "$moved")" = "$seen" ]; then
    echo "heavy.sh: took over a stale lock held by $(cat "$moved/owner" 2>/dev/null)" >&2
    rm -rf "$moved"
  elif [ ! -e "$lock" ]; then
    mv "$moved" "$lock" 2>/dev/null || rm -rf "$moved"
  else
    rm -rf "$moved"
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
  echo "$me $(hostname 2>/dev/null) $*" > "$lock/owner"
  beat
}

release() {
  [ -n "$hb_pid" ] && kill "$hb_pid" 2>/dev/null
  # Remove the lock only while it's still ours (a stale takeover may have replaced it).
  case "$(cat "$lock/owner" 2>/dev/null)" in "$me "*) rm -rf "$lock" ;; esac
}

trap release EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
acquire "$@"
# The heartbeat stops when this wrapper is gone (killed with SIGKILL included), so its lock goes
# stale instead of being held forever. It gets no stdout or stderr: a `sleep` left behind would
# otherwise keep the caller's output open, and the caller would hang until it ends.
( while sleep "$refresh_every" && kill -0 $$ 2>/dev/null; do beat || exit 0; done ) > /dev/null 2>&1 &
hb_pid=$!
export HEAVY_LOCK_HELD=1
"$@"
exit $?
