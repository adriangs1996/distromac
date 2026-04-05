#!/usr/bin/env bash

source "${CONFIG_DIR}/theme/catppuccin.sh"

COLOR="${_SSDF_CM_ORANGE}"

sketchybar --add item cpu left \
  --set cpu \
  update_freq=2 \
  icon="" \
  icon.color="${COLOR}" \
  icon.padding_left=10 \
  icon.padding_right=4 \
  label.color="${_SSDF_CM_SUBTEXT_1}" \
  label.padding_right=8 \
  script="$CONFIG_DIR/plugins/cpu.sh"
