#!/usr/bin/env bash

set -u -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="${SCRIPT_DIR}/monitor-setup.sh"
TS="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${SCRIPT_DIR}/monitor-test-session-${TS}.log"
SLEEP_SECONDS="${MONITOR_TEST_SLEEP_SECONDS:-12}"

if [[ ! -x "$SETUP_SCRIPT" ]]; then
  echo "ERROR: ${SETUP_SCRIPT} not found or not executable." >&2
  exit 1
fi

exec > >(tee -a "$LOG_FILE") 2>&1

pause_after_apply() {
  echo "Waiting ${SLEEP_SECONDS}s so you can observe monitor changes..."
  sleep "$SLEEP_SECONDS"
}

echo "Monitor test started at $(date)"
echo "Log file: $LOG_FILE"
echo "Pause between apply steps: ${SLEEP_SECONDS}s"
echo

echo "===== ENV ====="
echo "DISPLAY=${DISPLAY:-<unset>}"
echo "XAUTHORITY=${XAUTHORITY:-<unset>}"
echo "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-<unset>}"
echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-<unset>}"
echo

echo "===== BASELINE ====="
xrandr --query
echo
"$SETUP_SCRIPT" --verbose status
echo
"$SETUP_SCRIPT" --verbose list
echo
"$SETUP_SCRIPT" --dry-run --verbose cycle
echo

echo "===== MANUAL TEST 1: cycle (apply) ====="
"$SETUP_SCRIPT" --verbose cycle
pause_after_apply
xrandr --query
"$SETUP_SCRIPT" --verbose status
echo

echo "===== MANUAL TEST 2: cycle again (apply) ====="
"$SETUP_SCRIPT" --verbose cycle
pause_after_apply
xrandr --query
"$SETUP_SCRIPT" --verbose status
echo

echo "===== MANUAL TEST 3: explicit set lcd-only ====="
"$SETUP_SCRIPT" --verbose set lcd-only
pause_after_apply
xrandr --query
"$SETUP_SCRIPT" --verbose status
echo

echo "===== DONE ====="
echo "Completed at $(date)"
echo "Share this log file for review: $LOG_FILE"
