# distromac — Design Spec

**Date:** 2026-03-16
**Status:** Approved
**Author:** Adrian Gonzalez + Claude

## Overview

distromac is a macOS configuration distribution inspired by [omarchy](https://github.com/basecamp/omarchy). It packages a complete, opinionated Mac developer environment into a single installable repo with a unified theming system, modular installation, and easy extensibility.

**Default config:** Adrian's personal setup (Catppuccin Mocha, Ghostty, Neovim, Aerospace, Sketchybar).
**Customization:** Users can override defaults via flags, custom themes, and direct config edits.
**Minimum macOS version:** Sonoma (14.0) — required by Aerospace, Sketchybar, and JankyBorders.
**Canonical path:** `$DISTROMAC_PATH` defaults to `~/.local/share/distromac`. Exported in `.zshrc` and used by all scripts.

## Core Stack (Defaults)

| Category | Tool |
|----------|------|
| Terminal | Ghostty |
| Shell | zsh + Oh My Zsh + Starship |
| Editor | Neovim (LazyVim) |
| Browser | Google Chrome |
| Package Manager | Homebrew |
| Window Manager | Aerospace (tiling auto) |
| Status Bar | Sketchybar (replaces native menu bar) |
| Launcher | Raycast |
| Music | Spotify |
| Multiplexer | tmux |
| Window Borders | JankyBorders |
| Languages | rbenv (Ruby), uv (Python), nvm (Node), bun, cargo (Rust) |

## Directory Structure

```
distromac/
├── AGENTS.md                          # Coding standards & conventions
├── LICENSE                            # MIT
├── README.md                          # Installation & docs
├── version                            # 0.1.0
├── install.sh                         # Entry point (local install)
├── boot.sh                            # Online bootstrap (curl)
│
├── bin/                               # CLI scripts: distromac-*
│   ├── distromac-theme-set
│   ├── distromac-theme-list
│   ├── distromac-theme-current
│   ├── distromac-theme-pick
│   ├── distromac-theme-set-templates
│   ├── distromac-brew-missing
│   ├── distromac-brew-install
│   ├── distromac-cask-missing
│   ├── distromac-cask-install
│   ├── distromac-refresh-config
│   ├── distromac-defaults-apply
│   ├── distromac-restart-sketchybar
│   ├── distromac-restart-borders
│   ├── distromac-restart-aerospace
│   ├── distromac-hook
│   ├── distromac-migrate
│   ├── distromac-update
│   └── distromac-version
│
├── install/                           # Installation pipeline
│   ├── helpers/
│   │   ├── logging.sh               # Colored output, progress indicators
│   │   └── checks.sh                # Utility functions (is_installed, etc.)
│   ├── preflight/
│   │   ├── guard.sh                 # Verify macOS, minimum version
│   │   ├── xcode.sh                 # Install Xcode Command Line Tools
│   │   └── homebrew.sh              # Install Homebrew
│   ├── packaging/
│   │   ├── brews.sh                 # CLI tools
│   │   ├── casks.sh                 # GUI apps
│   │   ├── fonts.sh                 # Nerd Fonts
│   │   ├── languages.sh            # rbenv, uv, nvm, bun, cargo
│   │   └── npm.sh                   # Global npm packages
│   ├── config/
│   │   ├── shell.sh                 # zsh + oh-my-zsh + plugins
│   │   ├── git.sh                   # Git config
│   │   ├── dotfiles.sh             # Copy configs to ~/.config/
│   │   ├── macos-defaults.sh       # Apply defaults write
│   │   └── theme.sh                 # Apply default theme
│   └── post-install/
│       └── cleanup.sh               # Welcome message, restart notice
│
├── config/                            # Dotfiles by app (copied to ~/.config/)
│   ├── aerospace/                    # Core
│   ├── ghostty/                      # Core
│   ├── nvim/                         # Core
│   ├── sketchybar/                   # Core
│   ├── tmux/                         # Core
│   ├── starship/                     # Core
│   ├── bat/                          # Core
│   ├── borders/                      # Core
│   ├── lsd/                          # Core
│   ├── raycast/                      # Core: scripts/ with theme picker
│   ├── kitty/                        # Optional (secondary terminal)
│   ├── karabiner/                    # Optional (keyboard remapping)
│   ├── zellij/                       # Optional (alternative multiplexer)
│   └── zsh/                          # Core: .zshrc, aliases, plugins
│
├── default/
│   ├── macos/                        # macOS defaults write scripts
│   │   ├── dock.sh
│   │   ├── finder.sh
│   │   ├── keyboard.sh
│   │   ├── trackpad.sh
│   │   ├── screenshots.sh
│   │   └── misc.sh
│   └── themed/                       # Template files (.tpl)
│       ├── ghostty.conf.tpl
│       ├── sketchybar-theme.sh.tpl
│       ├── tmux-theme.conf.tpl
│       ├── borders.tpl
│       ├── bat.tpl
│       ├── lsd-colors.yaml.tpl
│       ├── kitty.conf.tpl
│       └── starship.toml.tpl
│
├── themes/                            # Official themes
│   ├── catppuccin-mocha/             # DEFAULT
│   │   ├── colors.toml
│   │   ├── wallpaper.png
│   │   └── nvim.lua              # Custom overrides: mauve→tokyonight purple, green1="#4fd6be"
│   ├── tokyo-night/
│   ├── gruvbox/
│   ├── nord/
│   ├── rose-pine/
│   └── dracula/
│
├── migrations/                        # Empty, ready for future updates
│
├── .editorconfig                      # 2 spaces, LF, UTF-8
├── .gitignore
│
└── .github/
    └── ISSUE_TEMPLATE/
```

## Theme System

### colors.toml Format

Each theme defines its palette in `colors.toml`:

```toml
# distromac catppuccin-mocha: base Catppuccin Mocha with custom overrides
accent = "#bb9af7"              # TokyoNight purple (replaces Catppuccin mauve #cba6f7)
cursor = "#f5e0dc"
foreground = "#cdd6f4"
background = "#1e1e2e"
surface0 = "#313244"
surface1 = "#45475a"
mantle = "#181825"
selection_foreground = "#1e1e2e"
selection_background = "#f5e0dc"
green1 = "#4fd6be"              # Extra: properties/accents color

color0 = "#45475a"    # Black
color1 = "#f38ba8"    # Red
color2 = "#a6e3a1"    # Green
color3 = "#f9e2af"    # Yellow
color4 = "#89b4fa"    # Blue
color5 = "#bb9af7"    # Purple (TokyoNight Night purple, replaces #cba6f7)
color6 = "#94e2d5"    # Teal
color7 = "#bac2de"    # Lavender
color8 = "#585b70"    # Bright Black
color9 = "#f38ba8"    # Bright Red
color10 = "#a6e3a1"   # Bright Green
color11 = "#f9e2af"   # Bright Yellow
color12 = "#89b4fa"   # Bright Blue
color13 = "#bb9af7"   # Bright Purple (TokyoNight Night purple)
color14 = "#94e2d5"   # Bright Teal
color15 = "#a6adc8"   # Bright White
```

### Template System

Templates use `{{ variable }}` placeholders. Three formats per variable:
- `{{ color_name }}` — Full hex (`#89b4fa`)
- `{{ color_name_strip }}` — Without `#` (`89b4fa`)
- `{{ color_name_rgb }}` — Decimal RGB (`137,180,250`)

Template example (`ghostty.conf.tpl`):
```toml
palette = 0={{ color0 }}
palette = 1={{ color1 }}
background = {{ background }}
foreground = {{ foreground }}
cursor-color = {{ cursor }}
```

Template example (`sketchybar-theme.sh.tpl`):
```bash
export BAR_COLOR=0xff{{ mantle_strip }}
export ITEM_BG_COLOR=0xff{{ surface0_strip }}
export ACCENT_COLOR=0xff{{ accent_strip }}
export TEXT_COLOR=0xff{{ foreground_strip }}
```

### Template Processing (`distromac-theme-set-templates`)

1. Read `colors.toml` from active theme
2. Build sed script with all color substitutions (3 formats per variable)
3. Process user templates first (`~/.config/distromac/themed/`), then built-in (`default/themed/`)
4. Skip rule: if the output file already exists in the `next-theme/` directory (placed there by step 3-4 of the theme flow), skip generating it from a template. This means theme-specific complete files take priority over templates.

### Theme Application Flow (`distromac-theme-set <name>`)

```
1. Validate theme exists (official or ~/.config/distromac/themes/<name>)
2. Create ~/.config/distromac/current/next-theme/
3. Copy official theme → next-theme/
4. Copy user overrides → next-theme/ (overlay)
5. Generate configs from templates (distromac-theme-set-templates)
6. Atomic swap: remove current/theme/, rename current/next-theme/ → current/theme/
   (current/ itself is preserved — theme.name and other state files live alongside theme/)
7. Store theme name in current/theme.name
8. Set wallpaper via osascript:
   osascript -e 'tell application "System Events" to tell every desktop to set picture to "<path>"'
9. Reload/restart all themed components:
   - Sketchybar: brew services restart sketchybar
   - Borders: brew services restart borders
   - Aerospace: aerospace reload-config
   - Ghostty: kill -USR2 $(pgrep ghostty)  (triggers config reload)
   - tmux: tmux source-file ~/.tmux.conf
   - bat: bat cache --build
   - Neovim: autocmd in nvim config watches ~/.config/distromac/current/theme.name
     and auto-applies colorscheme on change (no manual restart needed)
   - Starship/lsd: apply automatically on next prompt/execution
   - Kitty (optional): requires manual restart, show notice if running
10. App-specific theme application:
    - Neovim: copy nvim.lua override if theme provides one
11. Run hook: distromac-hook theme-set <THEME_NAME>
```

### Apps Themed via Templates

| App | Template | What Changes |
|-----|----------|-------------|
| Ghostty | ghostty.conf.tpl | Terminal colors |
| Sketchybar | sketchybar-theme.sh.tpl | Bar and item colors |
| tmux | tmux-theme.conf.tpl | Status bar, pane borders |
| Borders | borders.tpl | Active/inactive window border |
| bat | bat.tpl | Syntax highlighting theme |
| lsd | lsd-colors.yaml.tpl | File type colors |
| Kitty | kitty.conf.tpl | Terminal colors |
| Starship | starship.toml.tpl | Prompt colors |

### Apps with Special Handling

| App | How It's Themed |
|-----|----------------|
| Neovim | Each theme can include `nvim.lua` with colorscheme + custom overrides. Default (catppuccin-mocha) overrides: `mauve` and `pink` → TokyoNight purple, adds `green1 = "#4fd6be"` for properties/accents |
| Aerospace | No color changes (transparent; borders handles visual feedback) |

### Theme Picker UI

Two interfaces for interactive theme selection:

**1. Raycast Script Command (`distromac-theme-pick.sh`)**
- Lives in `config/raycast/scripts/distromac-theme-pick.sh`
- Appears in Raycast as "Pick Theme"
- Lists all available themes (official + user) with descriptions
- On selection, executes `distromac-theme-set <name>`
- Recommended hotkey: `Ctrl+T` (user assigns via Raycast preferences)
- Each theme can include a `preview.png` for future Raycast image support

**2. Terminal picker (`distromac-theme-pick`)**
- Script in `bin/distromac-theme-pick`
- Uses `fzf` with `--preview` to render color palette as ANSI color blocks
- Preview reads `colors.toml` and renders colored `██` blocks for each color
- On selection, executes `distromac-theme-set <name>`

### Hook System

Hooks allow user-defined scripts to run at lifecycle events. Scripts are placed in `~/.config/distromac/hooks/`:

```
~/.config/distromac/hooks/
├── theme-set          # Runs after theme change, receives theme name as $1
└── post-update        # Runs after distromac-update completes
```

`distromac-hook <event> [args...]` checks if a hook script exists for the event and executes it. Hooks are optional — if no script exists, the command silently succeeds.

### User Theme Customization

Users can create custom themes at `~/.config/distromac/themes/<name>/`:
- Must include `colors.toml`
- Can optionally include wallpaper, nvim.lua, or any app-specific override
- Can also override templates at `~/.config/distromac/themed/`

## Installation System

### Usage

```bash
# Remote install (one-liner)
curl -sL https://raw.githubusercontent.com/adriangs1996/distromac/main/boot.sh | bash

# Local install (after cloning)
./install.sh

# With flags
./install.sh --no-nvim --no-sketchybar --theme=tokyo-night
```

### Supported Flags

| Flag | Effect |
|------|--------|
| `--no-<app>` | Exclude app config AND its brew/cask install. Valid: nvim, sketchybar, aerospace, tmux, ghostty, borders, raycast, spotify, kitty, karabiner, zellij |
| `--theme=<name>` | Use different theme (default: catppuccin-mocha) |
| `--no-defaults` | Skip macOS defaults write |
| `--no-fonts` | Skip font installation |
| `--no-languages` | Skip rbenv, uv, nvm, bun, cargo |
| `--minimal` | Only Homebrew + shell + git |

### Pipeline Order

```
1. preflight/
   ├── guard.sh       → Verify macOS, minimum version
   ├── xcode.sh       → Install Xcode CLT if missing
   └── homebrew.sh    → Install Homebrew if missing

2. packaging/
   ├── brews.sh       → CLI: bat, lsd, starship, tmux, fzf, ripgrep, fd, jq...
   ├── casks.sh       → GUI: ghostty, raycast, spotify, google-chrome
   ├── fonts.sh       → JetBrains Mono NF, Cascadia Code NF
   ├── languages.sh   → rbenv, uv, nvm, bun, rustup/cargo
   └── npm.sh         → Global npm packages

3. config/
   ├── shell.sh       → oh-my-zsh + plugins (autosuggestions, syntax-highlighting, vi-mode)
   ├── git.sh         → Git config
   ├── dotfiles.sh    → Copy config/ → ~/.config/ (backup existing)
   ├── macos-defaults.sh → Apply defaults write
   └── theme.sh       → distromac-theme-set catppuccin-mocha (or --theme flag)

4. post-install/
   └── cleanup.sh     → Welcome message, restart notice
```

### Dotfiles Copy Logic (dotfiles.sh)

For each app in `config/`:
1. If `--no-<app>` was passed → skip
2. If `~/.config/<app>/` already exists → backup to `~/.config/<app>.distromac-backup.<TIMESTAMP>`
3. Copy `config/<app>/` → `~/.config/<app>/`
4. Log: `✓ <app> configured`

### boot.sh (Remote Install)

```bash
#!/usr/bin/env bash
set -eEo pipefail

DISTROMAC_REPO="${DISTROMAC_REPO:-adriangs1996/distromac}"
DISTROMAC_BRANCH="${DISTROMAC_BRANCH:-main}"
DISTROMAC_PATH="${HOME}/.local/share/distromac"

git clone -b "$DISTROMAC_BRANCH" "https://github.com/${DISTROMAC_REPO}.git" "$DISTROMAC_PATH"
cd "$DISTROMAC_PATH"
exec bash install.sh "$@"
```

## CLI Scripts (`bin/`)

All scripts follow the naming convention `distromac-<prefix>-<action>`.
Added to `$PATH` via `export PATH="$DISTROMAC_PATH/bin:$PATH"` in `.zshrc`.

### Initial Scripts

| Script | Purpose |
|--------|---------|
| **Theme** | |
| `distromac-theme-set <name>` | Apply theme to all apps |
| `distromac-theme-list` | List available themes (official + user) |
| `distromac-theme-current` | Print name of active theme |
| `distromac-theme-pick` | Interactive fzf picker with color preview |
| `distromac-theme-set-templates` | Generate configs from templates (internal) |
| **Packages** | |
| `distromac-brew-missing <pkg>` | Returns 0 (true) if missing, for use in `if distromac-brew-missing foo; then` |
| `distromac-brew-install <pkg>` | Install via brew if not present |
| `distromac-cask-missing <pkg>` | Returns 0 (true) if missing |
| `distromac-cask-install <pkg>` | Install cask if not present |
| **Config** | |
| `distromac-refresh-config <path>` | Reset config to default (with backup) |
| `distromac-defaults-apply` | Apply all macOS defaults |
| **Restart** | |
| `distromac-restart-sketchybar` | Restart sketchybar |
| `distromac-restart-borders` | Restart borders |
| `distromac-restart-aerospace` | Reload aerospace config |
| **Hooks** | |
| `distromac-hook <event> [args]` | Run user hook script if it exists |
| **System** | |
| `distromac-migrate` | Run pending migrations |
| `distromac-update` | Pull latest + migrate + refresh |
| `distromac-version` | Show current version |

## macOS Defaults

Organized in `default/macos/`, each script contains related `defaults write` commands.

### dock.sh
- Autohide enabled, delay 0
- Reduced tile size
- Hide recent apps
- Minimize with scale effect

### finder.sh
- Show file extensions
- Show hidden files
- List view as default
- Show path bar and status bar
- Search current folder by default

### keyboard.sh
- Fast key repeat rate
- Short delay before repeat
- Disable autocorrect
- Disable smart quotes and dashes
- **Caps Lock remapped to Ctrl** via `hidutil property --set` (generates hardware-specific modifier mapping at runtime; persisted via LaunchAgent plist)

### trackpad.sh
- Tap to click
- High tracking speed
- Natural scrolling

### screenshots.sh
- PNG format
- No shadow
- Save to `~/Screenshots` (created if missing)

### misc.sh
- Disable startup sound
- Expand save panel by default
- Disable "Are you sure you want to open this app?"
- **Autohide native menu bar** via `defaults write NSGlobalDomain _HIHideMenuBar -bool true` (still shows on hover; Sketchybar replaces it functionally)

### Post-install permissions note
Aerospace and Sketchybar require Accessibility permissions. `post-install/cleanup.sh` will prompt the user to grant these in System Settings > Privacy & Security > Accessibility.

## Coding Standards (AGENTS.md)

### Bash
- Shebang: `#!/usr/bin/env bash`
- Error handling: `set -eEo pipefail`
- Indentation: 2 spaces, no tabs
- Conditionals: `[[ ]]` for strings/files, `(( ))` for numeric
- Paths with spaces: use quotes, not backslash escape

### Naming Convention
- All scripts: `distromac-<prefix>-<action>`
- Prefixes: `theme-`, `brew-`, `cask-`, `refresh-`, `restart-`, `defaults-`, `migrate`, `update`, `version`

### Repository
- Branch: `main`
- Version tags: `v0.1.0`, `v0.2.0`, etc.
- License: MIT
- `.editorconfig` enforced (2 spaces, LF, UTF-8, trim trailing whitespace)

## Migration System

Same approach as omarchy:
- Migration files in `migrations/` named by timestamp: `<unix_timestamp>.sh`
- Optional descriptive suffix: `<timestamp>_description.sh`
- No shebang line (executed with `bash` by `distromac-migrate`)
- Must start with `echo` describing what it does
- Uses `$DISTROMAC_PATH` to reference distromac directory
- Tracking in `~/.local/state/distromac/migrations/`
- `distromac-migrate` checks for unrun migrations and executes them
- On failure: prompt to skip or abort
- Empty at launch, ready for future updates

## User Customization Layers

Priority (highest to lowest):
1. **User configs** — `~/.config/<app>/` (direct edits)
2. **User themes** — `~/.config/distromac/themes/<custom>/`
3. **User template overrides** — `~/.config/distromac/themed/`
4. **Active theme** — `~/.config/distromac/current/` (atomic swap)
5. **Official themes** — `$DISTROMAC_PATH/themes/<name>/`
6. **System defaults** — `$DISTROMAC_PATH/default/`

## Platform Notes

- **Rustup/Cargo:** Installed via `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y`, not Homebrew. Handled separately in `languages.sh`.
- **Shell config:** Uses traditional `~/.zshrc` (not `~/.config/zsh/`). The `config/zsh/` directory in the repo contains shell fragments (aliases, plugin config) that get sourced from `.zshrc`.
- **`colors.toml` extends omarchy format:** Adds `surface0`, `surface1`, and `mantle` fields needed by macOS-specific components (Sketchybar). Omarchy themes cannot be used directly without adding these fields.
- **`DISTROMAC_PATH`:** Set to `~/.local/share/distromac` by `boot.sh`. For local clones, `install.sh` sets it to the repo's location. Exported in `.zshrc` so all `distromac-*` scripts can reference it.
