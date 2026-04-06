#!/usr/bin/env bash
# Sourced by suite.sh — do not execute directly.

# --- Helper: check if a flag was passed ---
_flag_passed() {
  [[ " ${DISTROMAC_TEST_FLAGS:-} " == *" $1 "* ]]
}

_app_skipped() {
  _flag_passed "--no-$1" || _flag_passed "--minimal"
}

# --- Phase 1: Run install ---
install_flags=()
if [[ -n ${DISTROMAC_TEST_FLAGS:-} ]]; then
  read -ra install_flags <<< "$DISTROMAC_TEST_FLAGS"
fi

# Run install with visible output so failures can be diagnosed
install_rc=0
bash "$DISTROMAC_PATH/install.sh" "${install_flags[@]}" 2>&1 || install_rc=$?

if (( install_rc == 0 )); then
  _pass "install.sh exits 0"
else
  _fail "install.sh exits 0" "exit 0" "exit $install_rc"
fi

# Refresh PATH — install.sh installs homebrew but its PATH changes
# don't propagate back to our shell
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Phase 2: Core binaries ---
for bin in bat lsd starship fzf rg fd jq git gh; do
  assert_exit_0 "$bin is available" command -v "$bin"
done

# --- Phase 3: Optional binaries (gated by flags) ---
# CLI tools
for app in nvim tmux sketchybar borders; do
  if ! _app_skipped "$app"; then
    assert_exit_0 "$app is available" command -v "$app"
  fi
done

# GUI apps (casks)
if ! _app_skipped "ghostty"; then
  assert_dir_exists "Ghostty.app installed" "/Applications/Ghostty.app"
fi
if ! _app_skipped "raycast"; then
  assert_dir_exists "Raycast.app installed" "/Applications/Raycast.app"
fi
if ! _app_skipped "spotify"; then
  assert_dir_exists "Spotify.app installed" "/Applications/Spotify.app"
fi
if ! _app_skipped "aerospace"; then
  assert_dir_exists "AeroSpace.app installed" "/Applications/AeroSpace.app"
fi

# --- Phase 4: Config directories ---
# Always present
for dir in "$HOME/.config/bat" "$HOME/.config/lsd" "$HOME/.config/starship" "$HOME/.config/distromac/current"; do
  assert_dir_exists "$(basename "$dir") config dir exists" "$dir"
done

# Optional (gated)
if ! _app_skipped "nvim"; then
  assert_dir_exists "nvim distromac dir exists" "$HOME/.config/nvim/lua/distromac"
fi
if ! _app_skipped "ghostty"; then
  assert_dir_exists "ghostty config dir exists" "$HOME/.config/ghostty"
fi
if ! _app_skipped "aerospace"; then
  assert_dir_exists "aerospace config dir exists" "$HOME/.config/aerospace"
fi
if ! _app_skipped "tmux"; then
  # tmux may use ~/.config/tmux or ~/.tmux.conf
  if [[ ! -d "$HOME/.config/tmux" ]] && [[ ! -f "$HOME/.tmux.conf" ]]; then
    _fail "tmux config exists" "~/.config/tmux or ~/.tmux.conf to exist" "neither found"
  else
    _pass "tmux config exists"
  fi
fi

# --- Phase 5: Theme state ---
assert_file_exists "theme.name exists" "$HOME/.config/distromac/current/theme.name"

# Determine expected theme
expected_theme="catppuccin-mocha"
if [[ "${DISTROMAC_TEST_FLAGS:-}" =~ --theme=([^ ]+) ]]; then
  expected_theme="${BASH_REMATCH[1]}"
fi

assert_eq "theme is $expected_theme" "$expected_theme" "$(cat "$HOME/.config/distromac/current/theme.name")"

# --- Phase 6: User dotfiles (mirror/stow approach) ---
DOTFILES_SRC="$HOME/.config/distromac/dotfiles"
mkdir -p "$DOTFILES_SRC"

# Test 1: flat file in $HOME
echo "flat-content" > "$DOTFILES_SRC/.testrc"

# Test 2: nested directory (e.g., zellij-like config)
mkdir -p "$DOTFILES_SRC/.config/zellij"
echo "layout {}" > "$DOTFILES_SRC/.config/zellij/config.kdl"

# Test 3: file inside distromac-managed dir (merge, don't clobber)
mkdir -p "$DOTFILES_SRC/.config/nvim/lua"
echo "-- user custom" > "$DOTFILES_SRC/.config/nvim/lua/custom.lua"

# Source dotfiles.sh
TIMESTAMP=$(date +%s)
source "$DISTROMAC_PATH/install/helpers/logging.sh"
source "$DISTROMAC_PATH/install/config/dotfiles.sh"

# Flat file
assert_file_exists "flat dotfile symlinked" "$HOME/.testrc"
assert_eq "flat dotfile is symlink" "true" "$([ -L "$HOME/.testrc" ] && echo true || echo false)"
assert_contains "flat dotfile content" "flat-content" "$HOME/.testrc"

# Nested directory: dir created, leaf file symlinked
assert_dir_exists "zellij config dir created" "$HOME/.config/zellij"
assert_file_exists "zellij config symlinked" "$HOME/.config/zellij/config.kdl"
assert_eq "zellij config is symlink" "true" "$([ -L "$HOME/.config/zellij/config.kdl" ] && echo true || echo false)"
assert_contains "zellij config content" "layout {}" "$HOME/.config/zellij/config.kdl"

# Merge with distromac dir: nvim dir still exists with distromac files + user file
assert_dir_exists "nvim dir preserved" "$HOME/.config/nvim/lua"
assert_file_exists "user lua symlinked into nvim" "$HOME/.config/nvim/lua/custom.lua"
assert_eq "user lua is symlink" "true" "$([ -L "$HOME/.config/nvim/lua/custom.lua" ] && echo true || echo false)"
# distromac's own files should still be there
assert_dir_exists "distromac nvim untouched" "$HOME/.config/nvim/lua/distromac"

# Idempotent: run again, no backups created
source "$DISTROMAC_PATH/install/config/dotfiles.sh"
assert_file_missing "no flat backup on re-run" "$HOME/.testrc.distromac-backup.*"

# Cleanup
rm -f "$HOME/.testrc"
rm -f "$HOME/.config/zellij/config.kdl" && rmdir "$HOME/.config/zellij" 2>/dev/null || true
rm -f "$HOME/.config/nvim/lua/custom.lua"
rm -rf "$DOTFILES_SRC"
