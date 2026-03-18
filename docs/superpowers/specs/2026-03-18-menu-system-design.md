# distromac Menu System — Design Spec

**Date:** 2026-03-18
**Status:** Draft

## Overview

An interactive menu system for distromac, inspired by omarchy's `omarchy-menu`. Provides a central hub for all distromac actions via a floating Ghostty terminal window with fzf-based navigation. Triggered by `ctrl-t` in Aerospace.

## Architecture

Three components work together:

1. **`bin/distromac-menu`** — Monolithic bash script containing all menu logic, submenus, helpers, and action execution.
2. **Aerospace keybinding** — `ctrl-t` launches Ghostty targeting the menu script.
3. **Aerospace window rule** — Detects the menu window by title and forces floating layout.

### Trigger Flow

```
ctrl-t (Aerospace) → ghostty -e distromac-menu
                   → distromac-menu sets terminal title via escape sequence
                   → Aerospace detects window title "distromac-menu" → layout floating
                   → fzf renders menu → user selects → action runs
                   → "Press any key to close..." → window closes
```

Note: Ghostty's `--class` flag is a Linux/X11/Wayland concept and does not work on macOS. Instead, the script sets the terminal title with `printf '\033]0;distromac-menu\007'` at startup, which Aerospace matches via `window-title-regex-substring`.

### Toggle Behavior

If `distromac-menu` is already running when `ctrl-t` is pressed again, the existing instance closes instead of opening a second one. Detected via a PID file at `/tmp/distromac-menu.pid`.

## Aerospace Configuration Changes

### New keybinding

```toml
ctrl-t = 'exec-and-forget ghostty -e distromac-menu'
```

### New window detection rule

```toml
[[on-window-detected]]
if.app-id = 'com.mitchellh.ghostty'
if.window-title-regex-substring = 'distromac-menu'
run = ['layout floating']
```

### Removed

The Raycast theme picker script (`config/raycast/scripts/distromac-theme-pick.sh`) is removed. The menu system replaces its functionality.

## Menu Structure

```
Main Menu
├── 󰸌  Style
│   ├── 󰸌  Theme          → calls distromac-theme-pick (reuses existing fzf preview)
│   ├──   Current Theme   → displays active theme name
│   └──   Refresh Theme   → re-applies current theme
│
├──   Setup
│   ├──   Restart Sketchybar
│   ├──   Restart Borders
│   ├──   Restart Aerospace
│   ├──   Refresh Config    → submenu to choose which config to reset
│   └──   macOS Defaults    → re-apply all macOS defaults
│
├──   Update
│   ├──   Distromac Update
│   └──   Version
│
└──   System
    ├──   Lock Screen
    ├── 󰜉  Restart
    └── 󰐥  Shutdown
```

### Navigation

- **Escape / empty selection** in a submenu → returns to parent menu
- **Escape / empty selection** in main menu → closes the window
- **ctrl-t again** → toggle closes the menu if already open

## Startup

At the top of `distromac-menu`, before any menu logic:

1. **Set terminal title** for Aerospace detection:
   ```bash
   printf '\033]0;distromac-menu\007'
   ```

2. **Check fzf dependency:**
   ```bash
   if ! command -v fzf &>/dev/null; then
     echo "Error: fzf is required. Run: brew install fzf" >&2
     read -rsn1
     exit 1
   fi
   ```

3. **Toggle detection** — close existing instance if running (see Toggle Detection section).

4. **Load theme colors** from `~/.config/distromac/current/theme/colors.toml`.

## Window Sizing

The Ghostty invocation does not specify window dimensions — the floating window uses Ghostty's default size. This is acceptable since Aerospace allows the user to resize floating windows. A future improvement could pass `--window-height` and `--window-width` flags if Ghostty adds stable CLI support for them.

## Core Helpers

### `menu()` — fzf wrapper

Shared by all submenus. Renders options with consistent styling.

```bash
menu() {
  local prompt="$1"
  local options="$2"
  echo -e "$options" | fzf --prompt "$prompt > " \
    --height=100% --layout=reverse \
    --border=rounded --margin=1,2 \
    --color="fg:$fg,bg:$bg,hl:$accent,fg+:$bg,bg+:$accent,pointer:$accent,prompt:$accent,border:$surface1"
}
```

Colors are loaded dynamically from `~/.config/distromac/current/theme/colors.toml` at menu startup, so fzf matches the active theme.

### `run_and_wait()` — action executor

Runs a command, displays its output, and waits for user acknowledgment before closing.

```bash
run_and_wait() {
  echo ""
  "$@"
  echo ""
  echo "Press any key to close..."
  read -rsn1
}
```

### `back_to()` — navigation helper

Returns to a parent menu or exits depending on invocation context.

```bash
BACK_TO_EXIT=false

back_to() {
  local parent_menu="$1"
  if [[ $BACK_TO_EXIT == "true" ]]; then
    exit 0
  elif [[ -n $parent_menu ]]; then
    "$parent_menu"
  else
    show_main_menu
  fi
}
```

## Theme-Aware fzf Colors

At startup, `distromac-menu` reads `~/.config/distromac/current/theme/colors.toml` and extracts hex values for:

- `foreground` → fzf `fg`
- `background` → fzf `bg`
- `accent` → fzf `hl`, `bg+`, `pointer`, `prompt`
- `surface1` → fzf `border`

This ensures the menu visually matches the active distromac theme.

## Toggle Detection

Uses a PID file for reliable instance detection, avoiding false positives from `pgrep`.

```bash
toggle_existing_menu() {
  local pidfile="/tmp/distromac-menu.pid"
  if [[ -f $pidfile ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    kill "$(cat "$pidfile")"
    rm -f "$pidfile"
    exit 0
  fi
  echo $$ > "$pidfile"
  trap 'rm -f "$pidfile"' EXIT
}
```

Called at the top of `distromac-menu` before rendering anything.

## Extensibility

Users can add custom menu items by creating `~/.config/distromac/extensions/menu.sh`. If present, it is sourced before the main menu renders, allowing users to override or extend `show_main_menu` and submenu functions.

## System Actions

| Action | Command |
|--------|---------|
| Lock Screen | `pmset displaysleepnow` |
| Restart | `osascript -e 'tell app "System Events" to restart'` |
| Shutdown | `osascript -e 'tell app "System Events" to shut down'` |
| Restart Sketchybar | `distromac-restart-sketchybar` |
| Restart Borders | `distromac-restart-borders` |
| Restart Aerospace | `distromac-restart-aerospace` |
| Apply macOS Defaults | `distromac-defaults-apply` |
| Refresh Config | `distromac-refresh-config <path>` |
| Set Theme | `distromac-theme-set <name>` |
| Update | `distromac-update` |
| Version | `distromac-version` |

## Files Changed

| File | Action |
|------|--------|
| `bin/distromac-menu` | **New** — main menu script |
| `config/aerospace/aerospace.toml` | **Modified** — add ctrl-t binding + window rule |
| `config/raycast/scripts/distromac-theme-pick.sh` | **Removed** — replaced by menu |

## Direct Submenu Access

The menu supports a parameter to jump directly to a submenu:

```bash
distromac-menu style    # opens directly in Style submenu
distromac-menu system   # opens directly in System submenu
```

When invoked with a parameter, `BACK_TO_EXIT=true` so Escape exits instead of going to main menu.
