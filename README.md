# distromac

A declarative macOS developer environment — opinionated dotfiles, app configs, and a theme system, installed in one command.

---

## Preview

> Screenshots coming soon. Run the installer and pick a theme to see it in action.

---

## Quick Install

```bash
curl -sL https://raw.githubusercontent.com/adriangs1996/distromac/main/boot.sh | bash
```

The bootstrap script clones the repo and runs `install.sh`. On subsequent runs it will update in place.

---

## What's Included

| App | Description | Skip Flag |
|---|---|---|
| **Ghostty** | GPU-accelerated terminal emulator | `--no-ghostty` |
| **Neovim** | Modal editor with full plugin config | `--no-nvim` |
| **tmux** | Terminal multiplexer | `--no-tmux` |
| **Aerospace** | Tiling window manager | `--no-aerospace` |
| **Sketchybar** | Custom macOS menu bar | `--no-sketchybar` |
| **Borders** | Window border highlights (JankyBorders) | `--no-borders` |
| **Raycast** | Launcher with theme picker script | `--no-raycast` |
| **Spotify** | Music player | `--no-spotify` |
| **bat** | `cat` replacement (syntax highlighting) | — |
| **zsh** | Shell with starship prompt | — |

---

## Install Flags

```
./install.sh [flags]
```

| Flag | Effect |
|---|---|
| `--theme=<name>` | Set starting theme (default: `catppuccin-mocha`) |
| `--no-<app>` | Skip installing a specific app (see table above) |
| `--no-defaults` | Skip applying macOS system defaults |
| `--no-fonts` | Skip Nerd Font installation |
| `--no-languages` | Skip language toolchain setup (pyenv, rbenv, etc.) |
| `--no-npm` | Skip global npm package installation |
| `--minimal` | Skip everything optional; core shell only |

**Examples:**

```bash
# Tokyo Night theme, no Sketchybar
./install.sh --theme=tokyo-night --no-sketchybar

# Minimal install
./install.sh --minimal
```

---

## Theme System

All themes live in `themes/<name>/colors.toml`. At install time (and on every `distromac-theme-set` call) the template engine reads the palette and renders configs for every themed app.

**Available themes:**

| Theme | Style |
|---|---|
| `catppuccin-mocha` | Dark, pastel (default) |
| `tokyo-night` | Dark blue / purple |
| `gruvbox` | Warm retro dark |
| `nord` | Arctic blue |
| `rose-pine` | Muted rose / dark |
| `dracula` | Classic dark purple |

### Switching Themes

```bash
distromac-theme-set tokyo-night
```

Or use the interactive picker (requires fzf):

```bash
distromac-theme-pick
```

The current theme is printed by:

```bash
distromac-theme-current
```

### Creating a Custom Theme

1. Copy an existing theme as a starting point:

   ```bash
   cp -r themes/catppuccin-mocha themes/my-theme
   ```

2. Edit `themes/my-theme/colors.toml`. Required fields:

   ```toml
   accent     = "#hexcolor"
   background = "#hexcolor"
   foreground = "#hexcolor"
   mantle     = "#hexcolor"
   surface0   = "#hexcolor"
   surface1   = "#hexcolor"
   overlay0   = "#hexcolor"

   red     = "#hexcolor"
   green   = "#hexcolor"
   green1  = "#hexcolor"
   yellow  = "#hexcolor"
   blue    = "#hexcolor"
   magenta = "#hexcolor"
   cyan    = "#hexcolor"
   white   = "#hexcolor"

   color0  = "#hexcolor"
   # ... color1 through color15

   bat_theme = "name-of-bat-theme"
   ```

3. Apply it:

   ```bash
   distromac-theme-set my-theme
   ```

---

## Commands Reference

| Command | Description |
|---|---|
| `distromac-theme-set <name>` | Apply a theme across all apps |
| `distromac-theme-list` | List available themes |
| `distromac-theme-current` | Print the active theme |
| `distromac-theme-pick` | Interactive fzf theme picker |
| `distromac-theme-set-templates` | Re-render templates for current theme |
| `distromac-defaults-apply` | Re-apply macOS system defaults |
| `distromac-refresh-config` | Re-render all app configs from templates |
| `distromac-update` | Pull latest distromac and re-apply |
| `distromac-migrate` | Run any pending migration scripts |
| `distromac-hook <event>` | Fire a lifecycle hook |
| `distromac-brew-install` | Install missing Homebrew formulae |
| `distromac-brew-missing` | List formulae not yet installed |
| `distromac-cask-install` | Install missing Homebrew casks |
| `distromac-cask-missing` | List casks not yet installed |
| `distromac-restart-aerospace` | Restart Aerospace WM |
| `distromac-restart-sketchybar` | Restart Sketchybar |
| `distromac-restart-borders` | Restart JankyBorders |
| `distromac-version` | Print distromac version |

---

## Customization

### Hooks

Lifecycle hooks let you run custom code at key points without modifying distromac itself. Create executable scripts in `~/.config/distromac/hooks/`:

| Hook | When it runs |
|---|---|
| `pre-install` | Before install begins |
| `post-install` | After install completes |
| `pre-theme` | Before a theme is applied |
| `post-theme` | After a theme is applied |

Example:

```bash
mkdir -p ~/.config/distromac/hooks
cat > ~/.config/distromac/hooks/post-theme << 'EOF'
#!/usr/bin/env bash
# Reload any custom scripts after a theme change
pkill -USR1 some-daemon || true
EOF
chmod +x ~/.config/distromac/hooks/post-theme
```

### User Themes

Drop a theme directory into `~/.config/distromac/themes/<name>/colors.toml`. User themes take precedence over built-in themes with the same name.

### Dotfiles

Place personal dotfiles in `~/.config/distromac/dotfiles/`. They are symlinked into `$HOME` during install and on `distromac-update`.

---

## License

MIT — see [LICENSE](LICENSE).
