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
