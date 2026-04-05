#!/usr/bin/env bash

source "${CONFIG_DIR}/theme/catppuccin.sh"

POPUP_OFF="sketchybar --set power popup.drawing=off"

# Main power button
sketchybar --add item power right \
  --set power \
  icon="󰐥" \
  icon.font="JetBrainsMono Nerd Font:Bold:30.0" \
  icon.color="${_SSDF_CM_RED}" \
  icon.padding_left=8 \
  icon.padding_right=8 \
  label.drawing=off \
  popup.background.color="${_SSDF_CM_MANTLE_LIGHTER}" \
  popup.background.corner_radius=8 \
  popup.background.border_width=2 \
  popup.background.border_color="${_SSDF_CM_SURFACE_2}" \
  popup.blur_radius=20 \
  popup.align=right \
  click_script="sketchybar --set power popup.drawing=toggle"

# Popup items
power_popup=(
  background.color="${TRANSPARENT}"
  background.corner_radius=5
  background.height=30
  width=200
  icon.font="JetBrainsMono Nerd Font:Bold:16.0"
  icon.color="${_SSDF_CM_SUBTEXT_1}"
  icon.padding_left=10
  icon.padding_right=5
  label.font="JetBrainsMono Nerd Font:Bold:12.0"
  label.color="${_SSDF_CM_SUBTEXT_1}"
  label.padding_left=5
  label.padding_right=10
)

# Lock
sketchybar --add item power.lock popup.power \
  --set power.lock "${power_popup[@]}" \
  icon="󰌾" \
  icon.color="${_SSDF_CM_BLUE}" \
  label="Lock" \
  click_script="pmset displaysleepnow; $POPUP_OFF"

# Sleep
sketchybar --add item power.sleep popup.power \
  --set power.sleep "${power_popup[@]}" \
  icon="󰒲" \
  icon.color="${_SSDF_CM_TEAL}" \
  label="Sleep" \
  click_script="pmset sleepnow; $POPUP_OFF"

# Restart
sketchybar --add item power.restart popup.power \
  --set power.restart "${power_popup[@]}" \
  icon="󰜉" \
  icon.color="${_SSDF_CM_ORANGE}" \
  label="Restart" \
  click_script="osascript -e 'tell app \"System Events\" to restart'; $POPUP_OFF"

# Shutdown
sketchybar --add item power.shutdown popup.power \
  --set power.shutdown "${power_popup[@]}" \
  icon="󰐥" \
  icon.color="${_SSDF_CM_RED}" \
  label="Shutdown" \
  click_script="osascript -e 'tell app \"System Events\" to shut down'; $POPUP_OFF"

# Logout
sketchybar --add item power.logout popup.power \
  --set power.logout "${power_popup[@]}" \
  icon="󰍃" \
  icon.color="${_SSDF_CM_MAUVE}" \
  label="Logout" \
  click_script="osascript -e 'tell app \"System Events\" to log out'; $POPUP_OFF"
