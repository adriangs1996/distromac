# Menu System Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an interactive fzf-based menu system for distromac, launched via ctrl-t in a floating Ghostty window through Aerospace.

**Architecture:** A monolithic bash script (`bin/distromac-menu`) with helper functions for fzf rendering, navigation, and action execution. Aerospace keybinding triggers Ghostty which runs the menu. Window title detection makes it float automatically.

**Tech Stack:** Bash 5, fzf, Ghostty, Aerospace, osascript

**Spec:** `docs/superpowers/specs/2026-03-18-menu-system-design.md`

---

### Task 1: Create `bin/distromac-menu` with startup, helpers, and main menu

**Files:**
- Create: `bin/distromac-menu`

This task creates the script with all startup logic, core helper functions, and the main menu — but no submenus yet (those come in subsequent tasks).

- [ ] **Step 1: Create the script with startup and helpers**

```bash
#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.distromac}"
export PATH="$DISTROMAC_PATH/bin:$PATH"

# --- Startup ---

# Set terminal title for Aerospace floating detection
printf '\033]0;distromac-menu\007'

# Check fzf dependency
if ! command -v fzf &>/dev/null; then
  echo "Error: fzf is required. Run: brew install fzf" >&2
  echo ""
  echo "Press any key to close..."
  read -rsn1
  exit 1
fi

# Toggle: close existing menu if already running
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

toggle_existing_menu

# Load theme colors for fzf styling
load_theme_colors() {
  local colors_file="$HOME/.config/distromac/current/theme/colors.toml"

  # Defaults if no theme is set
  fg="#cdd6f4"
  bg="#1e1e2e"
  accent="#bb9af7"
  surface1="#45475a"

  [[ ! -f $colors_file ]] && return

  while IFS='=' read -r key value; do
    [[ $key =~ ^[[:space:]]*# ]] && continue
    [[ -z $key ]] && continue
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs | sed 's/^"//;s/"$//' | xargs)
    case $key in
      foreground) fg="$value" ;;
      background) bg="$value" ;;
      accent)     accent="$value" ;;
      surface1)   surface1="$value" ;;
    esac
  done < "$colors_file"
}

load_theme_colors

# --- Core Helpers ---

BACK_TO_EXIT=false

menu() {
  local prompt="$1"
  local options="$2"
  echo -e "$options" | fzf --prompt " $prompt > " \
    --height=100% --layout=reverse \
    --border=rounded --margin=1,2 \
    --no-info --no-scrollbar \
    --color="fg:$fg,bg:$bg,hl:$accent,fg+:$bg,bg+:$accent,pointer:$accent,prompt:$accent,border:$surface1,header:$accent"
}

run_and_wait() {
  echo ""
  "$@"
  echo ""
  echo "Press any key to close..."
  read -rsn1
}

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

# --- Main Menu ---

show_main_menu() {
  case $(menu "Menu" "󰸌  Style\n  Setup\n  Update\n  System") in
    *Style*)  show_style_menu ;;
    *Setup*)  show_setup_menu ;;
    *Update*) show_update_menu ;;
    *System*) show_system_menu ;;
    *)        exit 0 ;;
  esac
}

# Submenu stubs — implemented in subsequent tasks
show_style_menu()  { show_main_menu; }
show_setup_menu()  { show_main_menu; }
show_update_menu() { show_main_menu; }
show_system_menu() { show_main_menu; }

# Allow user extensions
USER_EXTENSIONS="$HOME/.config/distromac/extensions/menu.sh"
[[ -f $USER_EXTENSIONS ]] && source "$USER_EXTENSIONS"

# Direct submenu access
if [[ -n $1 ]]; then
  BACK_TO_EXIT=true
  case "${1,,}" in
    style)  show_style_menu ;;
    setup)  show_setup_menu ;;
    update) show_update_menu ;;
    system) show_system_menu ;;
    *)      show_main_menu ;;
  esac
else
  show_main_menu
fi
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x bin/distromac-menu`

