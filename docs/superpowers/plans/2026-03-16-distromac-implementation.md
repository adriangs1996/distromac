# distromac Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a macOS configuration distribution with unified theming, modular installation, and CLI tooling — inspired by omarchy.

**Architecture:** Bash scripts organized in a pipeline (preflight → packaging → config → post-install). Theme system uses `colors.toml` + `.tpl` templates to generate app-specific configs. All CLI tools follow `distromac-*` naming and live in `bin/`. User's actual dotfiles from `~/.config/` are copied into `config/` as the defaults.

**Tech Stack:** Bash, Homebrew, sed (template engine), fzf (theme picker), osascript (wallpaper/macOS integration)

**Spec:** `docs/superpowers/specs/2026-03-16-distromac-design.md`

---

## Chunk 1: Repository Scaffold & Core Utilities

### Task 1: Repository foundation files

**Files:**
- Create: `AGENTS.md`
- Create: `.gitignore`
- Create: `.editorconfig`
- Create: `LICENSE`
- Create: `version`

- [ ] **Step 1: Create AGENTS.md**

```markdown
# AGENTS.md — distromac Coding Standards

## Bash

- Shebang: `#!/usr/bin/env bash`
- Error handling: `set -eEo pipefail`
- Indentation: 2 spaces, no tabs
- Conditionals: `[[ ]]` for strings/files, `(( ))` for numeric
- In `[[ ]]`: don't quote variables, do quote string literals
- Use `(( ))` over `-lt`, `-gt`, etc.
- Paths with spaces: use quotes, not backslash escape

## Naming Convention

All scripts: `distromac-<prefix>-<action>`

Prefixes:
- `theme-` — theme management
- `brew-` / `cask-` — package management
- `refresh-` — reset config to defaults
- `restart-` — restart services/apps
- `defaults-` — macOS defaults
- `hook` — lifecycle hooks
- `migrate` — migrations
- `update` — self-update
- `version` — version info

## Helper Commands

- `distromac-brew-missing` / `distromac-brew-install` — check/install brew packages
- `distromac-cask-missing` / `distromac-cask-install` — check/install casks

## Migration Format

- Named by timestamp: `<unix_timestamp>.sh` or `<timestamp>_description.sh`
- No shebang line (executed with `bash` by `distromac-migrate`)
- Must start with `echo` describing what it does
- Uses `$DISTROMAC_PATH` to reference distromac directory
```

- [ ] **Step 2: Create .gitignore**

```
.DS_Store
*.swp
*.swo
*~
.env
.env.local
node_modules/
```

- [ ] **Step 3: Create .editorconfig**

```ini
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
```

- [ ] **Step 4: Create LICENSE (MIT)**

Use standard MIT license with "Adrian Gonzalez" and year 2026.

- [ ] **Step 5: Create version file**

```
0.1.0
```

- [ ] **Step 6: Commit**

```bash
git add AGENTS.md .gitignore .editorconfig LICENSE version
git commit -m "feat: add repository foundation files"
```

---

### Task 2: Install helpers

**Files:**
- Create: `install/helpers/logging.sh`
- Create: `install/helpers/checks.sh`

- [ ] **Step 1: Create logging.sh**

```bash
# Colored output helpers for the install pipeline
# Source this file, do not execute directly

BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_step() {
  echo -e "\n${PURPLE}${BOLD}==>${NC} ${BOLD}$1${NC}"
}
```

- [ ] **Step 2: Create checks.sh**

```bash
# Utility functions for the install pipeline
# Source this file, do not execute directly

is_macos() {
  [[ $(uname -s) == "Darwin" ]]
}

macos_version() {
  sw_vers -productVersion
}

macos_version_major() {
  sw_vers -productVersion | cut -d. -f1
}

command_exists() {
  command -v "$1" &>/dev/null
}

app_installed() {
  # Check if a macOS .app exists
  [[ -d "/Applications/$1.app" ]] || [[ -d "$HOME/Applications/$1.app" ]]
}
```

- [ ] **Step 3: Verify helpers source without errors**

Run: `bash -c 'source install/helpers/logging.sh && log_info "test" && log_success "ok"'`
Expected: Colored output with [INFO] test and [✓] ok

Run: `bash -c 'source install/helpers/checks.sh && is_macos && echo "yes"'`
Expected: `yes` (on macOS)

- [ ] **Step 4: Commit**

```bash
git add install/helpers/
git commit -m "feat: add install helper utilities (logging, checks)"
```

---

### Task 3: Package management scripts

**Files:**
- Create: `bin/distromac-brew-missing`
- Create: `bin/distromac-brew-install`
- Create: `bin/distromac-cask-missing`
- Create: `bin/distromac-cask-install`
- Create: `bin/distromac-version`

- [ ] **Step 1: Create distromac-brew-missing**

```bash
#!/usr/bin/env bash
set -eEo pipefail

# Returns 0 (true) if ANY of the given brew packages are missing.
# Usage: distromac-brew-missing pkg1 pkg2 ...
# For use in: if distromac-brew-missing bat; then ...

for pkg in "$@"; do
  if ! brew list --formula "$pkg" &>/dev/null; then
    exit 0 # Found missing
  fi
done
exit 1 # All present
```

- [ ] **Step 2: Create distromac-brew-install**

```bash
#!/usr/bin/env bash
set -eEo pipefail

# Install brew formula(s) if not already installed.
# Usage: distromac-brew-install pkg1 pkg2 ...

for pkg in "$@"; do
  if ! brew list --formula "$pkg" &>/dev/null; then
    echo "Installing $pkg..."
    brew install "$pkg"
  fi
done
```

- [ ] **Step 3: Create distromac-cask-missing**

```bash
#!/usr/bin/env bash
set -eEo pipefail

# Returns 0 (true) if ANY of the given casks are missing.
# Usage: distromac-cask-missing app1 app2 ...

for cask in "$@"; do
  if ! brew list --cask "$cask" &>/dev/null; then
    exit 0 # Found missing
  fi
done
exit 1 # All present
```

- [ ] **Step 4: Create distromac-cask-install**

```bash
#!/usr/bin/env bash
set -eEo pipefail

# Install cask(s) if not already installed.
# Usage: distromac-cask-install app1 app2 ...

for cask in "$@"; do
  if ! brew list --cask "$cask" &>/dev/null; then
    echo "Installing $cask..."
    brew install --cask "$cask"
  fi
done
```

- [ ] **Step 5: Create distromac-version**

```bash
#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.local/share/distromac}"
cat "$DISTROMAC_PATH/version"
```

- [ ] **Step 6: Make all scripts executable**

Run: `chmod +x bin/distromac-*`

- [ ] **Step 7: Verify scripts work**

Run: `PATH="$PWD/bin:$PATH" DISTROMAC_PATH="$PWD" distromac-version`
Expected: `0.1.0`

Run: `PATH="$PWD/bin:$PATH" distromac-brew-missing nonexistent-pkg-12345 && echo "missing" || echo "present"`
Expected: `missing`

- [ ] **Step 8: Commit**

```bash
git add bin/
git commit -m "feat: add package management and version scripts"
```

---

### Task 4: Restart and hook scripts

**Files:**
- Create: `bin/distromac-restart-sketchybar`
- Create: `bin/distromac-restart-borders`
- Create: `bin/distromac-restart-aerospace`
- Create: `bin/distromac-hook`

- [ ] **Step 1: Create distromac-restart-sketchybar**

```bash
#!/usr/bin/env bash
set -eEo pipefail

