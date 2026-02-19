#!/usr/bin/env bash

# Quick Debug Checklist
# 1) Show detected outputs/context and saved state:
#    ./monitor-setup.sh --verbose status
# 2) Print valid modes for current wiring:
#    ./monitor-setup.sh --verbose list
# 3) Preview next change without applying:
#    ./monitor-setup.sh --dry-run --verbose cycle
# 4) Apply a specific mode explicitly:
#    ./monitor-setup.sh --verbose set dual
# 5) Use saved xrandr snapshot for offline debugging:
#    MONITOR_XRANDR_QUERY_FILE=./monitor-debug.xrandr-query.txt ./monitor-setup.sh --dry-run status
#
# Mode toggles (edit at top, keep 1=enabled, 0=disabled):
# - To skip triple monitor mode, set ENABLE_TRIPLE=0.
# - To disable mirrored in single-external context, set ENABLE_MIRRORED=0.

# Strict shell mode:
# -u: error on unset variables
# -o pipefail: pipeline fails if any command fails
set -u -o pipefail

# Mode toggles (small manual configuration surface).
ENABLE_LCD_ONLY="${ENABLE_LCD_ONLY:-1}"
ENABLE_EXTENDED="${ENABLE_EXTENDED:-1}"
ENABLE_EXTERNAL_ONLY="${ENABLE_EXTERNAL_ONLY:-1}"
ENABLE_MIRRORED="${ENABLE_MIRRORED:-1}"
ENABLE_DUAL="${ENABLE_DUAL:-1}"
ENABLE_TRIPLE="${ENABLE_TRIPLE:-0}"

# Runtime/state locations and optional overrides.
STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}/monitor-setup"
STATE_FILE_DEFAULT="${STATE_DIR}/state"
LOCK_FILE="${STATE_DIR}/lock"
XRANDR_QUERY_FILE="${MONITOR_XRANDR_QUERY_FILE:-}"
WALLPAPER_GLOB="${WALLPAPER_GLOB:-/home/nitish/dotfiles/wallpapers/*}"
I3_MSG_BIN="${I3_MSG_BIN:-/usr/bin/i3-msg}"
PREFERRED_LEFT="${MONITOR_PREFERRED_LEFT:-}"
PREFERRED_RIGHT="${MONITOR_PREFERRED_RIGHT:-}"
OVERRIDE_LAPTOP_OUTPUT="${MONITOR_LAPTOP_OUTPUT:-}"

USER_STATE_FILE=0
if [[ -n "${MONITOR_STATE_FILE:-}" ]]; then
  USER_STATE_FILE=1
else
  MONITOR_STATE_FILE="$STATE_FILE_DEFAULT"
fi

DRY_RUN=0
VERBOSE=0
XRANDR_QUERY=""
CONTEXT=""
LAPTOP_OUTPUT=""
SELECTED_EXTERNAL=""
LEFT_EXTERNAL=""
RIGHT_EXTERNAL=""
CURRENT_MODES=()
CONNECTED_OUTPUTS=()
CONNECTED_EXTERNALS=()
ALL_OUTPUTS=()
SAVED_MODE=""
SAVED_CONTEXT=""
CMD="cycle"
TARGET_MODE=""
NEXT_MODE=""

# Verbose logger (enabled with --verbose).
log() {
  if [[ "$VERBOSE" -eq 1 ]]; then
    printf '[monitor-setup] %s\n' "$*" >&2
  fi
}

fail() {
  printf '[monitor-setup] %s\n' "$*" >&2
  exit 1
}

# Wrapper for command execution.
# In dry-run mode we print exactly what would run and skip execution.
run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] %q' "$1"
    shift
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
    return 0
  fi
  "$@"
}

