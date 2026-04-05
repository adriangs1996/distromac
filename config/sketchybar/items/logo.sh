#!/usr/bin/env bash

source "${CONFIG_DIR}/theme/catppuccin.sh"

sketchybar --add item logo left \
  --set logo \
  icon="" \
  icon.color="${_SSDF_CM_TEAL}" \
  icon.padding_left=12 \
  icon.padding_right=8 \
  label.drawing=off \
  background.drawing=off

sketchybar --add item separator left \
  --set separator \
  icon="󰇙" \
  icon.color="${_SSDF_CM_SUBTEXT_0}" \
  icon.padding_left=4 \
  icon.padding_right=4 \
  label.drawing=off \
  background.drawing=off
