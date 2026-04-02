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

assert_exit_0 "install.sh exits 0" bash "$DISTROMAC_PATH/install.sh" "${install_flags[@]}"

# --- Phase 2: Core binaries ---
for bin in bat lsd starship fzf rg fd jq git gh; do
  assert_exit_0 "$bin is available" command -v "$bin"
done

# --- Phase 3: Optional binaries (gated by flags) ---
# CLI tools
for app in nvim tmux sketchybar borders aerospace; do
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