# Read xrandr snapshot:
# - from a debug file when MONITOR_XRANDR_QUERY_FILE is set
# - from live xrandr otherwise
load_xrandr_query() {
  if [[ -n "$XRANDR_QUERY_FILE" ]]; then
    [[ -r "$XRANDR_QUERY_FILE" ]] || fail "Cannot read MONITOR_XRANDR_QUERY_FILE: $XRANDR_QUERY_FILE"
    XRANDR_QUERY="$(<"$XRANDR_QUERY_FILE")"
    return
  fi
  XRANDR_QUERY="$(xrandr --query 2>/dev/null)" || fail "Unable to run xrandr."
}

# Parse outputs from xrandr text:
# - ALL_OUTPUTS: connected + disconnected outputs (for --off cleanup)
# - CONNECTED_OUTPUTS: physically connected outputs
# - LAPTOP_OUTPUT: eDP/LVDS panel (or explicit override)
# - CONNECTED_EXTERNALS: connected outputs excluding laptop panel
detect_outputs() {
  local out
  mapfile -t ALL_OUTPUTS < <(awk '/^[A-Za-z0-9.-]+ (connected|disconnected)/ {print $1}' <<<"$XRANDR_QUERY")
  mapfile -t CONNECTED_OUTPUTS < <(awk '/^[A-Za-z0-9.-]+ connected/ {print $1}' <<<"$XRANDR_QUERY")

  if [[ -n "$OVERRIDE_LAPTOP_OUTPUT" ]]; then
    LAPTOP_OUTPUT="$OVERRIDE_LAPTOP_OUTPUT"
  else
    LAPTOP_OUTPUT="$(awk '/^[A-Za-z0-9.-]+ connected/ {if ($1 ~ /^(eDP-|LVDS-)/) {print $1; exit}}' <<<"$XRANDR_QUERY")"
  fi

  CONNECTED_EXTERNALS=()
  for out in "${CONNECTED_OUTPUTS[@]}"; do
    if [[ -n "$LAPTOP_OUTPUT" && "$out" == "$LAPTOP_OUTPUT" ]]; then
      continue
    fi
    CONNECTED_EXTERNALS+=("$out")
  done
}

# Pick one external output used by single-external modes.
# Preference order: MONITOR_PREFERRED_LEFT -> first connected external.
choose_single_external() {
  local out
  SELECTED_EXTERNAL=""
  if [[ -n "$PREFERRED_LEFT" ]]; then
    for out in "${CONNECTED_EXTERNALS[@]}"; do
      if [[ "$out" == "$PREFERRED_LEFT" ]]; then
        SELECTED_EXTERNAL="$out"
        return
      fi
    done
  fi
  if [[ "${#CONNECTED_EXTERNALS[@]}" -gt 0 ]]; then
    SELECTED_EXTERNAL="${CONNECTED_EXTERNALS[0]}"
  fi
}

# Pick two external outputs used by dual/triple modes.
# Preference order: MONITOR_PREFERRED_LEFT/RIGHT -> first two connected.
choose_dual_externals() {
  local out
  LEFT_EXTERNAL=""
  RIGHT_EXTERNAL=""

  if [[ -n "$PREFERRED_LEFT" ]]; then
    for out in "${CONNECTED_EXTERNALS[@]}"; do
      if [[ "$out" == "$PREFERRED_LEFT" ]]; then
        LEFT_EXTERNAL="$out"
        break
      fi
    done
  fi

  if [[ -n "$PREFERRED_RIGHT" ]]; then
    for out in "${CONNECTED_EXTERNALS[@]}"; do
      if [[ "$out" == "$PREFERRED_RIGHT" ]]; then
        RIGHT_EXTERNAL="$out"
        break
      fi
    done
  fi

  for out in "${CONNECTED_EXTERNALS[@]}"; do
    if [[ -z "$LEFT_EXTERNAL" ]]; then
      LEFT_EXTERNAL="$out"
      continue
    fi
    if [[ -z "$RIGHT_EXTERNAL" && "$out" != "$LEFT_EXTERNAL" ]]; then
      RIGHT_EXTERNAL="$out"
      break
    fi
  done

  if [[ -n "$RIGHT_EXTERNAL" && "$RIGHT_EXTERNAL" == "$LEFT_EXTERNAL" ]]; then
    RIGHT_EXTERNAL=""
  fi
}

