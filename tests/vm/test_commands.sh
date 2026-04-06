#!/usr/bin/env bash
# Sourced by suite.sh — do not execute directly.

# Define helpers if not already available (e.g., when running SUITE=commands alone)
if ! declare -f _flag_passed &>/dev/null; then
  _flag_passed() {
    [[ " ${DISTROMAC_TEST_FLAGS:-} " == *" $1 "* ]]
  }
  _app_skipped() {
    _flag_passed "--no-$1" || _flag_passed "--minimal"
  }
fi

# --- distromac-version ---
assert_exit_0 "version exits 0" distromac-version
assert_eq "version matches file" "$(cat "$DISTROMAC_PATH/version")" "$(distromac-version)"

# --- distromac-theme-list ---
assert_exit_0 "theme-list exits 0" distromac-theme-list

# Compare against themes/ directory names (dynamic, not hardcoded)
expected_themes=$(ls -1 "$DISTROMAC_PATH/themes/" | sort)
actual_themes=$(distromac-theme-list | sort)
assert_eq "theme-list matches themes dirs" "$expected_themes" "$actual_themes"

# --- distromac-theme-current ---
assert_exit_0 "theme-current exits 0" distromac-theme-current
assert_eq "theme-current matches theme.name" \
  "$(cat "$HOME/.config/distromac/current/theme.name")" \
  "$(distromac-theme-current)"

# Negative test: no theme set
mv "$HOME/.config/distromac/current/theme.name" "$HOME/.config/distromac/current/theme.name.bak"
assert_exit_nonzero "theme-current exits 1 with no theme" distromac-theme-current
assert_stdout_contains "theme-current says no theme" "No theme set" distromac-theme-current
mv "$HOME/.config/distromac/current/theme.name.bak" "$HOME/.config/distromac/current/theme.name"

# --- distromac-theme-pick: SKIP (requires interactive fzf) ---
# --- distromac-theme-set: SKIP (covered in test_themes.sh) ---
# --- distromac-theme-set-templates: SKIP (covered implicitly by test_themes.sh) ---

# --- distromac-refresh-config ---
# Only test if ghostty config source exists (not --no-ghostty)
if ! _app_skipped "ghostty" && [[ -f "$DISTROMAC_PATH/config/ghostty/config" ]]; then
  assert_exit_0 "refresh-config ghostty/config exits 0" distromac-refresh-config ghostty/config
fi

# --- distromac-defaults-apply ---
if ! _flag_passed "--no-defaults"; then
  assert_exit_0 "defaults-apply exits 0" distromac-defaults-apply
fi

# --- distromac-brew-install (already-installed package) ---
assert_exit_0 "brew-install with installed pkg" distromac-brew-install git

# --- distromac-brew-missing (all present → exit 1) ---
# brew-missing exits 0 if ANY missing, 1 if all present
assert_exit_nonzero "brew-missing all present" distromac-brew-missing bat lsd starship

# --- distromac-cask-install (already-installed cask) ---
# Use a cask known to be installed — check what's available
if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null 2>&1; then
  assert_exit_0 "cask-install with installed cask" distromac-cask-install font-jetbrains-mono-nerd-font
fi

# --- distromac-cask-missing (all present → exit 1) ---
if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null 2>&1; then
  assert_exit_nonzero "cask-missing all present" distromac-cask-missing font-jetbrains-mono-nerd-font
fi

# --- distromac-hook ---
# No-op when hook doesn't exist
assert_exit_0 "hook no-op for missing hook" distromac-hook test-event

# Create all 4 hooks, verify they execute and receive args
HOOKS_DIR="$HOME/.config/distromac/hooks"
mkdir -p "$HOOKS_DIR"

for hook in pre-install post-install pre-theme post-theme; do
  cat > "$HOOKS_DIR/$hook" << 'HOOKEOF'
#!/usr/bin/env bash
echo "$0 $*" >> /tmp/distromac-hook-log
HOOKEOF
  chmod +x "$HOOKS_DIR/$hook"
done

# Clear log
rm -f /tmp/distromac-hook-log

# Test pre-theme and post-theme (fired by theme-set)
current_theme=$(distromac-theme-current)
distromac-theme-set "$current_theme" >/dev/null 2>&1

assert_file_exists "hook log created" /tmp/distromac-hook-log
assert_contains "pre-theme hook fired" "pre-theme" /tmp/distromac-hook-log
assert_contains "post-theme hook fired" "post-theme" /tmp/distromac-hook-log
assert_contains "pre-theme receives theme arg" "pre-theme $current_theme" /tmp/distromac-hook-log
assert_contains "post-theme receives theme arg" "post-theme $current_theme" /tmp/distromac-hook-log

# Test pre-install and post-install (fired by install.sh)
rm -f /tmp/distromac-hook-log
bash "$DISTROMAC_PATH/install.sh" >/dev/null 2>&1 || true

assert_contains "pre-install hook fired" "pre-install" /tmp/distromac-hook-log
assert_contains "post-install hook fired" "post-install" /tmp/distromac-hook-log

# Cleanup
rm -f /tmp/distromac-hook-log
rm -f "$HOOKS_DIR"/{pre-install,post-install,pre-theme,post-theme}

# --- distromac-migrate (no pending migrations in fresh VM) ---
assert_exit_0 "migrate exits 0" bash -c "distromac-migrate < /dev/null"

# --- distromac-update: SKIP (covered in test_update.sh) ---
# --- distromac-menu: SKIP (requires interactive terminal) ---

# --- Restart commands (no-ops if services not running) ---
assert_exit_0 "restart-sketchybar exits 0" distromac-restart-sketchybar
assert_exit_0 "restart-borders exits 0" distromac-restart-borders
assert_exit_0 "restart-aerospace exits 0" distromac-restart-aerospace
