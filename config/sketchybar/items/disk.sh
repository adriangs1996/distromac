#!/usr/bin/env bash
source "${CONFIG_DIR}/theme/catppuccin.sh"

COLOR="${_SSDF_CM_GREEN}"

sketchybar --add item "disk-sep" right \
  --set "disk-sep" \
  icon="/" \
  icon.color="$COLOR" \
  label.color="$COLOR"

sketchybar --add item disk right \
  --set disk \
  update_freq=60 \
  icon.color="$COLOR" \
  label.color="$COLOR" \
  script="$CONFIG_DIR/plugins/disk.sh"
