#!/usr/bin/env bash

source "${CONFIG_DIR}/theme/catppuccin.sh"

# WiFi status item - Orange/Coral for left bracket
sketchybar --add item wifi_status left \
  --set wifi_status \
  update_freq=5 \
  icon="󰤭" \
  icon.font="JetBrainsMono Nerd Font:Bold:20.0" \
  icon.color="${_SSDF_CM_ORANGE}" \
  icon.padding_left=8 \
  icon.padding_right=4 \
  label.font="JetBrainsMono Nerd Font:Bold:16.0" \
  label.color="${_SSDF_CM_SUBTEXT_1}" \
  label.padding_right=12 \
  script="$CONFIG_DIR/plugins/wifi_status.sh"