# Context drives which modes are valid:
# laptop_only / single_external / multi_external
detect_context() {
  local ext_count
  ext_count="${#CONNECTED_EXTERNALS[@]}"
  if [[ "$ext_count" -eq 0 ]]; then
    CONTEXT="laptop_only"
  elif [[ "$ext_count" -eq 1 ]]; then
    CONTEXT="single_external"
  else
    CONTEXT="multi_external"
  fi
  log "context=$CONTEXT laptop=${LAPTOP_OUTPUT:-none} externals=${CONNECTED_EXTERNALS[*]:-none}"
}

# Mode catalog per context.
mode_enabled() {
  local mode="$1"
  case "$mode" in
    lcd-only) [[ "$ENABLE_LCD_ONLY" == "1" ]] ;;
    extended) [[ "$ENABLE_EXTENDED" == "1" ]] ;;
    external-only) [[ "$ENABLE_EXTERNAL_ONLY" == "1" ]] ;;
    mirrored) [[ "$ENABLE_MIRRORED" == "1" ]] ;;
    dual) [[ "$ENABLE_DUAL" == "1" ]] ;;
    triple) [[ "$ENABLE_TRIPLE" == "1" ]] ;;
    *) return 1 ;;
  esac
}

add_mode_if_enabled() {
  local mode="$1"
  if mode_enabled "$mode"; then
    CURRENT_MODES+=("$mode")
  fi
}

set_modes_for_context() {
  CURRENT_MODES=()
  case "$CONTEXT" in
    laptop_only)
      add_mode_if_enabled "lcd-only"
      ;;
    single_external)
      add_mode_if_enabled "extended"
      add_mode_if_enabled "lcd-only"
      add_mode_if_enabled "external-only"
      add_mode_if_enabled "mirrored"
      ;;
    multi_external)
      add_mode_if_enabled "dual"
      add_mode_if_enabled "triple"
      add_mode_if_enabled "lcd-only"
      ;;
    *)
      fail "Unknown context: $CONTEXT"
      ;;
  esac

  if [[ "${#CURRENT_MODES[@]}" -eq 0 ]]; then
    fail "No enabled modes for context '$CONTEXT'. Update ENABLE_* toggles at top of script."
  fi
}

# State file format:
# mode=<name> context=<name> ts=<epoch>
state_read() {
  local raw
  SAVED_MODE=""
  SAVED_CONTEXT=""
  if [[ ! -f "$MONITOR_STATE_FILE" ]]; then
    return
  fi
  raw="$(<"$MONITOR_STATE_FILE")"
  SAVED_MODE="$(sed -n 's/.*mode=\([^ ]*\).*/\1/p' <<<"$raw")"
  SAVED_CONTEXT="$(sed -n 's/.*context=\([^ ]*\).*/\1/p' <<<"$raw")"
}

state_write() {
  local mode="$1"
  local ts
  # Dry-run should not mutate cycle state.
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return
  fi
  ts="$(date +%s)"
  mkdir -p "$STATE_DIR"
  printf 'mode=%s context=%s ts=%s\n' "$mode" "$CONTEXT" "$ts" >"$MONITOR_STATE_FILE"
}

# Given current saved mode, return next mode in circular order.
# If current is missing/invalid, start from first mode.
next_mode() {
  local i
  local current="$1"
  local count="${#CURRENT_MODES[@]}"
  if [[ "$count" -eq 0 ]]; then
    fail "No modes available for context $CONTEXT."
  fi
  if [[ -z "$current" ]]; then
    printf '%s\n' "${CURRENT_MODES[0]}"
    return
  fi
  for i in "${!CURRENT_MODES[@]}"; do
    if [[ "${CURRENT_MODES[$i]}" == "$current" ]]; then
      printf '%s\n' "${CURRENT_MODES[$(((i + 1) % count))]}"
      return
    fi
  done
  printf '%s\n' "${CURRENT_MODES[0]}"
}

