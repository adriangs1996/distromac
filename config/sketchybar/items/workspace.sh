#!/usr/bin/env bash
# items/workspace.sh — single workspace number in the center island

source "${CONFIG_DIR}/theme/catppuccin.sh"

sketchybar --add event aerospace_workspace_change

sketchybar --add item ws_number center \
  --set ws_number \
  icon="󰍹" \
  icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
  icon.color="${_SSDF_CM_BLUE}" \
  icon.padding_left=10 \
  icon.padding_right=4 \
  label.font="JetBrainsMono Nerd Font:Bold:14.0" \
  label.color="${_SSDF_CM_SUBTEXT_1}" \
  label.padding_right=8 \
  background.color="${_SSDF_CM_SURFACE_0}" \
  background.corner_radius=10 \
  background.height=26 \
  background.drawing=on \
  script="$CONFIG_DIR/plugins/workspace.sh" \
  --subscribe ws_number aerospace_workspace_change
