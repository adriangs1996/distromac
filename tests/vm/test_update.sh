#!/usr/bin/env bash
# Sourced by suite.sh — do not execute directly.
# Bash 3.2 compatible — no associative arrays.

CURRENT_THEME=$(distromac-theme-current)
THEME_OUT="$HOME/.config/distromac/current/theme"

# 1. Record initial checksums of deployed configs (temp file instead of assoc array)
_CKSUM_FILE=$(mktemp)

_record_checksum() {
  local label="$1" path="$2"
  if [[ -f $path ]]; then
    echo "${label}=$(md5 -q "$path")" >> "$_CKSUM_FILE"
  fi
}

_get_checksum() {
  grep "^${1}=" "$_CKSUM_FILE" | head -1 | cut -d= -f2-
}

_record_checksum "bat" "$HOME/.config/bat/config"
_record_checksum "lsd" "$HOME/.config/lsd/colors.yaml"
_record_checksum "starship" "$HOME/.config/starship/starship.toml"
_record_checksum "ghostty" "$THEME_OUT/ghostty.conf"
_record_checksum "tmux" "$THEME_OUT/tmux-theme.conf"
_record_checksum "borders" "$THEME_OUT/borders"
_record_checksum "sketchybar" "$THEME_OUT/sketchybar-theme.sh"
_record_checksum "zsh" "$THEME_OUT/zsh-theme.zsh"

# 2. Modify a template (append a comment to bat.tpl)
echo "# test-modification" >> "$DISTROMAC_PATH/default/themed/bat.tpl"

# 3. Re-apply current theme
assert_exit_0 "re-apply after template change" distromac-theme-set "$CURRENT_THEME"

# 4. Verify bat config changed
orig_bat=$(_get_checksum "bat")
if [[ -n $orig_bat ]]; then
  new_cksum=$(md5 -q "$HOME/.config/bat/config")
  if [[ $orig_bat != "$new_cksum" ]]; then
    _pass "bat config changed after template edit"
  else
    _fail "bat config changed after template edit" "checksum to differ" "checksums match"
  fi
fi

# 5. Verify other configs did NOT change (only bat.tpl was modified)
for label in lsd ghostty tmux borders sketchybar zsh; do
  case "$label" in
    lsd)       path="$HOME/.config/lsd/colors.yaml" ;;
    ghostty)   path="$THEME_OUT/ghostty.conf" ;;
    tmux)      path="$THEME_OUT/tmux-theme.conf" ;;
    borders)   path="$THEME_OUT/borders" ;;
    sketchybar) path="$THEME_OUT/sketchybar-theme.sh" ;;
    zsh)       path="$THEME_OUT/zsh-theme.zsh" ;;
  esac
  orig=$(_get_checksum "$label")
  if [[ -n $orig && -f $path ]]; then
    assert_eq "$label config unchanged" "$orig" "$(md5 -q "$path")"
  fi
done

# 6. Revert the template change
sed -i '' '/^# test-modification$/d' "$DISTROMAC_PATH/default/themed/bat.tpl"

# 7. Re-apply again
assert_exit_0 "re-apply after template revert" distromac-theme-set "$CURRENT_THEME"

# 8. Verify all checksums match originals (clean round-trip)
_verify_restored() {
  local label="$1" path="$2"
  local orig
  orig=$(_get_checksum "$label")
  if [[ -n $orig && -f $path ]]; then
    assert_eq "$label config restored" "$orig" "$(md5 -q "$path")"
  fi
}

_verify_restored "bat" "$HOME/.config/bat/config"
_verify_restored "lsd" "$HOME/.config/lsd/colors.yaml"
_verify_restored "starship" "$HOME/.config/starship/starship.toml"
_verify_restored "ghostty" "$THEME_OUT/ghostty.conf"
_verify_restored "tmux" "$THEME_OUT/tmux-theme.conf"
_verify_restored "borders" "$THEME_OUT/borders"
_verify_restored "sketchybar" "$THEME_OUT/sketchybar-theme.sh"
_verify_restored "zsh" "$THEME_OUT/zsh-theme.zsh"

rm -f "$_CKSUM_FILE"