# Validate a mode against current context list.
is_mode_allowed() {
  local mode="$1"
  local item
  for item in "${CURRENT_MODES[@]}"; do
    if [[ "$item" == "$mode" ]]; then
      return 0
    fi
  done
  return 1
}

# Resolve an output's active/preferred width from xrandr text.
# Used to place right/laptop displays without hardcoded resolutions.
output_width() {
  local out="$1"
  local width
  width="$(awk -v out="$out" '
    $1 == out && $2 == "connected" {
      if (match($0, /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/)) {
        geom = substr($0, RSTART, RLENGTH)
        split(geom, parts, /x|\+/)
        print parts[1]
        exit
      }
      in_block = 1
      next
    }
    in_block && $1 ~ /^[0-9]+x[0-9]+$/ {
      split($1, parts, "x")
      print parts[1]
      exit
    }
    in_block && /^[A-Za-z0-9.-]+ (connected|disconnected)/ { in_block = 0 }
  ' <<<"$XRANDR_QUERY")"

  if [[ -z "$width" ]]; then
    width=1920
  fi
  printf '%s\n' "$width"
}

# Build one xrandr command per mode and execute once.
# Every mode explicitly turns off non-participating outputs for stability.
xrandr_apply() {
  local mode="$1"
  local cmd=("xrandr")
  local out
  local w_left
  local w_right
  local x_laptop

  choose_single_external
  choose_dual_externals

  case "$mode" in
    # Laptop panel only, everything else off.
    lcd-only)
      if [[ -z "$LAPTOP_OUTPUT" ]]; then
        fail "No laptop panel detected for lcd-only."
      fi
      cmd+=("--output" "$LAPTOP_OUTPUT" "--auto" "--primary" "--pos" "0x0" "--rotate" "normal")
      for out in "${ALL_OUTPUTS[@]}"; do
        if [[ "$out" != "$LAPTOP_OUTPUT" ]]; then
          cmd+=("--output" "$out" "--off")
        fi
      done
      ;;

    # One external + laptop side by side (external at x=0).
    extended)
      if [[ -z "$LAPTOP_OUTPUT" || -z "$SELECTED_EXTERNAL" ]]; then
        fail "extended requires one laptop and one external output."
      fi
      cmd+=("--output" "$LAPTOP_OUTPUT" "--auto" "--pos" "1920x0" "--rotate" "normal")
      cmd+=("--output" "$SELECTED_EXTERNAL" "--auto" "--primary" "--pos" "0x0" "--rotate" "normal")
      for out in "${ALL_OUTPUTS[@]}"; do
        if [[ "$out" != "$LAPTOP_OUTPUT" && "$out" != "$SELECTED_EXTERNAL" ]]; then
          cmd+=("--output" "$out" "--off")
        fi
      done
      ;;

    # External only, laptop panel off.
    external-only)
      if [[ -z "$SELECTED_EXTERNAL" ]]; then
        fail "external-only requires at least one external output."
      fi
      cmd+=("--output" "$SELECTED_EXTERNAL" "--auto" "--primary" "--pos" "0x0" "--rotate" "normal")
      for out in "${ALL_OUTPUTS[@]}"; do
        if [[ "$out" != "$SELECTED_EXTERNAL" ]]; then
          cmd+=("--output" "$out" "--off")
        fi
      done
      ;;

    # External mirrors laptop panel.
    mirrored)
      if [[ -z "$LAPTOP_OUTPUT" || -z "$SELECTED_EXTERNAL" ]]; then
        fail "mirrored requires one laptop and one external output."
      fi
      cmd+=("--output" "$LAPTOP_OUTPUT" "--auto" "--pos" "0x0" "--rotate" "normal")
      cmd+=("--output" "$SELECTED_EXTERNAL" "--auto" "--primary" "--same-as" "$LAPTOP_OUTPUT")
      for out in "${ALL_OUTPUTS[@]}"; do
        if [[ "$out" != "$LAPTOP_OUTPUT" && "$out" != "$SELECTED_EXTERNAL" ]]; then
          cmd+=("--output" "$out" "--off")
        fi
      done
      ;;

    # Two externals side by side, laptop panel off.
    dual)
      if [[ -z "$LEFT_EXTERNAL" || -z "$RIGHT_EXTERNAL" ]]; then
        fail "dual requires at least two external outputs."
      fi
      w_left="$(output_width "$LEFT_EXTERNAL")"
      cmd+=("--output" "$LEFT_EXTERNAL" "--auto" "--primary" "--pos" "0x0" "--rotate" "normal")
      cmd+=("--output" "$RIGHT_EXTERNAL" "--auto" "--pos" "${w_left}x0" "--rotate" "normal")
      for out in "${ALL_OUTPUTS[@]}"; do
        if [[ "$out" != "$LEFT_EXTERNAL" && "$out" != "$RIGHT_EXTERNAL" ]]; then
          cmd+=("--output" "$out" "--off")
        fi
      done
      ;;

    # Two externals + laptop (laptop to the far right).
    triple)
      if [[ -z "$LAPTOP_OUTPUT" || -z "$LEFT_EXTERNAL" || -z "$RIGHT_EXTERNAL" ]]; then
        fail "triple requires laptop and two external outputs."
      fi
      w_left="$(output_width "$LEFT_EXTERNAL")"
      w_right="$(output_width "$RIGHT_EXTERNAL")"
      x_laptop="$((w_left + w_right))"
      cmd+=("--output" "$LEFT_EXTERNAL" "--auto" "--primary" "--pos" "0x0" "--rotate" "normal")
      cmd+=("--output" "$RIGHT_EXTERNAL" "--auto" "--pos" "${w_left}x0" "--rotate" "normal")
      cmd+=("--output" "$LAPTOP_OUTPUT" "--auto" "--pos" "${x_laptop}x0" "--rotate" "normal")
      for out in "${ALL_OUTPUTS[@]}"; do
        if [[ "$out" != "$LEFT_EXTERNAL" && "$out" != "$RIGHT_EXTERNAL" && "$out" != "$LAPTOP_OUTPUT" ]]; then
          cmd+=("--output" "$out" "--off")
        fi
      done
      ;;

    *)
      fail "Unknown mode: $mode"
      ;;
  esac

  run_cmd "${cmd[@]}"
}

