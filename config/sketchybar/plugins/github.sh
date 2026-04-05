#!/usr/bin/env bash

source "${CONFIG_DIR}/theme/catppuccin.sh"

# Get GitHub notification count using gh CLI
COUNT=$(gh api notifications 2>/dev/null | jq '. | length' 2>/dev/null)

if [ -z "$COUNT" ] || [ "$COUNT" = "null" ]; then
  COUNT=0
fi

if [ "$COUNT" -gt 0 ]; then
  sketchybar --set "$NAME" \
    icon="" \
    label="$COUNT" \
    icon.color="${_SSDF_CM_MAUVE}" \
    label.color="${_SSDF_CM_SUBTEXT_1}"
else
  sketchybar --set "$NAME" \
    icon="" \
    label="0" \
    icon.color="${_SSDF_CM_SUBTEXT_0}" \
    label.color="${_SSDF_CM_SUBTEXT_0}"
fi
