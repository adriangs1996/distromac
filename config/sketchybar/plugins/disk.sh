#!/usr/bin/env bash
source "$HOME/.config/distromac/current/theme/sketchybar-theme.sh"

# Get available disk space in GiB format (like waybar)
AVAILABLE=$(df -Pk / | tail -1 | awk '{print $4}')
AVAILABLE_GB=$(echo "scale=2; $AVAILABLE / 1048576" | bc)

sketchybar --set "$NAME" label="${AVAILABLE_GB} GiB" icon="" icon.color="$_SSDF_CM_YELLOW"