# Post-success hooks: i3 restart and wallpaper refresh.
# These are skipped during --dry-run.
post_apply() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return
  fi

  if [[ -x "$I3_MSG_BIN" ]]; then
    "$I3_MSG_BIN" restart >/dev/null 2>&1 || true
  fi

  if command -v feh >/dev/null 2>&1; then
    # shellcheck disable=SC2086
    feh --bg-scale --randomize $WALLPAPER_GLOB >/dev/null 2>&1 || true
  fi
}

# Status/list helpers for quick inspection.
print_status() {
  state_read
  printf 'context: %s\n' "$CONTEXT"
  printf 'laptop: %s\n' "${LAPTOP_OUTPUT:-none}"
  printf 'connected_externals: %s\n' "${CONNECTED_EXTERNALS[*]:-none}"
  printf 'state_file: %s\n' "$MONITOR_STATE_FILE"
  printf 'saved_mode: %s\n' "${SAVED_MODE:-none}"
  printf 'saved_context: %s\n' "${SAVED_CONTEXT:-none}"
}

print_modes() {
  local m
  printf 'context: %s\n' "$CONTEXT"
  printf 'modes:\n'
  for m in "${CURRENT_MODES[@]}"; do
    printf '%s\n' "$m"
  done
}

choose_mode_interactive() {
  local selected
  if command -v rofi >/dev/null 2>&1; then
    selected="$(printf '%s\n' "${CURRENT_MODES[@]}" | rofi -dmenu -p 'Monitor mode')"
  elif command -v dmenu >/dev/null 2>&1; then
    selected="$(printf '%s\n' "${CURRENT_MODES[@]}" | dmenu -p 'Monitor mode')"
  else
    fail "Neither rofi nor dmenu is available for choose."
  fi

  if [[ -z "$selected" ]]; then
    exit 0
  fi

  if ! is_mode_allowed "$selected"; then
    fail "Invalid mode selected: $selected"
  fi

  xrandr_apply "$selected"
  state_write "$selected"
  post_apply
}