- [ ] **Step 3: Verify the script parses correctly**

Run: `bash -n bin/distromac-menu`
Expected: no output (no syntax errors)

- [ ] **Step 4: Commit**

```bash
git add bin/distromac-menu
git commit -m "feat: add distromac-menu script with startup, helpers, and main menu"
```

---

### Task 2: Implement Style submenu

**Files:**
- Modify: `bin/distromac-menu` (replace `show_style_menu` stub)

- [ ] **Step 1: Replace the `show_style_menu` stub**

Replace `show_style_menu()  { show_main_menu; }` with:

```bash
show_style_menu() {
  case $(menu "Style" "󰸌  Theme\n  Current Theme\n  Refresh Theme") in
    *Current*)
      run_and_wait distromac-theme-current
      ;;
    *Refresh*)
      local current
      current=$(distromac-theme-current 2>/dev/null || echo "")
      if [[ -n $current ]] && [[ $current != "No theme set" ]]; then
        run_and_wait distromac-theme-set "$current"
      else
        echo "No theme set."
        echo ""
        echo "Press any key to close..."
        read -rsn1
      fi
      ;;
    *Theme*)
      distromac-theme-pick
      exit 0
      ;;
    *) back_to ;;
  esac
}
```

- [ ] **Step 2: Verify syntax**

Run: `bash -n bin/distromac-menu`
Expected: no output

- [ ] **Step 3: Commit**

```bash
git add bin/distromac-menu
git commit -m "feat: add Style submenu to distromac-menu"
```

---

### Task 3: Implement Setup submenu

**Files:**
- Modify: `bin/distromac-menu` (replace `show_setup_menu` stub)

- [ ] **Step 1: Replace the `show_setup_menu` stub**

Replace `show_setup_menu()  { show_main_menu; }` with:

```bash
show_setup_menu() {
  case $(menu "Setup" "  Restart Sketchybar\n  Restart Borders\n  Restart Aerospace\n  Refresh Config\n  macOS Defaults") in
    *Sketchybar*)  run_and_wait distromac-restart-sketchybar ;;
    *Borders*)     run_and_wait distromac-restart-borders ;;
    *Aerospace*)   run_and_wait distromac-restart-aerospace ;;
    *Refresh*)     show_refresh_config_menu ;;
    *Defaults*)    run_and_wait distromac-defaults-apply ;;
    *) back_to ;;
  esac
}

show_refresh_config_menu() {
  # Only list individual files that distromac-refresh-config can handle
  local configs="aerospace/aerospace.toml"
  configs="$configs\nghostty/config"
  configs="$configs\ntmux/tmux.conf"
  configs="$configs\nstarship/starship.toml"
  configs="$configs\nborders/bordersrc"
  configs="$configs\nlsd/colors.yaml"
  configs="$configs\nbat/config"
  configs="$configs\nzsh/.zshrc"

  local selected
  selected=$(menu "Refresh Config" "$configs")

  case $selected in
    "") back_to show_setup_menu ;;
    *)
      run_and_wait distromac-refresh-config "$selected"
      ;;
  esac
}
```

- [ ] **Step 2: Verify syntax**

Run: `bash -n bin/distromac-menu`
Expected: no output

- [ ] **Step 3: Commit**

```bash
git add bin/distromac-menu
git commit -m "feat: add Setup submenu with refresh config to distromac-menu"
```

---

### Task 4: Implement Update and System submenus

**Files:**
- Modify: `bin/distromac-menu` (replace `show_update_menu` and `show_system_menu` stubs)

- [ ] **Step 1: Replace the `show_update_menu` stub**

Replace `show_update_menu() { show_main_menu; }` with:

```bash
show_update_menu() {
  case $(menu "Update" "  Distromac Update\n  Version") in
    *Update*) run_and_wait distromac-update ;;
    *Version*) run_and_wait distromac-version ;;
    *) back_to ;;
  esac
}
```

