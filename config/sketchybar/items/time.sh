#!/usr/bin/env bash

source "${CONFIG_DIR}/theme/catppuccin.sh"

sketchybar --add item clock right \
  --set clock \
  update_freq=1 \
  icon="󱑍" \
  icon.color="${_SSDF_CM_BLUE}" \
  icon.padding_left=8 \
  icon.padding_right=4 \
  label.color="${_SSDF_CM_SUBTEXT_1}" \
  label.padding_right=8 \
  script="$CONFIG_DIR/plugins/clock.sh"
