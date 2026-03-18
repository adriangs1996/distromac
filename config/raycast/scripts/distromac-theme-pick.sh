#!/usr/bin/env bash
set -eEo pipefail

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Pick Theme
# @raycast.mode compact
# @raycast.packageName distromac

# Optional parameters:
# @raycast.icon 🎨
# @raycast.argument1 { "type": "text", "placeholder": "Theme name" }

# Documentation:
# @raycast.description Select and apply a distromac theme. Press Ctrl+T to open.
# @raycast.author Adrian Gonzalez

DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.distromac}"
export PATH="$DISTROMAC_PATH/bin:$PATH"

theme="$1"

if [[ -z $theme ]]; then
  echo "No theme selected. Available: $(distromac-theme-list | tr '\n' ' ')"
  exit 1
fi

distromac-theme-set "$theme"
echo "Theme set to: $theme"