usage() {
  cat <<'USAGE'
Usage: monitor-setup.sh [--dry-run] [--verbose] [command]

Commands:
  cycle            Cycle to next mode for current context (default).
  set <mode>       Apply a specific mode for current context.
  choose           Pick mode via rofi/dmenu.
  list             List valid modes for current context.
  status           Show detected outputs/context and saved state.
  help             Show this message.
USAGE
}

# Parse flags + command.
# Default command is "cycle" to preserve old keybind behavior.
parse_args() {
  CMD="cycle"
  TARGET_MODE=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --verbose)
        VERBOSE=1
        shift
        ;;
      cycle|list|status|choose|help)
        CMD="$1"
        shift
        ;;
      set)
        CMD="set"
        TARGET_MODE="${2:-}"
        if [[ -z "$TARGET_MODE" ]]; then
          fail "set requires a mode argument."
        fi
        shift 2
        ;;
      -h|--help)
        CMD="help"
        shift
        ;;
      *)
        fail "Unknown argument: $1"
        ;;
    esac
  done
}

switch_to_tmp_state_dir() {
  STATE_DIR="/tmp/monitor-setup-${UID}"
  if [[ "$USER_STATE_FILE" -eq 0 ]]; then
    MONITOR_STATE_FILE="${STATE_DIR}/state"
  fi
  LOCK_FILE="${STATE_DIR}/lock"
  mkdir -p "$STATE_DIR" || fail "Unable to create state dir."
}

prepare_state_dir() {
  local probe_file

  if ! mkdir -p "$STATE_DIR" 2>/dev/null; then
    switch_to_tmp_state_dir
    return
  fi

  probe_file="$(mktemp "${STATE_DIR}/.write-test.XXXXXX" 2>/dev/null || true)"
  if [[ -z "$probe_file" ]]; then
    switch_to_tmp_state_dir
    return
  fi

  rm -f "$probe_file" >/dev/null 2>&1 || true
}

main() {
  parse_args "$@"

  # Create runtime state dir; fallback to /tmp if runtime path is unavailable.
  prepare_state_dir

  # Single-process lock so repeated key presses don't race.
  exec 9>"$LOCK_FILE"
  if command -v flock >/dev/null 2>&1; then
    flock 9
  fi

  load_xrandr_query
  detect_outputs
  detect_context
  set_modes_for_context

  case "$CMD" in
    help)
      usage
      ;;
    list)
      print_modes
      ;;
    status)
      print_status
      ;;
    choose)
      choose_mode_interactive
      ;;
    set)
      if ! is_mode_allowed "$TARGET_MODE"; then
        fail "Mode '$TARGET_MODE' is not valid for context '$CONTEXT'."
      fi
      xrandr_apply "$TARGET_MODE"
      state_write "$TARGET_MODE"
      post_apply
      ;;
    cycle)
      state_read
      # Reset cycle when context changes (e.g., unplug dock / plug monitor).
      if [[ "${SAVED_CONTEXT:-}" != "$CONTEXT" ]]; then
        NEXT_MODE="${CURRENT_MODES[0]}"
      else
        NEXT_MODE="$(next_mode "${SAVED_MODE:-}")"
      fi
      xrandr_apply "$NEXT_MODE"
      state_write "$NEXT_MODE"
      post_apply
      ;;
    *)
      fail "Unknown command: $CMD"
      ;;
  esac
}

main "$@"
