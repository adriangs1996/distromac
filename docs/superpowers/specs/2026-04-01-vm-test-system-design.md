# distromac VM Test System — Design Spec

**Date:** 2026-04-01
**Status:** Draft

## Overview

An automated test system that spins up ephemeral macOS VMs via [Tart](https://github.com/cirruslabs/tart) to run the full distromac install and lifecycle with real macOS fidelity. Runs locally on Apple Silicon via `make test-vm`.

## Goals

- Verify `install.sh` completes without errors across flag combinations
- Verify the theme engine produces correct configs with no unresolved placeholders and correct color values for every theme
- Verify every `bin/` command runs without error and produces expected output
- Verify the update cycle re-applies configs correctly
- Catch subtle failures: stale configs from previous themes, partially resolved templates, wrong color values in generated files

## Non-Goals

- CI integration (local only for now)
- Testing macOS GUI behavior (wallpaper, window management)
- Performance benchmarking

## Architecture

```
make test-vm                              # default: full install + lifecycle
make test-vm FLAGS="--no-sketchybar"      # forward flags to install.sh
make test-vm SUITE=themes                 # run only one suite
make test-vm IMAGE=ghcr.io/cirruslabs/macos-sequoia-xcode:latest

    │
    ▼
tests/vm/run.sh                          ← orchestrator (runs on host)
    │
    ├── 1. tart clone <image> → fresh VM
    ├── 2. tart run (background)
    ├── 3. wait for SSH availability
    ├── 4. rsync repo into VM
    ├── 5. SSH: execute tests/vm/suite.sh
    │       └── suite.sh (runs inside VM)
    │           ├── assert.sh         ← assertion helpers
    │           ├── test_install.sh   ← install + verify
    │           ├── test_themes.sh    ← theme engine deep checks
    │           ├── test_commands.sh  ← bin/* commands
    │           └── test_update.sh    ← update cycle
    ├── 6. collect results (exit code + log)
    └── 7. tart stop + tart delete (cleanup)
```

## Prerequisites

Two tools needed on the host Mac:

```bash
brew install cirruslabs/cli/tart
brew install hudochenkov/sshpass/sshpass
```

- **Tart** — macOS VM manager (Apple Silicon, Virtualization.framework)
- **sshpass** — non-interactive SSH password auth for the Tart VM default credentials

The orchestrator checks for both at startup and exits with a clear message if either is missing.

## Components

### `tests/vm/run.sh` — Orchestrator

Runs on the host. Manages the full VM lifecycle.

**Configuration (environment variables with defaults):**

| Variable | Default | Description |
|---|---|---|
| `DISTROMAC_TEST_IMAGE` | `ghcr.io/cirruslabs/macos-sequoia-base:latest` | Tart OCI image to clone |
| `DISTROMAC_TEST_VM` | `distromac-test-$$` | VM name (PID-suffixed for uniqueness) |
| `DISTROMAC_TEST_FLAGS` | _(empty)_ | Flags forwarded to `install.sh` |
| `DISTROMAC_TEST_SUITE` | _(empty — run all)_ | Run only a specific suite (`install`, `themes`, `commands`, `update`) |
| `DISTROMAC_TEST_SSH_USER` | `admin` | SSH user for the Tart VM |
| `DISTROMAC_TEST_SSH_PASS` | `admin` | SSH password (Tart default) |

**Lifecycle steps:**

1. **Clone** — `tart clone $IMAGE $VM_NAME`. If the image is not cached locally, Tart pulls it automatically (first run will be slow).
2. **Start** — `tart run $VM_NAME --no-graphics &`. Headless mode.
3. **Wait for SSH** — Poll `tart ip $VM_NAME` + `ssh` connection test with timeout (max 120s, poll every 5s). Exit with error if timeout.
4. **Sync repo** — `sshpass -p $SSH_PASS rsync -az --exclude .git` the entire repo into `~/distromac` inside the VM.
5. **Run suite** — `sshpass -p $SSH_PASS ssh $VM "bash ~/distromac/tests/vm/suite.sh"` with FLAGS and SUITE forwarded as env vars. Output streams naturally through the SSH pipe (no `-t` flag, which can cause issues in non-interactive contexts).
6. **Collect** — Capture exit code. Print summary.
7. **Cleanup** — Always runs (trap on EXIT): `tart stop $VM_NAME && tart delete $VM_NAME`.

**Overall timeout:** 30 minutes max for the entire run. Enforced via `timeout 1800` wrapping the SSH test execution. Prevents hangs from Homebrew installs or other unexpected blocks.

**Exit codes:** 0 = all pass, 1 = test failure, 2 = infrastructure error (VM, SSH, timeout, etc.)

### `tests/vm/suite.sh` — Test Runner (inside VM)

Entry point that runs inside the VM. Receives environment:
- `DISTROMAC_TEST_FLAGS` — flags to forward to `install.sh`
- `DISTROMAC_TEST_SUITE` — optional filter for a single suite

**Behavior:**
1. Sources `assert.sh`
2. Sets `DISTROMAC_PATH=~/distromac`
3. Determines which suites to run (all by default, or filtered)
4. Executes each suite in order: `install → themes → commands → update`
5. Tracks pass/fail counts and prints a summary at the end
6. Exits non-zero if any assertion failed

**Output format:**
```
[SUITE] install
  [PASS] install.sh exits 0
  [PASS] bat binary exists
  [FAIL] starship binary exists
         Expected: file /opt/homebrew/bin/starship to exist
         Got: file not found
  ...
[SUITE] themes
  ...

══════════════════════════
  Results: 42 passed, 1 failed
══════════════════════════
```

### `tests/vm/assert.sh` — Assertion Library

Pure bash, no external dependencies. Each function increments a global pass/fail counter and prints the result line.

```bash
assert_exit_0         <description> <cmd...>         # command exits 0
assert_exit_nonzero   <description> <cmd...>         # command exits != 0
assert_file_exists    <description> <path>            # file exists
assert_file_missing   <description> <path>            # file does NOT exist
assert_dir_exists     <description> <path>            # directory exists
assert_contains       <description> <string> <file>   # file contains string
assert_not_contains   <description> <string> <file>   # file does NOT contain string
assert_stdout_contains <description> <string> <cmd...> # command stdout contains string
assert_eq             <description> <expected> <actual> # exact string equality
assert_files_equal    <description> <file_a> <file_b>  # identical content
assert_match          <description> <regex> <string>   # regex match
```

Each assertion prints:
- `[PASS] description` on success
- `[FAIL] description` + `Expected:` / `Got:` detail on failure

Failures do NOT abort the suite — all tests run to completion so you see the full picture.

### `tests/vm/test_install.sh` — Install Verification

**Phase 1: Run install**
- Executes `./install.sh $DISTROMAC_TEST_FLAGS`
- `assert_exit_0` on the install command

**Phase 2: Core binaries**
For each binary in `(bat lsd starship fzf rg fd jq git gh)`:
- `assert_exit_0 "<bin> is available" command -v <bin>`

**Phase 3: Optional app binaries**
For each optional app, check only if its `--no-*` flag was NOT passed:
- nvim → `command -v nvim`
- tmux → `command -v tmux`
- sketchybar → `command -v sketchybar`
- borders → `command -v borders`
- aerospace → `command -v aerospace`
- ghostty → check `/Applications/Ghostty.app` exists (installed via cask)
- raycast → check `/Applications/Raycast.app` exists (installed via cask)
- spotify → check `/Applications/Spotify.app` exists (installed via cask)

**Phase 4: Config directories**
- `assert_dir_exists` for: `~/.config/bat`, `~/.config/lsd`, `~/.config/starship`, `~/.config/distromac/current`
- Optional dirs (gated by flags): `~/.config/nvim/lua/distromac`, `~/.config/ghostty`, `~/.config/aerospace`, `~/.config/tmux` (or `~/.tmux.conf`)

**Phase 5: Theme state**
- `assert_file_exists` `~/.config/distromac/current/theme.name`
- `assert_eq` theme name matches `$DISTROMAC_THEME` (default: `catppuccin-mocha`)

### `tests/vm/test_themes.sh` — Theme Engine Deep Verification

The most thorough suite. Iterates over every built-in theme.

**For each theme in `distromac-theme-list`:**

1. **Apply theme**
   - `assert_exit_0 "theme-set $theme" distromac-theme-set $theme`

2. **Theme name stored correctly**
   - `assert_eq` `~/.config/distromac/current/theme.name` contains `$theme`

3. **Colors file staged**
   - `assert_file_exists` `~/.config/distromac/current/theme/colors.toml`

4. **No unresolved placeholders in any generated config**
   - For every file in `~/.config/distromac/current/theme/` (excluding `colors.toml` and image files):
     - Use regex `\{\{ [a-z_0-9]+ \}\}` to detect unresolved template placeholders (avoids false positives from legitimate `{{ ` in comments or config values)

5. **Color values correctly injected**
   - Parse `colors.toml` to extract all key-value pairs into an associative array
   - For each generated template output file, verify the expected color hex values from `colors.toml` appear in the output. The exact keys checked per file are based on the actual templates:
     - `ghostty.conf` → `background`, `foreground`, `cursor`, `selection_background`, `selection_foreground`, and `color0` through `color15`
     - `tmux-theme.conf` → `background`, `foreground`, `surface0`, `surface1`, `mantle`, `color1`, `color3`, `color4`, `color6`, `accent`
     - `starship.toml` → `background`, `foreground`, `mantle`, `surface0`, `surface1`, `color1`, `color2`, `color3`, `color4`, `color5`, `color6`, `color7`, `color15`
     - `borders` → `color4` (stripped, no `#`), `surface1` (stripped) — the actual template uses `{{ color4_strip }}` and `{{ surface1_strip }}`
     - `sketchybar-theme.sh` → `color1`–`color7` (stripped), `accent` (stripped), `foreground` (stripped), `surface0` (stripped), `surface1` (stripped), `mantle` (stripped), `background` (stripped), `color15` (stripped)
     - `bat` config → `bat_theme` string value (not a hex color)
     - `lsd-colors.yaml` → `color1`–`color6`, `surface1`, `foreground`, `color7`
     - `zsh-theme.zsh` → `blue`, `cyan`, `green`, `green1`, `red`, `yellow`, `magenta`, `foreground`, `overlay0` (direct hex), plus `_rgb` variants for `blue`, `cyan`, `yellow`, `green`, `red`, `magenta`, `green1`
   - **Note:** nvim does not use a template. It uses a static `nvim.lua` file provided directly by each theme directory. If `nvim.lua` exists in the theme, verify it was deployed to `~/.config/nvim/lua/distromac/theme.lua`.

6. **Configs deployed to final locations**
   - Copied files: `assert_file_exists ~/.config/bat/config`, `~/.config/lsd/colors.yaml`, `~/.config/starship/starship.toml`
   - In-place staged files: `assert_file_exists ~/.config/distromac/current/theme/zsh-theme.zsh`, `ghostty.conf`, `tmux-theme.conf`, `borders`, `sketchybar-theme.sh`
   - Optional (gated by flags): nvim → `~/.config/nvim/lua/distromac/theme.lua`

7. **Deployed files match staging**
   - Files that are **physically copied** to a separate deploy location use `assert_files_equal`:
     - `bat`: `~/.config/distromac/current/theme/bat` vs `~/.config/bat/config`
     - `lsd`: `~/.config/distromac/current/theme/lsd-colors.yaml` vs `~/.config/lsd/colors.yaml`
   - **Starship is special**: `distromac-theme-set` concatenates the base config (`config/starship/starship.toml`) with the theme palette, so the deployed file is strictly larger. Use `assert_contains` to verify the theme palette content appears within `~/.config/starship/starship.toml`.
   - Files that are **sourced in-place** from the staging dir (ghostty, tmux, borders, sketchybar, zsh-theme) do not need a files-equal check — the staging dir IS the final location. Instead, verify these files exist in `~/.config/distromac/current/theme/`.
   - `nvim.lua`: if it exists in the theme, `assert_files_equal` between `~/.config/distromac/current/theme/nvim.lua` and `~/.config/nvim/lua/distromac/theme.lua`

**Round-trip test (after individual theme tests):**
- Set theme A (first theme in list)
- Snapshot all generated config files (checksums)
- Set theme B (last theme in list)
- Set theme A again
- Verify all config checksums match the original snapshot — proves no stale state leaks

### `tests/vm/test_commands.sh` — Command Verification

Tests every script in `bin/`:

| Command | Verification |
|---|---|
| `distromac-version` | exits 0, stdout matches content of `version` file |
| `distromac-theme-list` | exits 0, output matches directory names in `themes/*/` (dynamic, not hardcoded count) |
| `distromac-theme-current` | exits 0, output matches last set theme. **Negative test:** before any theme is set, exits 1 and prints "No theme set" |
| `distromac-theme-pick` | skipped (requires interactive fzf) |
| `distromac-theme-set <name>` | already covered in test_themes.sh |
| `distromac-theme-set-templates` | skipped as standalone test — requires `next-theme/colors.toml` staging dir that only exists mid-`distromac-theme-set`. Already covered implicitly by `test_themes.sh`. |
| `distromac-refresh-config ghostty/config` | exits 0, resets a single config file to its default from `config/` (this is a per-file reset tool, NOT a theme re-application command) |
| `distromac-defaults-apply` | exits 0 (unless `--no-defaults` was passed) |
| `distromac-brew-install` | exits 0 with an already-installed package |
| `distromac-brew-missing` | exits 0, empty output (all installed) |
| `distromac-cask-install` | exits 0 with an already-installed cask |
| `distromac-cask-missing` | exits 0, empty output (all installed) |
| `distromac-hook` | exits 0 with a valid hook name (no-op if no hooks dir) |
| `distromac-migrate` | exits 0 (run with `< /dev/null` to prevent interactive `read` prompts from hanging; no pending migrations expected in a fresh VM) |
| `distromac-update` | covered in test_update.sh |
| `distromac-restart-sketchybar` | exits 0 (no-op if sketchybar not running) |
| `distromac-restart-borders` | exits 0 (no-op if borders not running) |
| `distromac-restart-aerospace` | exits 0 (no-op if aerospace not running) |
| `distromac-menu` | skipped (requires interactive terminal) |

### `tests/vm/test_update.sh` — Update Cycle

**Note:** `distromac-update` itself calls `git pull --rebase` which requires a real git remote. Since the repo is copied into the VM via rsync (not cloned), we cannot test `distromac-update` directly. Instead, we test the template re-application that update triggers, using `distromac-theme-set "$(distromac-theme-current)"`.

1. Record checksums of all deployed config files
2. Modify a template file in the repo (e.g., append a comment to `default/themed/bat.tpl`)
3. Re-apply the current theme: `distromac-theme-set "$(distromac-theme-current)"`
4. Verify the modified template produced a different output file (checksum changed)
5. Revert the template change
6. Re-apply again: `distromac-theme-set "$(distromac-theme-current)"`
7. Verify checksums match the originals — clean round-trip

## Makefile Integration

```makefile
# --- VM Tests ---
DISTROMAC_TEST_IMAGE ?= ghcr.io/cirruslabs/macos-sequoia-base:latest

.PHONY: test-vm
test-vm:
	DISTROMAC_TEST_IMAGE=$(DISTROMAC_TEST_IMAGE) \
	DISTROMAC_TEST_FLAGS="$(FLAGS)" \
	DISTROMAC_TEST_SUITE="$(SUITE)" \
	bash tests/vm/run.sh

.PHONY: test-vm-pull
test-vm-pull:
	tart pull $(DISTROMAC_TEST_IMAGE)
```

## File Layout

```
tests/
└── vm/
    ├── run.sh              # orchestrator (host-side)
    ├── suite.sh            # test runner (VM-side)
    ├── assert.sh           # assertion helpers
    ├── test_install.sh     # install verification
    ├── test_themes.sh      # theme engine deep checks
    ├── test_commands.sh    # bin/* command verification
    └── test_update.sh      # update cycle verification
```

## Error Handling

- **VM creation fails:** exit 2 with message suggesting `tart pull` or checking disk space
- **SSH timeout:** exit 2 with message about VM boot time
- **Test failure:** exit 1, all suites still run to completion (no early abort)
- **Cleanup always runs:** `trap` on EXIT ensures `tart stop + delete` regardless of how the script exits

## Limitations

- First run requires downloading the macOS image (~15 GB). Subsequent runs use the cached image.
- Each full test run takes ~10-15 minutes (VM boot + Homebrew installs).
- Cannot test GUI interactions (wallpaper changes, window management rules).
- `distromac-theme-pick` and `distromac-menu` are skipped (require interactive terminal).