if pgrep -x sketchybar &>/dev/null; then
  brew services restart sketchybar
fi
```

- [ ] **Step 2: Create distromac-restart-borders**

```bash
#!/usr/bin/env bash
set -eEo pipefail

if pgrep -x borders &>/dev/null; then
  brew services restart borders
fi
```

- [ ] **Step 3: Create distromac-restart-aerospace**

```bash
#!/usr/bin/env bash
set -eEo pipefail

if command -v aerospace &>/dev/null; then
  aerospace reload-config
fi
```

- [ ] **Step 4: Create distromac-hook**

```bash
#!/usr/bin/env bash
set -eEo pipefail

# Run a user hook if it exists.
# Usage: distromac-hook <event> [args...]
# Hooks live in ~/.config/distromac/hooks/

event="${1:?Usage: distromac-hook <event> [args...]}"
shift

hook_path="$HOME/.config/distromac/hooks/$event"

if [[ -x $hook_path ]]; then
  exec "$hook_path" "$@"
fi
```

- [ ] **Step 5: Make executable and commit**

```bash
chmod +x bin/distromac-restart-* bin/distromac-hook
git add bin/
git commit -m "feat: add restart and hook scripts"
```

---

## Chunk 2: Theme System

### Task 5: Default theme — catppuccin-mocha colors.toml

**Files:**
- Create: `themes/catppuccin-mocha/colors.toml`

- [ ] **Step 1: Create colors.toml**

```toml
# distromac catppuccin-mocha: base Catppuccin Mocha with custom overrides
accent = "#bb9af7"
cursor = "#f5e0dc"
foreground = "#cdd6f4"
background = "#1e1e2e"
surface0 = "#313244"
surface1 = "#45475a"
mantle = "#181825"
selection_foreground = "#1e1e2e"
selection_background = "#f5e0dc"
green1 = "#4fd6be"

color0 = "#45475a"
color1 = "#f38ba8"
color2 = "#a6e3a1"
color3 = "#f9e2af"
color4 = "#89b4fa"
color5 = "#bb9af7"
color6 = "#94e2d5"
color7 = "#bac2de"
color8 = "#585b70"
color9 = "#f38ba8"
color10 = "#a6e3a1"
color11 = "#f9e2af"
color12 = "#89b4fa"
color13 = "#bb9af7"
color14 = "#94e2d5"
color15 = "#a6adc8"
```

- [ ] **Step 2: Commit**

```bash
git add themes/
git commit -m "feat: add catppuccin-mocha default theme"
```

---

### Task 6: Template engine — distromac-theme-set-templates

**Files:**
- Create: `bin/distromac-theme-set-templates`

- [ ] **Step 1: Create distromac-theme-set-templates**

This is the core engine. Reads `colors.toml`, builds sed substitutions for 3 formats per variable, processes templates.

```bash
#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.local/share/distromac}"
CURRENT_DIR="$HOME/.config/distromac/current"
THEME_DIR="$CURRENT_DIR/next-theme"
COLORS_FILE="$THEME_DIR/colors.toml"

if [[ ! -f $COLORS_FILE ]]; then
  echo "Error: No colors.toml found in $THEME_DIR" >&2
  exit 1
fi

