#!/usr/bin/env bash

source "$HOME/.config/distromac/current/theme/sketchybar-theme.sh"

sketchybar --add event aerospace_workspace_change

# Define colors for workspace dots
WORKSPACE_COLORS=(
  "${_SSDF_WS_ORANGE}" # Workspace 1
  "${_SSDF_WS_GREEN}"  # Workspace 2
  "${_SSDF_WS_CYAN}"   # Workspace 3
  "${_SSDF_WS_PURPLE}" # Workspace 4
  "${_SSDF_WS_ORANGE}" # Workspace 5
  "${_SSDF_WS_GREEN}"  # Workspace 6
  "${_SSDF_WS_CYAN}"   # Workspace 7
)

# Get workspace count
_SSDF_WS_INDEX=0
for _SSDF_WS_ID in $(aerospace list-workspaces --monitor focused); do
  # Get color for this workspace (cycle through colors)
  COLOR_INDEX=$((_SSDF_WS_INDEX % ${#WORKSPACE_COLORS[@]}))
  WS_COLOR="${WORKSPACE_COLORS[$COLOR_INDEX]}"

  sketchybar --add item "workspace.${_SSDF_WS_ID}" center
  sketchybar --subscribe "workspace.${_SSDF_WS_ID}" aerospace_workspace_change front_app_switched
  sketchybar --set "workspace.${_SSDF_WS_ID}" \
    label.drawing=off \
    icon.padding_left=20 \
    icon.padding_right=20 \
    icon="" \
    icon.color="${_SSDF_CM_SUBTEXT_0}" \
    icon.background.drawing=off \
    icon.background.image.scale=0.7 \
    background.drawing=off \
    click_script="aerospace workspace ${_SSDF_WS_ID}" \
    script="${CONFIG_DIR}/plugins/workspaces.sh ${_SSDF_WS_ID} ${WS_COLOR}"

  ((_SSDF_WS_INDEX++))
done
