# Monitor Setup Script Guide

This document explains `monitor-setup.sh` in this folder.

## Purpose

`monitor-setup.sh` manages display layouts for i3 using `xrandr`.

It is context-aware:
- If only laptop panel is connected, it uses laptop-only mode.
- If one external monitor is connected, it uses single-external modes.
- If two or more external monitors are connected, it uses multi-external modes.

It also stores the last mode in a state file so `cycle` moves to the next mode.

## Key Concepts

### Context

The script detects connected outputs from `xrandr --query` and classifies into:
- `laptop_only`
- `single_external`
- `multi_external`

### Modes

Default modes per context:
- `laptop_only`: `lcd-only`
- `single_external`: `extended`, `lcd-only`, `external-only`, `mirrored`
- `multi_external`: `dual`, `triple`, `lcd-only`

Important:
- `mirrored` is a single-external mode, so it will not appear when two externals are connected.
- For one HDMI (single external) setup, the script automatically enters `single_external`.

### Mode Toggles (Edit at Script Top)

You can enable/disable modes by editing flags at the top of `monitor-setup.sh`:
- `ENABLE_LCD_ONLY`
- `ENABLE_EXTENDED`
- `ENABLE_EXTERNAL_ONLY`
- `ENABLE_MIRRORED`
- `ENABLE_DUAL`
- `ENABLE_TRIPLE`

Use `1` for enabled and `0` for disabled.

Example: skip triple mode in dual-monitor context
```bash
ENABLE_TRIPLE=0
```

After changing toggles, check:
```bash
./monitor-setup.sh --verbose list
```

### State File

Default state file location:
- `${XDG_RUNTIME_DIR}/monitor-setup/state`
- fallback: `/tmp/monitor-setup-<uid>/state` if runtime dir is not writable

State format:
```txt
mode=<mode> context=<context> ts=<epoch>
```

The script uses a lock file in the same directory to prevent race conditions.

## Commands

```bash
./monitor-setup.sh [--dry-run] [--verbose] [command]
```

Supported commands:
- `cycle` (default): move to next mode in current context
- `set <mode>`: apply explicit mode if valid for context
- `choose`: pick a mode via `rofi` or `dmenu`
- `list`: print valid modes for current context
- `status`: print detected context/outputs and saved state
- `help`: show usage

## Example Usage

```bash
# Show what script detects right now
./monitor-setup.sh status

# See valid modes for current wiring
./monitor-setup.sh list

# Cycle to next mode
./monitor-setup.sh

# Set one mode explicitly
./monitor-setup.sh set dual

# Interactive picker
./monitor-setup.sh choose
```

## Safe Testing

Use dry-run to print the exact `xrandr` command without applying:

```bash
./monitor-setup.sh --dry-run --verbose cycle
```

Use a saved xrandr snapshot for offline debugging:

```bash
MONITOR_XRANDR_QUERY_FILE=./monitor-debug.xrandr-query.txt ./monitor-setup.sh --dry-run status
```

## Environment Variables

Optional overrides:
- `MONITOR_STATE_FILE`: custom state file path
- `MONITOR_LAPTOP_OUTPUT`: force laptop output name (example: `eDP-1`)
- `MONITOR_PREFERRED_LEFT`: preferred left external output
- `MONITOR_PREFERRED_RIGHT`: preferred right external output
- `MONITOR_XRANDR_QUERY_FILE`: read xrandr output from file (debug/testing)
- `I3_MSG_BIN`: override i3-msg path
- `WALLPAPER_GLOB`: wallpaper glob for `feh`

Examples:
```bash
MONITOR_PREFERRED_LEFT=DP-1-1-8 MONITOR_PREFERRED_RIGHT=DP-1-1-1 ./monitor-setup.sh set dual
MONITOR_STATE_FILE=/tmp/my-monitor-state ./monitor-setup.sh cycle
```

You can also override mode toggles via environment (temporary):
```bash
ENABLE_TRIPLE=0 ./monitor-setup.sh --verbose list
```

## How `cycle` Works

1. Detect current context.
2. Read state file.
3. If saved context differs from current context, start from first mode in current context.
4. Otherwise go to next mode in that context's mode list.
5. Apply one `xrandr` command, then update state.

## Post Apply Hooks

After successful apply (not dry-run), script does:
- `i3-msg restart` (if available)
- `feh --bg-scale --randomize ...` (if available)

## Troubleshooting

### "Unable to run xrandr"
- Make sure command runs from your active X/i3 session terminal.
- Check:
  - `echo "$DISPLAY"`
  - `echo "$XAUTHORITY"`
  - `xrandr --query`

### Wrong output selected
- Check output names via:
  ```bash
  xrandr --query
  ```
- Set preferred outputs:
  ```bash
  MONITOR_PREFERRED_LEFT=<name> MONITOR_PREFERRED_RIGHT=<name> ./monitor-setup.sh set dual
  ```

### `choose` says rofi/dmenu missing
- Install one of:
  - `rofi`
  - `dmenu`

### State seems stuck
- Check status:
  ```bash
  ./monitor-setup.sh status
  ```
- Remove state file (script recreates it):
  ```bash
  rm -f "${XDG_RUNTIME_DIR:-/tmp}/monitor-setup/state"
  ```

## Suggested i3 Keybinds

Current style (cycle):
```i3
bindsym XF86Display exec --no-startup-id ~/cron/monitor-setup.sh
bindsym $mod+p exec --no-startup-id ~/cron/monitor-setup.sh
```

Optional chooser:
```i3
bindsym $mod+Shift+p exec --no-startup-id ~/cron/monitor-setup.sh choose
```