- [ ] **Step 2: Replace the `show_system_menu` stub**

Replace `show_system_menu() { show_main_menu; }` with:

```bash
show_system_menu() {
  case $(menu "System" "  Lock Screen\n󰜉  Restart\n󰐥  Shutdown") in
    *Lock*)     pmset displaysleepnow ;;
    *Restart*)  osascript -e 'tell app "System Events" to restart' ;;
    *Shutdown*) osascript -e 'tell app "System Events" to shut down' ;;
    *) back_to ;;
  esac
}
```

- [ ] **Step 3: Verify syntax**

Run: `bash -n bin/distromac-menu`
Expected: no output

- [ ] **Step 4: Commit**

```bash
git add bin/distromac-menu
git commit -m "feat: add Update and System submenus to distromac-menu"
```

---

### Task 5: Add Aerospace keybinding and window rule

**Files:**
- Modify: `config/aerospace/aerospace.toml:95` (add ctrl-t binding near other keybindings)
- Modify: `config/aerospace/aerospace.toml:191` (add window detection rule at the end)

- [ ] **Step 1: Add ctrl-t keybinding**

Add after line 98 (`alt-shift-o = 'exec-and-forget open -a obsidian'`):

```toml
ctrl-t = 'exec-and-forget ghostty -e distromac-menu'
```

- [ ] **Step 2: Add window detection rule for floating**

Add at the end of the file (after the existing `[[on-window-detected]]` blocks):

```toml
[[on-window-detected]]
if.app-id = 'com.mitchellh.ghostty'
if.window-title-regex-substring = 'distromac-menu'
run = ['layout floating']
```

- [ ] **Step 3: Verify TOML is valid**

Run: `python3 -c "import tomllib; tomllib.load(open('config/aerospace/aerospace.toml', 'rb')); print('Valid TOML')"`
Expected: `Valid TOML`

- [ ] **Step 4: Commit**

```bash
git add config/aerospace/aerospace.toml
git commit -m "feat: add ctrl-t keybinding and floating rule for distromac-menu"
```

---

### Task 6: Remove Raycast theme picker script

**Files:**
- Remove: `config/raycast/scripts/distromac-theme-pick.sh`

- [ ] **Step 1: Remove the file**

Run: `rm config/raycast/scripts/distromac-theme-pick.sh`

- [ ] **Step 2: Check if the raycast/scripts directory is now empty**

Run: `ls config/raycast/scripts/`

If empty, remove the directory too:
Run: `rmdir config/raycast/scripts && rmdir config/raycast`

- [ ] **Step 3: Commit**

```bash
git add -A config/raycast/
git commit -m "feat: remove Raycast theme picker, replaced by distromac-menu"
```

---

### Task 7: Manual smoke test

No files changed — this is a verification step.

- [ ] **Step 1: Verify the full script parses**

Run: `bash -n bin/distromac-menu`
Expected: no output

- [ ] **Step 2: Verify all referenced commands exist in bin/**

Run: `ls bin/distromac-theme-pick bin/distromac-theme-current bin/distromac-theme-set bin/distromac-restart-sketchybar bin/distromac-restart-borders bin/distromac-restart-aerospace bin/distromac-defaults-apply bin/distromac-refresh-config bin/distromac-update bin/distromac-version`
Expected: all files listed, no errors

- [ ] **Step 3: Verify aerospace TOML is valid**

Run: `python3 -c "import tomllib; tomllib.load(open('config/aerospace/aerospace.toml', 'rb')); print('Valid TOML')"`
Expected: `Valid TOML`

- [ ] **Step 4: Test menu launch directly (if on macOS with fzf installed)**

Run: `bin/distromac-menu` and navigate through menus with Escape to verify navigation works. Press Escape at main menu to exit.

- [ ] **Step 5: Final commit if any fixes were needed**

Only if adjustments were made during smoke testing.