# Build sed script from colors.toml
sed_script=""
while IFS='=' read -r key value; do
  # Skip comments and empty lines
  [[ $key =~ ^[[:space:]]*# ]] && continue
  [[ -z $key ]] && continue

  # Trim whitespace and quotes (do NOT strip # — it's part of hex color values)
  key=$(echo "$key" | xargs)
  value=$(echo "$value" | xargs | sed 's/^"//;s/"$//' | xargs)

  [[ -z $value ]] && continue

  # Full hex: {{ key }}
  sed_script+="s|{{ ${key} }}|${value}|g;"

  # Strip #: {{ key_strip }}
  stripped="${value#\#}"
  sed_script+="s|{{ ${key}_strip }}|${stripped}|g;"

  # RGB decimal: {{ key_rgb }}
  if [[ $value =~ ^# ]]; then
    r=$((16#${stripped:0:2}))
    g=$((16#${stripped:2:2}))
    b=$((16#${stripped:4:2}))
    sed_script+="s|{{ ${key}_rgb }}|${r},${g},${b}|g;"
  fi
done < "$COLORS_FILE"

# Process templates: user overrides first, then built-in
process_templates() {
  local tpl_dir="$1"

  [[ ! -d $tpl_dir ]] && return

  for tpl in "$tpl_dir"/*.tpl; do
    [[ ! -f $tpl ]] && continue

    local filename
    filename=$(basename "$tpl" .tpl)

    # Skip if theme already provides this file (not a template)
    if [[ -f "$THEME_DIR/$filename" ]]; then
      continue
    fi

    sed "$sed_script" "$tpl" > "$THEME_DIR/$filename"
  done
}

# User templates override built-in
process_templates "$HOME/.config/distromac/themed"
process_templates "$DISTROMAC_PATH/default/themed"
```

- [ ] **Step 2: Make executable**

Run: `chmod +x bin/distromac-theme-set-templates`

- [ ] **Step 3: Create a test template to verify**

Create temporary test: `mkdir -p /tmp/distromac-test && echo 'bg={{ background }} fg={{ foreground }} accent_raw={{ accent_strip }}' > /tmp/distromac-test/test.tpl`

Run:
```bash
export DISTROMAC_PATH="$PWD"
mkdir -p ~/.config/distromac/current/next-theme
cp themes/catppuccin-mocha/colors.toml ~/.config/distromac/current/next-theme/
cp /tmp/distromac-test/test.tpl default/themed/ 2>/dev/null || mkdir -p default/themed && cp /tmp/distromac-test/test.tpl default/themed/
PATH="$PWD/bin:$PATH" distromac-theme-set-templates
cat ~/.config/distromac/current/next-theme/test
```

Expected: `bg=#1e1e2e fg=#cdd6f4 accent_raw=bb9af7`

- [ ] **Step 4: Clean up test artifacts and commit**

```bash
rm -f default/themed/test.tpl
rm -rf ~/.config/distromac/current/next-theme
rm -rf /tmp/distromac-test
git add bin/distromac-theme-set-templates
git commit -m "feat: add template engine for theme system"
```

---

### Task 7: Theme templates (.tpl files)

**Files:**
- Create: `default/themed/ghostty.conf.tpl`
- Create: `default/themed/sketchybar-theme.sh.tpl`
- Create: `default/themed/tmux-theme.conf.tpl`
- Create: `default/themed/borders.tpl`
- Create: `default/themed/starship.toml.tpl`
- Create: `default/themed/kitty.conf.tpl`
- Create: `default/themed/lsd-colors.yaml.tpl`

**Note:** These templates must match the structure of the user's actual config files at `~/.config/`. Read the user's current configs to build accurate templates. The key parts that vary by theme are the color values — everything else (fonts, keybindings, behavior settings) stays in the non-templated config in `config/`.

- [ ] **Step 1: Create ghostty.conf.tpl**

Read `~/.config/ghostty/config` to extract the color-related lines. Create a template that only contains theme-sensitive settings (palette, background, foreground, cursor). The main Ghostty config in `config/ghostty/` will `include` this generated file.

Template should contain:
- `palette = 0-15` lines with `{{ color0 }}` through `{{ color15 }}`
- `background = {{ background }}`
- `foreground = {{ foreground }}`
- `cursor-color = {{ cursor }}`
- `selection-background = {{ selection_background }}`
- `selection-foreground = {{ selection_foreground }}`

- [ ] **Step 2: Create sketchybar-theme.sh.tpl**

Read `~/.config/sketchybar/theme/catppuccin.sh` for the exact variable names used. Template exports color variables that sketchybar plugins source:

```bash
#!/usr/bin/env bash
# Auto-generated by distromac-theme-set-templates
export BAR_COLOR=0xff{{ mantle_strip }}
export ITEM_BG_COLOR=0xff{{ surface0_strip }}
export ACCENT_COLOR=0xff{{ accent_strip }}
export TEXT_COLOR=0xff{{ foreground_strip }}
export SUBTEXT_COLOR=0xff{{ surface1_strip }}
export BG_COLOR=0xff{{ background_strip }}
export RED=0xff{{ color1_strip }}
export GREEN=0xff{{ color2_strip }}
export YELLOW=0xff{{ color3_strip }}
export BLUE=0xff{{ color4_strip }}
export PURPLE=0xff{{ color5_strip }}
export TEAL=0xff{{ color6_strip }}
```

- [ ] **Step 3: Create tmux-theme.conf.tpl**

Read `~/.config/tmux/catppuccin.conf` for the tmux status bar color format. Template:

```tmux
# Auto-generated by distromac-theme-set-templates
set -g status-style "bg={{ background }},fg={{ foreground }}"
set -g pane-border-style "fg={{ surface1 }}"
set -g pane-active-border-style "fg={{ color4 }}"
set -g message-style "bg={{ surface0 }},fg={{ foreground }}"
set -g status-left "#[bg={{ color4 }},fg={{ background }},bold] #S #[default] "
set -g status-right "#[fg={{ surface1 }}]%Y-%m-%d #[fg={{ foreground }}]%H:%M "
set -g window-status-current-format "#[bg={{ surface0 }},fg={{ color4 }}] #I:#W "
set -g window-status-format "#[fg={{ surface1 }}] #I:#W "
```

- [ ] **Step 4: Create borders.tpl**

Read `~/.config/borders/bordersrc`. Template:

```bash
#!/usr/bin/env bash
# Auto-generated by distromac-theme-set-templates
options=(
  style=round
  width=6.0
  hidpi=on
  active_color=0xff{{ color4_strip }}
  inactive_color=0xff{{ surface1_strip }}
)
borders "${options[@]}"
```

- [ ] **Step 5: Create starship.toml.tpl**

Read `~/.config/starship.toml` (symlink target). Create template for the `[palettes.catppuccin_mocha]` section that Starship uses. The template replaces the palette color values.

- [ ] **Step 6: Create kitty.conf.tpl**

Standard Kitty color template:

```ini
# Auto-generated by distromac-theme-set-templates
foreground {{ foreground }}
background {{ background }}
cursor {{ cursor }}
selection_foreground {{ selection_foreground }}
selection_background {{ selection_background }}
color0  {{ color0 }}
color1  {{ color1 }}
color2  {{ color2 }}
color3  {{ color3 }}
color4  {{ color4 }}
color5  {{ color5 }}
color6  {{ color6 }}
color7  {{ color7 }}
color8  {{ color8 }}
color9  {{ color9 }}
color10 {{ color10 }}
color11 {{ color11 }}
color12 {{ color12 }}
color13 {{ color13 }}
color14 {{ color14 }}
color15 {{ color15 }}
```

- [ ] **Step 7: Create bat.tpl**

bat uses named themes from its cache. The template generates a `.tmTheme` file (TextMate theme format) with colors from the palette. Alternatively, since bat's theme format is complex, the simpler approach: each `colors.toml` defines which built-in bat theme to use. Create a simple config template:

```
# Auto-generated by distromac-theme-set-templates
--theme="{{ bat_theme }}"
```

Add `bat_theme = "Catppuccin Mocha"` to `colors.toml` (and equivalent for other themes). This avoids generating a full `.tmTheme` and leverages bat's built-in theme support.

- [ ] **Step 8: Create lsd-colors.yaml.tpl**

Read `~/.config/lsd/colors.yaml` for the structure. Template maps file types to theme colors.

- [ ] **Step 9: Commit**

```bash
git add default/themed/
git commit -m "feat: add theme templates for all supported apps"
```

---

### Task 8: distromac-theme-set (main theme command)

**Files:**
- Create: `bin/distromac-theme-set`

- [ ] **Step 1: Create distromac-theme-set**

```bash
#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.local/share/distromac}"
CURRENT_DIR="$HOME/.config/distromac/current"
THEME_NAME="${1:?Usage: distromac-theme-set <theme-name>}"

# 1. Validate theme exists (in at least one location)
OFFICIAL_DIR="$DISTROMAC_PATH/themes/$THEME_NAME"
USER_DIR="$HOME/.config/distromac/themes/$THEME_NAME"

if [[ ! -d $OFFICIAL_DIR ]] && [[ ! -d $USER_DIR ]]; then
  echo "Error: Theme '$THEME_NAME' not found." >&2
  echo "Available themes: $(distromac-theme-list)" >&2
  exit 1
fi

# 2. Create next-theme staging directory
mkdir -p "$CURRENT_DIR"
rm -rf "$CURRENT_DIR/next-theme"
mkdir -p "$CURRENT_DIR/next-theme"

# 3. Copy official theme first (base)
if [[ -d $OFFICIAL_DIR ]]; then
  cp -r "$OFFICIAL_DIR"/. "$CURRENT_DIR/next-theme/"
fi

# 4. Copy user overrides on top (overlay — user wins)
if [[ -d $USER_DIR ]]; then
  cp -r "$USER_DIR"/. "$CURRENT_DIR/next-theme/"
fi

# 5. Generate configs from templates
distromac-theme-set-templates

# 6. Atomic swap
rm -rf "$CURRENT_DIR/theme"
mv "$CURRENT_DIR/next-theme" "$CURRENT_DIR/theme"

# 7. Store theme name
echo "$THEME_NAME" > "$CURRENT_DIR/theme.name"

# 8. Set wallpaper if exists
for wallpaper in "$CURRENT_DIR/theme"/wallpaper.{png,jpg,jpeg}; do
  if [[ -f $wallpaper ]]; then
    osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$wallpaper\""
    break
  fi
done

# 9. Reload all themed components
distromac-restart-sketchybar
distromac-restart-borders
distromac-restart-aerospace

# Ghostty: SIGUSR2 triggers config reload
if pgrep -x ghostty &>/dev/null; then
  pkill -USR2 -x ghostty 2>/dev/null || true
fi

# tmux: source config if running
if tmux list-sessions &>/dev/null 2>&1; then
  tmux source-file ~/.tmux.conf 2>/dev/null || true
fi

# bat: rebuild cache
if command -v bat &>/dev/null; then
  bat cache --build &>/dev/null || true
fi

# 10. Copy nvim.lua override if theme provides one
if [[ -f "$CURRENT_DIR/theme/nvim.lua" ]]; then
  mkdir -p "$HOME/.config/nvim/lua/distromac"
  cp "$CURRENT_DIR/theme/nvim.lua" "$HOME/.config/nvim/lua/distromac/theme.lua"
fi

# 11. Run hook
distromac-hook theme-set "$THEME_NAME" || true

echo "Theme set to: $THEME_NAME"
```

- [ ] **Step 2: Make executable**

Run: `chmod +x bin/distromac-theme-set`

- [ ] **Step 3: Commit**

```bash
git add bin/distromac-theme-set
git commit -m "feat: add distromac-theme-set with full reload pipeline"
```

---

### Task 9: Theme list, current, and picker scripts

**Files:**
- Create: `bin/distromac-theme-list`
- Create: `bin/distromac-theme-current`
- Create: `bin/distromac-theme-pick`

- [ ] **Step 1: Create distromac-theme-list**

```bash
#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.local/share/distromac}"

{
  # List official themes
  for dir in "$DISTROMAC_PATH/themes"/*/; do
    [[ -d $dir ]] && basename "$dir"
  done

  # List user themes
  for dir in "$HOME/.config/distromac/themes"/*/; do
    [[ -d $dir ]] && basename "$dir"
  done
} | sort -u
```

- [ ] **Step 2: Create distromac-theme-current**

```bash
#!/usr/bin/env bash
set -eEo pipefail

theme_file="$HOME/.config/distromac/current/theme.name"

if [[ -f $theme_file ]]; then
  cat "$theme_file"
else
  echo "No theme set"
  exit 1
fi
```

- [ ] **Step 3: Create distromac-theme-pick**

```bash
#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.local/share/distromac}"

# Preview function: render color blocks from colors.toml
preview_theme() {
  local theme="$1"
  local colors_file=""

  if [[ -f "$HOME/.config/distromac/themes/$theme/colors.toml" ]]; then
    colors_file="$HOME/.config/distromac/themes/$theme/colors.toml"
  elif [[ -f "$DISTROMAC_PATH/themes/$theme/colors.toml" ]]; then
    colors_file="$DISTROMAC_PATH/themes/$theme/colors.toml"
  fi

  if [[ -z $colors_file ]]; then
    echo "No colors.toml found"
    return
  fi

  while IFS='=' read -r key value; do
    [[ $key =~ ^[[:space:]]*# ]] && continue
    [[ -z $key ]] && continue

    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs | sed 's/^"//;s/"$//' | xargs)
    [[ -z $value ]] && continue

    # Convert hex to ANSI true color
    local hex="${value#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    printf "\033[48;2;%d;%d;%dm  ████  \033[0m  %-25s %s\n" "$r" "$g" "$b" "$key" "$value"
  done < "$colors_file"
}

export -f preview_theme
export DISTROMAC_PATH

selected=$(distromac-theme-list | fzf \
  --preview "bash -c 'preview_theme {}'" \
  --preview-window=right:50% \
  --header="Select a theme (Enter to apply, Esc to cancel)" \
  --prompt="Theme > ")

if [[ -n $selected ]]; then
  distromac-theme-set "$selected"
fi
```

- [ ] **Step 4: Make executable and verify**

```bash
chmod +x bin/distromac-theme-list bin/distromac-theme-current bin/distromac-theme-pick
```

Run: `PATH="$PWD/bin:$PATH" DISTROMAC_PATH="$PWD" distromac-theme-list`
Expected: `catppuccin-mocha`

- [ ] **Step 5: Commit**

```bash
git add bin/distromac-theme-list bin/distromac-theme-current bin/distromac-theme-pick
git commit -m "feat: add theme list, current, and fzf picker"
```

---

### Task 10: Raycast theme picker script command

**Files:**
- Create: `config/raycast/scripts/distromac-theme-pick.sh`

- [ ] **Step 1: Create Raycast Script Command**

```bash
#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Pick Theme
# @raycast.mode compact
# @raycast.packageName distromac

# Optional parameters:
# @raycast.icon 🎨
# @raycast.argument1 { "type": "dropdown", "placeholder": "Theme", "data": [] }

# Documentation:
# @raycast.description Select and apply a distromac theme
# @raycast.author Adrian Gonzalez

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.local/share/distromac}"
export PATH="$DISTROMAC_PATH/bin:$PATH"

theme="$1"

if [[ -z $theme ]]; then
  echo "No theme selected"
  exit 1
fi

distromac-theme-set "$theme"
echo "Theme set to: $theme"
```

**Note:** Raycast Script Commands with dropdown arguments require the data to be static in the script header OR use Raycast's Script Command API. Since themes are dynamic, an alternative approach is to use `mode: fullOutput` and list themes, or create a Raycast extension. For v1, a simpler approach: use `mode: silent` with an argument that the user types (theme name). The dropdown data array can be populated by a build step during install.

- [ ] **Step 2: Make executable and commit**

```bash
chmod +x config/raycast/scripts/distromac-theme-pick.sh
git add config/raycast/
git commit -m "feat: add Raycast Script Command for theme picker"
```

---

## Chunk 3: macOS Defaults & Config Scripts

### Task 11: macOS defaults scripts

**Files:**
- Create: `default/macos/dock.sh`
- Create: `default/macos/finder.sh`
- Create: `default/macos/keyboard.sh`
- Create: `default/macos/trackpad.sh`
- Create: `default/macos/screenshots.sh`
- Create: `default/macos/misc.sh`

- [ ] **Step 1: Create dock.sh**

```bash
# macOS Dock defaults
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.4
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock mineffect -string "scale"
killall Dock
```

- [ ] **Step 2: Create finder.sh**

```bash
# macOS Finder defaults
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder _FXSortFoldersFirst -bool true
killall Finder
```

- [ ] **Step 3: Create keyboard.sh**

```bash
# macOS Keyboard defaults
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Caps Lock → Ctrl via hidutil (works across all connected keyboards)
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}'

# Persist across reboots via LaunchAgent
mkdir -p ~/Library/LaunchAgents
cat > ~/Library/LaunchAgents/com.distromac.capslock-ctrl.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.distromac.capslock-ctrl</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/hidutil</string>
    <string>property</string>
    <string>--set</string>
    <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
PLIST
```

- [ ] **Step 4: Create trackpad.sh**

```bash
# macOS Trackpad defaults
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true
```

- [ ] **Step 5: Create screenshots.sh**

```bash
# macOS Screenshots defaults
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
killall SystemUIServer 2>/dev/null || true
```

- [ ] **Step 6: Create misc.sh**

```bash
# macOS Misc defaults
# Disable startup sound
sudo nvram SystemAudioVolume=" " 2>/dev/null || true

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Disable "Are you sure you want to open this application?"
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Autohide native menu bar (replaced by Sketchybar)
defaults write NSGlobalDomain _HIHideMenuBar -bool true
```

- [ ] **Step 7: Commit**

```bash
git add default/macos/
git commit -m "feat: add macOS defaults (dock, finder, keyboard, trackpad, screenshots, misc)"
```

---

### Task 12: distromac-defaults-apply and distromac-refresh-config

**Files:**
- Create: `bin/distromac-defaults-apply`
- Create: `bin/distromac-refresh-config`

- [ ] **Step 1: Create distromac-defaults-apply**

```bash
#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.local/share/distromac}"

echo "Applying macOS defaults..."

for script in "$DISTROMAC_PATH/default/macos"/*.sh; do
  [[ ! -f $script ]] && continue
  echo "  → $(basename "$script" .sh)"
  bash "$script"
done

echo "Done. Some changes may require a logout/restart to take effect."
```

- [ ] **Step 2: Create distromac-refresh-config**

```bash
#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.local/share/distromac}"

# Reset a config file to its default.
# Usage: distromac-refresh-config <relative-path>
# Example: distromac-refresh-config ghostty/config

config_path="${1:?Usage: distromac-refresh-config <relative-path>}"
source_file="$DISTROMAC_PATH/config/$config_path"
target_file="$HOME/.config/$config_path"

if [[ ! -f $source_file ]]; then
  echo "Error: No default config found at $source_file" >&2
  exit 1
fi

# Backup existing
if [[ -f $target_file ]]; then
  backup="${target_file}.distromac-backup.$(date +%s)"
  cp "$target_file" "$backup"
  echo "Backed up to: $backup"
fi

# Copy default
mkdir -p "$(dirname "$target_file")"
cp "$source_file" "$target_file"

echo "Refreshed: $config_path"
```

- [ ] **Step 3: Make executable and commit**

```bash
chmod +x bin/distromac-defaults-apply bin/distromac-refresh-config
git add bin/distromac-defaults-apply bin/distromac-refresh-config
git commit -m "feat: add defaults-apply and refresh-config commands"
```

---

### Task 13: Migration system

**Files:**
- Create: `bin/distromac-migrate`
- Create: `migrations/.gitkeep`

- [ ] **Step 1: Create distromac-migrate**

```bash
#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.local/share/distromac}"
STATE_DIR="$HOME/.local/state/distromac/migrations"
SKIP_DIR="$STATE_DIR/skipped"

mkdir -p "$STATE_DIR" "$SKIP_DIR"

for migration in "$DISTROMAC_PATH/migrations"/*.sh; do
  [[ ! -f $migration ]] && continue

  name=$(basename "$migration")

  # Skip if already run or skipped
  [[ -f "$STATE_DIR/$name" ]] && continue
  [[ -f "$SKIP_DIR/$name" ]] && continue

  echo "Running migration: $name"
  if bash "$migration"; then
    touch "$STATE_DIR/$name"
    echo "  ✓ Done"
  else
    echo "  ✗ Migration failed: $name"
    read -rp "  Skip this migration? [y/N] " answer
    if [[ $answer == [yY] ]]; then
      touch "$SKIP_DIR/$name"
      echo "  Skipped."
    else
      echo "  Aborting."
      exit 1
    fi
  fi
done
```

- [ ] **Step 2: Create .gitkeep and make executable**

```bash
touch migrations/.gitkeep
chmod +x bin/distromac-migrate
```

- [ ] **Step 3: Commit**

```bash
git add bin/distromac-migrate migrations/.gitkeep
git commit -m "feat: add migration system"
```

---

### Task 14: distromac-update

**Files:**
- Create: `bin/distromac-update`

- [ ] **Step 1: Create distromac-update**

```bash
#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.local/share/distromac}"

echo "Updating distromac..."

# Pull latest
cd "$DISTROMAC_PATH"
git pull --rebase

# Run pending migrations
distromac-migrate

# Re-apply current theme (regenerates templates with potentially new templates)
current_theme=$(distromac-theme-current 2>/dev/null || echo "")
if [[ -n $current_theme ]] && [[ $current_theme != "No theme set" ]]; then
  echo "Re-applying theme: $current_theme"
  distromac-theme-set "$current_theme"
fi

# Run hook
distromac-hook post-update || true

echo "distromac updated to $(distromac-version)"
```

- [ ] **Step 2: Make executable and commit**

```bash
chmod +x bin/distromac-update
git add bin/distromac-update
git commit -m "feat: add distromac-update command"
```

---

## Chunk 4: Installation Pipeline

### Task 15: Preflight scripts

**Files:**
- Create: `install/preflight/guard.sh`
- Create: `install/preflight/xcode.sh`
- Create: `install/preflight/homebrew.sh`

- [ ] **Step 1: Create guard.sh**

```bash
# Verify we're on macOS Sonoma (14.0) or later
source "$DISTROMAC_PATH/install/helpers/logging.sh"
source "$DISTROMAC_PATH/install/helpers/checks.sh"

log_step "Preflight checks"

if ! is_macos; then
  log_error "distromac requires macOS. Detected: $(uname -s)"
  exit 1
fi

major=$(macos_version_major)
if (( major < 14 )); then
  log_error "distromac requires macOS Sonoma (14.0) or later. Detected: $(macos_version)"
  exit 1
fi

log_success "macOS $(macos_version) — OK"
```

- [ ] **Step 2: Create xcode.sh**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
  log_success "Already installed"
else
  log_info "Installing Xcode Command Line Tools..."
  xcode-select --install
  log_info "Waiting for installation to complete..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  log_success "Installed"
fi
```

- [ ] **Step 3: Create homebrew.sh**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Homebrew"

if command -v brew &>/dev/null; then
  log_success "Already installed"
else
  log_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to path for the rest of this session
  eval "$(/opt/homebrew/bin/brew shellenv)"
  log_success "Installed"
fi
```

- [ ] **Step 4: Commit**

```bash
git add install/preflight/
git commit -m "feat: add preflight checks (guard, xcode, homebrew)"
```

---

### Task 16: Packaging scripts

**Files:**
- Create: `install/packaging/brews.sh`
- Create: `install/packaging/casks.sh`
- Create: `install/packaging/fonts.sh`
- Create: `install/packaging/languages.sh`
- Create: `install/packaging/npm.sh`

- [ ] **Step 1: Create brews.sh**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "CLI Tools (Homebrew)"

# Always-install CLI tools
core_brews=(bat lsd starship fzf ripgrep fd jq git gh)

for pkg in "${core_brews[@]}"; do
  distromac-brew-install "$pkg"
done

# Optional brews gated by --no-<app> flags
[[ ${DISTROMAC_NO_NVIM} != "1" ]]       && distromac-brew-install neovim
[[ ${DISTROMAC_NO_TMUX} != "1" ]]       && distromac-brew-install tmux
[[ ${DISTROMAC_NO_SKETCHYBAR} != "1" ]] && distromac-brew-install sketchybar
[[ ${DISTROMAC_NO_BORDERS} != "1" ]]    && distromac-brew-install borders
[[ ${DISTROMAC_NO_AEROSPACE} != "1" ]]  && distromac-brew-install aerospace

log_success "CLI tools installed"
```

- [ ] **Step 2: Create casks.sh**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "GUI Apps (Homebrew Casks)"

# Always-install casks
distromac-cask-install google-chrome

# Optional casks gated by --no-<app> flags
[[ ${DISTROMAC_NO_GHOSTTY} != "1" ]]  && distromac-cask-install ghostty
[[ ${DISTROMAC_NO_RAYCAST} != "1" ]]  && distromac-cask-install raycast
[[ ${DISTROMAC_NO_SPOTIFY} != "1" ]]  && distromac-cask-install spotify
[[ ${DISTROMAC_NO_KITTY} != "1" ]]    && distromac-cask-install kitty

log_success "GUI apps installed"
```

- [ ] **Step 3: Create fonts.sh**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Fonts"

fonts=(
  font-jetbrains-mono-nerd-font
  font-cascadia-code-nerd-font
)

for font in "${fonts[@]}"; do
  distromac-cask-install "$font"
done

log_success "Fonts installed"
```

- [ ] **Step 4: Create languages.sh**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Language managers"

# rbenv (Ruby)
distromac-brew-install rbenv ruby-build
log_success "rbenv installed"

# uv (Python)
distromac-brew-install uv
log_success "uv installed"

# nvm (Node)
if [[ ! -d "$HOME/.nvm" ]]; then
  log_info "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  log_success "nvm installed"
else
  log_success "nvm already installed"
fi

# bun
if ! command -v bun &>/dev/null; then
  log_info "Installing bun..."
  curl -fsSL https://bun.sh/install | bash
  log_success "bun installed"
else
  log_success "bun already installed"
fi

# Rust/Cargo
if ! command -v rustup &>/dev/null; then
  log_info "Installing rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  log_success "rustup installed"
else
  log_success "rustup already installed"
fi
```

- [ ] **Step 5: Create npm.sh (placeholder)**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Global npm packages"

# Add global npm packages here as needed
# Example: npm install -g typescript

log_success "npm packages installed"
```

- [ ] **Step 6: Commit**

```bash
git add install/packaging/
git commit -m "feat: add packaging scripts (brews, casks, fonts, languages, npm)"
```

---

### Task 17: Config pipeline scripts

**Files:**
- Create: `install/config/shell.sh`
- Create: `install/config/git.sh`
- Create: `install/config/dotfiles.sh`
- Create: `install/config/macos-defaults.sh`
- Create: `install/config/theme.sh`

- [ ] **Step 1: Create shell.sh**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Shell configuration"

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log_info "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  log_success "Oh My Zsh installed"
else
  log_success "Oh My Zsh already installed"
fi

# Plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-vi-mode" ]]; then
  git clone https://github.com/jeffreytse/zsh-vi-mode "$ZSH_CUSTOM/plugins/zsh-vi-mode"
fi

log_success "Shell plugins installed"
```

- [ ] **Step 2: Create git.sh**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Git configuration"

# Set basic git config if not already set
if [[ -z $(git config --global user.name) ]]; then
  log_warn "Git user.name not set. Set it with: git config --global user.name 'Your Name'"
fi

if [[ -z $(git config --global user.email) ]]; then
  log_warn "Git user.email not set. Set it with: git config --global user.email 'you@example.com'"
fi

# Copy git ignore config
mkdir -p "$HOME/.config/git"
if [[ -f "$DISTROMAC_PATH/config/git/ignore" ]]; then
  cp "$DISTROMAC_PATH/config/git/ignore" "$HOME/.config/git/ignore"
fi

log_success "Git configured"
```

- [ ] **Step 3: Create dotfiles.sh**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Dotfiles"

TIMESTAMP=$(date +%s)

# List of config directories to install
configs=(
  aerospace
  ghostty
  nvim
  sketchybar
  tmux
  starship
  bat
  borders
  lsd
  raycast
  kitty
  karabiner
  zellij
)

for app in "${configs[@]}"; do
  # Check if excluded via --no-<app> flag
  flag_var="DISTROMAC_NO_$(echo "$app" | tr '[:lower:]' '[:upper:]')"
  if [[ ${!flag_var} == "1" ]]; then
    log_info "Skipping $app (excluded)"
    continue
  fi

  source_dir="$DISTROMAC_PATH/config/$app"
  target_dir="$HOME/.config/$app"

  if [[ ! -d $source_dir ]]; then
    continue
  fi

  # Backup existing
  if [[ -d $target_dir ]]; then
    backup="${target_dir}.distromac-backup.${TIMESTAMP}"
    mv "$target_dir" "$backup"
    log_info "Backed up $app → $(basename "$backup")"
  fi

  # Copy
  cp -r "$source_dir" "$target_dir"
  log_success "$app configured"
done

# Handle .zshrc separately (lives in $HOME, not ~/.config/)
if [[ -f "$DISTROMAC_PATH/config/zsh/.zshrc" ]]; then
  if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.distromac-backup.${TIMESTAMP}"
    log_info "Backed up .zshrc"
  fi
  cp "$DISTROMAC_PATH/config/zsh/.zshrc" "$HOME/.zshrc"
  log_success ".zshrc configured"
fi

# Handle .tmux.conf (lives in $HOME)
if [[ -f "$DISTROMAC_PATH/config/tmux/.tmux.conf" ]]; then
  if [[ -f "$HOME/.tmux.conf" ]]; then
    cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.distromac-backup.${TIMESTAMP}"
  fi
  cp "$DISTROMAC_PATH/config/tmux/.tmux.conf" "$HOME/.tmux.conf"
  log_success ".tmux.conf configured"
fi
```

- [ ] **Step 4: Create macos-defaults.sh**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "macOS Defaults"

if [[ ${DISTROMAC_NO_DEFAULTS} == "1" ]]; then
  log_info "Skipping macOS defaults (excluded)"
  return 0
fi

distromac-defaults-apply
```

- [ ] **Step 5: Create theme.sh**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Theme"

theme="${DISTROMAC_THEME:-catppuccin-mocha}"
log_info "Setting theme: $theme"
distromac-theme-set "$theme"
log_success "Theme applied: $theme"
```

- [ ] **Step 6: Commit**

```bash
git add install/config/
git commit -m "feat: add config pipeline (shell, git, dotfiles, defaults, theme)"
```

---

### Task 18: Post-install and main install.sh

**Files:**
- Create: `install/post-install/cleanup.sh`
- Create: `install.sh`
- Create: `boot.sh`

- [ ] **Step 1: Create cleanup.sh**

```bash
source "$DISTROMAC_PATH/install/helpers/logging.sh"

log_step "Post-install"

echo ""
echo -e "${BOLD}════════════════════════════════════════${NC}"
echo -e "${BOLD}  distromac installed successfully! 🎉  ${NC}"
echo -e "${BOLD}════════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "  1. Grant Accessibility permissions to Aerospace and Sketchybar:"
echo "     System Settings → Privacy & Security → Accessibility"
echo ""
echo "  2. Set recommended Raycast hotkey for theme picker:"
echo "     Raycast → Script Commands → Pick Theme → Set Ctrl+T"
echo ""
echo "  3. Restart your terminal or run: source ~/.zshrc"
echo ""
echo "  4. Some macOS defaults may require a logout/restart."
echo ""
echo "Commands:"
echo "  distromac-theme-pick    — change theme (fzf picker)"
echo "  distromac-theme-list    — list available themes"
echo "  distromac-update        — update distromac"
echo "  distromac-version       — show version"
echo ""
```

- [ ] **Step 2: Create install.sh**

```bash
#!/usr/bin/env bash
set -eEo pipefail

# distromac installer
# Usage: ./install.sh [--no-<app>] [--theme=<name>] [--no-defaults] [--no-fonts] [--no-languages] [--minimal]

export DISTROMAC_PATH="${DISTROMAC_PATH:-$(cd "$(dirname "$0")" && pwd)}"
export PATH="$DISTROMAC_PATH/bin:$PATH"

# Parse flags
export DISTROMAC_THEME="catppuccin-mocha"

for arg in "$@"; do
  case "$arg" in
    --no-nvim)       export DISTROMAC_NO_NVIM=1 ;;
    --no-sketchybar) export DISTROMAC_NO_SKETCHYBAR=1 ;;
    --no-aerospace)  export DISTROMAC_NO_AEROSPACE=1 ;;
    --no-tmux)       export DISTROMAC_NO_TMUX=1 ;;
    --no-ghostty)    export DISTROMAC_NO_GHOSTTY=1 ;;
    --no-borders)    export DISTROMAC_NO_BORDERS=1 ;;
    --no-raycast)    export DISTROMAC_NO_RAYCAST=1 ;;
    --no-spotify)    export DISTROMAC_NO_SPOTIFY=1 ;;
    --no-kitty)      export DISTROMAC_NO_KITTY=1 ;;
    --no-karabiner)  export DISTROMAC_NO_KARABINER=1 ;;
    --no-zellij)     export DISTROMAC_NO_ZELLIJ=1 ;;
    --no-defaults)   export DISTROMAC_NO_DEFAULTS=1 ;;
    --no-fonts)      export DISTROMAC_NO_FONTS=1 ;;
    --no-languages)  export DISTROMAC_NO_LANGUAGES=1 ;;
    --minimal)
      export DISTROMAC_NO_NVIM=1
      export DISTROMAC_NO_SKETCHYBAR=1
      export DISTROMAC_NO_AEROSPACE=1
      export DISTROMAC_NO_TMUX=1
      export DISTROMAC_NO_GHOSTTY=1
      export DISTROMAC_NO_BORDERS=1
      export DISTROMAC_NO_RAYCAST=1
      export DISTROMAC_NO_SPOTIFY=1
      export DISTROMAC_NO_KITTY=1
      export DISTROMAC_NO_KARABINER=1
      export DISTROMAC_NO_ZELLIJ=1
      export DISTROMAC_NO_DEFAULTS=1
      export DISTROMAC_NO_FONTS=1
      export DISTROMAC_NO_LANGUAGES=1
      ;;
    --theme=*) export DISTROMAC_THEME="${arg#--theme=}" ;;
    *)
      echo "Unknown flag: $arg" >&2
      echo "Usage: ./install.sh [--no-<app>] [--theme=<name>] [--no-defaults] [--no-fonts] [--no-languages] [--minimal]" >&2
      exit 1
      ;;
  esac
done

echo ""
echo "  ╔══════════════════════════════╗"
echo "  ║        d i s t r o m a c     ║"
echo "  ╚══════════════════════════════╝"
echo ""

# 1. Preflight
source "$DISTROMAC_PATH/install/preflight/guard.sh"
source "$DISTROMAC_PATH/install/preflight/xcode.sh"
source "$DISTROMAC_PATH/install/preflight/homebrew.sh"

# 2. Packaging
source "$DISTROMAC_PATH/install/packaging/brews.sh"
source "$DISTROMAC_PATH/install/packaging/casks.sh"

if [[ ${DISTROMAC_NO_FONTS} != "1" ]]; then
  source "$DISTROMAC_PATH/install/packaging/fonts.sh"
fi

if [[ ${DISTROMAC_NO_LANGUAGES} != "1" ]]; then
  source "$DISTROMAC_PATH/install/packaging/languages.sh"
fi

if [[ ${DISTROMAC_NO_LANGUAGES} != "1" ]]; then
  source "$DISTROMAC_PATH/install/packaging/npm.sh"
fi

# 3. Config
source "$DISTROMAC_PATH/install/config/shell.sh"
source "$DISTROMAC_PATH/install/config/git.sh"
source "$DISTROMAC_PATH/install/config/dotfiles.sh"
source "$DISTROMAC_PATH/install/config/macos-defaults.sh"
source "$DISTROMAC_PATH/install/config/theme.sh"

# 4. Post-install
source "$DISTROMAC_PATH/install/post-install/cleanup.sh"
```

- [ ] **Step 3: Create boot.sh**

```bash
#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_REPO="${DISTROMAC_REPO:-adriangs1996/distromac}"
DISTROMAC_BRANCH="${DISTROMAC_BRANCH:-main}"
export DISTROMAC_PATH="${HOME}/.local/share/distromac"

echo "Installing distromac..."

if [[ -d "$DISTROMAC_PATH" ]]; then
  echo "Updating existing installation..."
  cd "$DISTROMAC_PATH"
  git pull --rebase
else
  echo "Cloning distromac..."
  git clone -b "$DISTROMAC_BRANCH" "https://github.com/${DISTROMAC_REPO}.git" "$DISTROMAC_PATH"
fi

cd "$DISTROMAC_PATH"
exec bash install.sh "$@"
```

- [ ] **Step 4: Make executable and commit**

```bash
chmod +x install.sh boot.sh
git add install.sh boot.sh install/post-install/
git commit -m "feat: add main installer, boot.sh, and post-install cleanup"
```

---

## Chunk 5: Copy User's Dotfiles

### Task 19: Copy actual dotfiles from ~/.config/

This is the most important task — it copies the user's real configs into `config/` so they become the distromac defaults. This must be done manually with the user's actual files.

**Files:**
- Create: `config/aerospace/` (copy from `~/.config/aerospace/`)
- Create: `config/ghostty/` (copy from `~/.config/ghostty/`)
- Create: `config/nvim/` (copy from `~/.config/nvim/`)
- Create: `config/sketchybar/` (copy from `~/.config/sketchybar/`)
- Create: `config/tmux/` (copy from `~/.config/tmux/` and `~/.tmux.conf`)
- Create: `config/starship/` (copy starship.toml content, not symlink)
- Create: `config/bat/` (copy from `~/.config/bat/`)
- Create: `config/borders/` (copy from `~/.config/borders/`)
- Create: `config/lsd/` (copy from `~/.config/lsd/`)
- Create: `config/kitty/` (copy from `~/.config/kitty/`)
- Create: `config/karabiner/` (copy from `~/.config/karabiner/`)
- Create: `config/zellij/` (copy from `~/.config/zellij/`)
- Create: `config/zsh/.zshrc` (copy from `~/.zshrc`)
- Create: `config/raycast/scripts/` (theme picker script already created)
- Create: `config/git/ignore`

**Important considerations:**
- Resolve all symlinks (e.g., starship.toml → copy actual content, not link)
- Remove any personal secrets, tokens, or machine-specific paths
- In `.zshrc`: replace hardcoded paths with `$DISTROMAC_PATH` and `$HOME`
- In `.zshrc`: add `export DISTROMAC_PATH="$HOME/.local/share/distromac"` and `export PATH="$DISTROMAC_PATH/bin:$PATH"`
- Ghostty config: split into main config (static settings like font, padding) + themed part that gets generated from template. Main config should `include` the themed file.
- Sketchybar: ensure it sources `~/.config/distromac/current/theme/sketchybar-theme.sh` for colors
- tmux: ensure it sources `~/.config/distromac/current/theme/tmux-theme.conf`
- Borders: ensure it sources `~/.config/distromac/current/theme/borders` for colors
- Neovim: add autocmd that watches `~/.config/distromac/current/theme.name` and reloads colorscheme

- [ ] **Step 1: Copy each config directory**

For each app listed above:
1. Copy the directory from `~/.config/<app>/` to `config/<app>/`
2. Review for secrets or machine-specific paths
3. Adjust any hardcoded paths

- [ ] **Step 2: Modify Ghostty config to split static + themed**

The main `config/ghostty/config` keeps font, padding, behavior settings. Add at the end:
```
# Theme colors (auto-generated by distromac)
config-file = /Users/{HOME}/.config/distromac/current/theme/ghostty.conf
```
Wait — Ghostty doesn't support `$HOME` expansion in config-file. Use a relative path or handle via the template system. Alternative: the template generates the FULL ghostty color block and the main config includes it via Ghostty's `config-file` directive with an absolute path. During install, `dotfiles.sh` will sed-replace the path placeholder.

- [ ] **Step 3: Modify Sketchybar to source themed colors**

In the sketchybar config, ensure the theme file is sourced:
```bash
source "$HOME/.config/distromac/current/theme/sketchybar-theme.sh"
```

- [ ] **Step 4: Modify tmux to source themed colors**

In `.tmux.conf` or `config/tmux/tmux.conf`, add:
```
source-file ~/.config/distromac/current/theme/tmux-theme.conf
```

- [ ] **Step 5: Add Neovim autocmd for theme auto-reload**

Create `config/nvim/lua/distromac/init.lua`:
```lua
-- Watch for theme changes and auto-reload colorscheme
local theme_file = vim.fn.expand("~/.config/distromac/current/theme.name")

local function load_distromac_theme()
  local ok, theme_lua = pcall(require, "distromac.theme")
  if ok and theme_lua and theme_lua.colorscheme then
    vim.cmd.colorscheme(theme_lua.colorscheme)
  end
end

-- Watch theme.name for changes
local w = vim.uv.new_fs_event()
if w then
  w:start(theme_file, {}, vim.schedule_wrap(function()
    load_distromac_theme()
  end))
end

-- Load on startup
load_distromac_theme()
```

Create `themes/catppuccin-mocha/nvim.lua` with the user's custom catppuccin overrides (this file gets copied to `~/.config/nvim/lua/distromac/theme.lua` by `distromac-theme-set`):
```lua
return {
  colorscheme = "catppuccin-mocha",
}
```
The actual Catppuccin color_overrides stay in the nvim catppuccin plugin config (already in `config/nvim/`).

- [ ] **Step 6: Create .zshrc with DISTROMAC_PATH**

Copy `~/.zshrc` to `config/zsh/.zshrc` and add near the top:
```bash
# distromac
export DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.local/share/distromac}"
export PATH="$DISTROMAC_PATH/bin:$PATH"
```

- [ ] **Step 7: Commit all dotfiles**

```bash
git add config/
git commit -m "feat: add user dotfiles as distromac defaults"
```

---

### Task 20: Create additional theme skeletons

**Files:**
- Create: `themes/tokyo-night/colors.toml`
- Create: `themes/gruvbox/colors.toml`
- Create: `themes/nord/colors.toml`
- Create: `themes/rose-pine/colors.toml`
- Create: `themes/dracula/colors.toml`

- [ ] **Step 1: Create tokyo-night/colors.toml**

Use the standard Tokyo Night palette, extended with `surface0`, `surface1`, `mantle`, and `green1` fields.

- [ ] **Step 2: Create gruvbox/colors.toml**

Standard Gruvbox Dark palette with distromac extensions.

- [ ] **Step 3: Create nord/colors.toml**

Standard Nord palette with distromac extensions.

- [ ] **Step 4: Create rose-pine/colors.toml**

Standard Rose Pine palette with distromac extensions.

- [ ] **Step 5: Create dracula/colors.toml**

Standard Dracula palette with distromac extensions.

- [ ] **Step 6: Commit**

```bash
git add themes/
git commit -m "feat: add additional theme palettes (tokyo-night, gruvbox, nord, rose-pine, dracula)"
```

---

## Chunk 6: Final Polish

### Task 21: README.md

**Files:**
- Create: `README.md`

- [ ] **Step 1: Create README.md**

Include:
- Project description (one-liner)
- Screenshot/preview placeholder
- Quick install command (`curl | bash`)
- What's included (stack table)
- Flags reference
- Theme system overview
- How to create custom themes
- Commands reference
- How to customize
- License

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "feat: add README"
```

---

### Task 22: GitHub issue templates

**Files:**
- Create: `.github/ISSUE_TEMPLATE/bug.yml`
- Create: `.github/ISSUE_TEMPLATE/config.yml`

- [ ] **Step 1: Create bug report template**

Standard bug report template with:
- macOS version
- distromac version
- Steps to reproduce
- Expected vs actual behavior

- [ ] **Step 2: Create config.yml**

```yaml
blank_issues_enabled: true
```

- [ ] **Step 3: Commit**

```bash
git add .github/
git commit -m "feat: add GitHub issue templates"
```

---

### Task 23: Final verification

- [ ] **Step 1: Verify repo structure matches spec**

Run: `find . -not -path './.git/*' -not -path './.git' | sort`

Compare against the directory structure in the spec.

- [ ] **Step 2: Verify all bin scripts are executable**

Run: `ls -la bin/`

All files should have `+x` permission.

- [ ] **Step 3: Verify install.sh runs (dry check)**

Run: `bash -n install.sh` (syntax check only)
Expected: No errors

- [ ] **Step 4: Verify template engine works end-to-end**

Run a full theme-set with the catppuccin-mocha theme and check generated files.

- [ ] **Step 5: Tag initial release**

```bash
git tag v0.1.0
```
