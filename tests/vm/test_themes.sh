#!/usr/bin/env bash
# Sourced by suite.sh — do not execute directly.
# Bash 3.2 compatible — no associative arrays or mapfile.

CURRENT_DIR="$HOME/.config/distromac/current"
THEME_OUT="$CURRENT_DIR/theme"

# --- Helpers (bash 3 compatible) ---

# Temp file for parsed colors (key=value per line)
_COLORS_FILE=$(mktemp)
trap "rm -f '$_COLORS_FILE'" EXIT

# Parse colors.toml into temp file
parse_colors_toml() {
  local file="$1"
  : > "$_COLORS_FILE"
  while IFS='=' read -r key value; do
    [[ $key =~ ^[[:space:]]*# ]] && continue
    [[ -z $key ]] && continue
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs | sed 's/^"//;s/"$//' | xargs)
    [[ -z $value ]] && continue
    echo "${key}=${value}" >> "$_COLORS_FILE"
    # Strip leading # for _strip variant
    echo "${key}_strip=${value#\#}" >> "$_COLORS_FILE"
  done < "$file"
}

# Look up a color value by key
_color_get() {
  local key="$1"
  grep "^${key}=" "$_COLORS_FILE" | head -1 | cut -d= -f2-
}

# Convert hex to decimal R,G,B
hex_to_rgb() {
  local hex="${1#\#}"
  printf '%d,%d,%d' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# Assert a color key's value appears in a file
assert_color() {
  local theme="$1" color_key="$2" file="$3"
  local value
  value=$(_color_get "$color_key")
  if [[ -z $value ]]; then
    _fail "[$theme] $color_key in $(basename "$file")" "key '$color_key' to exist in COLORS" "key not found"
    return
  fi
  assert_contains "[$theme] $color_key in $(basename "$file")" "$value" "$file"
}

# --- Per-theme tests ---
while IFS= read -r theme; do
  # 1. Apply theme
  assert_exit_0 "[$theme] theme-set exits 0" distromac-theme-set "$theme"

  # 2. Theme name stored correctly
  assert_eq "[$theme] theme.name correct" "$theme" "$(cat "$CURRENT_DIR/theme.name")"

  # 3. Colors file staged
  assert_file_exists "[$theme] colors.toml staged" "$THEME_OUT/colors.toml"

  # Parse colors for this theme
  parse_colors_toml "$THEME_OUT/colors.toml"

  # 4. No unresolved placeholders in generated configs
  for f in "$THEME_OUT"/*; do
    [[ ! -f $f ]] && continue
    local_name=$(basename "$f")
    # Skip non-template outputs
    case "$local_name" in
      colors.toml|*.png|*.jpg|*.jpeg|*.lua) continue ;;
    esac
    assert_exit_nonzero "[$theme] no placeholders in $local_name" \
      grep -qE '\{\{ [a-z_0-9]+ \}\}' "$f"
  done

  # 5. Color values correctly injected

  # ghostty.conf — full hex values
  if [[ -f "$THEME_OUT/ghostty.conf" ]]; then
    for key in background foreground cursor selection_background selection_foreground \
               color0 color1 color2 color3 color4 color5 color6 color7 \
               color8 color9 color10 color11 color12 color13 color14 color15; do
      assert_color "$theme" "$key" "$THEME_OUT/ghostty.conf"
    done
  fi

  # tmux-theme.conf — full hex
  if [[ -f "$THEME_OUT/tmux-theme.conf" ]]; then
    for key in background foreground surface0 surface1 color1 color2; do
      assert_color "$theme" "$key" "$THEME_OUT/tmux-theme.conf"
    done
  fi

  # starship.toml — full hex (staged file, not deployed)
  if [[ -f "$THEME_OUT/starship.toml" ]]; then
    for key in background foreground mantle surface0 surface1 \
               color1 color2 color3 color4 color5 color6 color7 color15; do
      assert_color "$theme" "$key" "$THEME_OUT/starship.toml"
    done
  fi

  # borders — stripped hex (no #)
  if [[ -f "$THEME_OUT/borders" ]]; then
    for key in color4_strip surface1_strip; do
      assert_color "$theme" "$key" "$THEME_OUT/borders"
    done
  fi

  # sketchybar-theme.sh — stripped hex
  if [[ -f "$THEME_OUT/sketchybar-theme.sh" ]]; then
    for key in color1_strip color2_strip color3_strip color4_strip color5_strip \
               color6_strip color7_strip accent_strip foreground_strip \
               surface0_strip surface1_strip mantle_strip background_strip color15_strip; do
      assert_color "$theme" "$key" "$THEME_OUT/sketchybar-theme.sh"
    done
  fi

  # bat — bat_theme string value
  if [[ -f "$THEME_OUT/bat" ]]; then
    assert_color "$theme" "bat_theme" "$THEME_OUT/bat"
  fi

  # lsd-colors.yaml — full hex
  if [[ -f "$THEME_OUT/lsd-colors.yaml" ]]; then
    for key in color1 color2 color3 color4 color5 color6 surface1 foreground color7; do
      assert_color "$theme" "$key" "$THEME_OUT/lsd-colors.yaml"
    done
  fi

  # zsh-theme.zsh — full hex + _rgb variants
  if [[ -f "$THEME_OUT/zsh-theme.zsh" ]]; then
    for key in blue cyan green green1 red yellow magenta foreground overlay0; do
      assert_color "$theme" "$key" "$THEME_OUT/zsh-theme.zsh"
    done
    # _rgb variants
    for key in blue cyan yellow green red magenta green1; do
      local_hex=$(_color_get "$key")
      if [[ -n $local_hex && $local_hex =~ ^# ]]; then
        local_rgb=$(hex_to_rgb "$local_hex")
        assert_contains "[$theme] ${key}_rgb in zsh-theme.zsh" "$local_rgb" "$THEME_OUT/zsh-theme.zsh"
      fi
    done
  fi

  # 6. Configs deployed to final locations
  assert_file_exists "[$theme] bat config deployed" "$HOME/.config/bat/config"
  assert_file_exists "[$theme] lsd colors deployed" "$HOME/.config/lsd/colors.yaml"
  assert_file_exists "[$theme] starship config deployed" "$HOME/.config/starship/starship.toml"

  # In-place files (sourced from staging dir)
  for f in zsh-theme.zsh ghostty.conf tmux-theme.conf borders sketchybar-theme.sh; do
    assert_file_exists "[$theme] $f in staging" "$THEME_OUT/$f"
  done

  # nvim.lua — only if theme provides it
  if [[ -f "$THEME_OUT/nvim.lua" ]]; then
    assert_file_exists "[$theme] nvim theme.lua deployed" "$HOME/.config/nvim/lua/distromac/theme.lua"
  fi

  # Wallpaper — verify theme ships one and it landed in staging
  wallpaper_found=false
  for ext in png jpg jpeg; do
    if [[ -f "$THEME_OUT/wallpaper.$ext" ]]; then
      wallpaper_found=true
      break
    fi
  done
  if [[ $wallpaper_found == true ]]; then
    _pass "[$theme] wallpaper in staging"
  else
    _fail "[$theme] wallpaper in staging" "wallpaper.{png,jpg,jpeg} to exist" "not found"
  fi

  # 7. Deployed files match staging
  # Physical copies
  assert_files_equal "[$theme] bat staging == deployed" "$THEME_OUT/bat" "$HOME/.config/bat/config"
  assert_files_equal "[$theme] lsd staging == deployed" "$THEME_OUT/lsd-colors.yaml" "$HOME/.config/lsd/colors.yaml"

  # Starship: deployed = base_config + theme palette (deployed is larger)
  # Verify the theme palette content appears within the deployed file
  if [[ -f "$THEME_OUT/starship.toml" ]]; then
    starship_theme_content=$(cat "$THEME_OUT/starship.toml")
    assert_contains "[$theme] starship theme in deployed" "$starship_theme_content" "$HOME/.config/starship/starship.toml"
  fi

  # nvim.lua if exists
  if [[ -f "$THEME_OUT/nvim.lua" ]]; then
    assert_files_equal "[$theme] nvim staging == deployed" \
      "$THEME_OUT/nvim.lua" "$HOME/.config/nvim/lua/distromac/theme.lua"
  fi

done < <(distromac-theme-list)

# --- Round-trip test ---
all_themes=()
while IFS= read -r t; do
  all_themes+=("$t")
done < <(distromac-theme-list)

first_theme="${all_themes[0]}"
last_theme="${all_themes[${#all_themes[@]}-1]}"

# Set first theme and snapshot checksums
distromac-theme-set "$first_theme" >/dev/null 2>&1

_SNAPSHOT_FILE=$(mktemp)
for f in "$THEME_OUT"/*; do
  [[ ! -f $f ]] && continue
  fname=$(basename "$f")
  echo "${fname}=$(md5 -q "$f")" >> "$_SNAPSHOT_FILE"
done

# Set last theme, then back to first
distromac-theme-set "$last_theme" >/dev/null 2>&1
distromac-theme-set "$first_theme" >/dev/null 2>&1

# Verify checksums match
for f in "$THEME_OUT"/*; do
  [[ ! -f $f ]] && continue
  fname=$(basename "$f")
  current_sum=$(md5 -q "$f")
  orig_sum=$(grep "^${fname}=" "$_SNAPSHOT_FILE" | head -1 | cut -d= -f2-)
  assert_eq "[round-trip] $fname unchanged" "${orig_sum:-MISSING}" "$current_sum"
done

rm -f "$_SNAPSHOT_FILE"
