#!/usr/bin/env bash

source "${CONFIG_DIR}/theme/catppuccin.sh"

# Check if Spotify is running
if ! pgrep -x "Spotify" > /dev/null; then
  sketchybar --set "$NAME" icon="󰐊" icon.color=0xff666666
  exit 0
fi

# Get player state
STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)

if [ "$STATE" = "playing" ]; then
  sketchybar --set "$NAME" icon="󰏤" icon.color="${_SSDF_CM_GREEN}"
else
  sketchybar --set "$NAME" icon="󰐊" icon.color="${_SSDF_CM_GREEN}"
fi
