#!/usr/bin/env bash

source "$HOME/.config/distromac/current/theme/sketchybar-theme.sh"

# Memory item - Yellow
sketchybar --add item mem left \
  --set mem \
  update_freq=2 \
  icon="" \
  icon.color="${_SSDF_CM_TEAL}" \
  icon.padding_left=8 \
  icon.padding_right=4 \
  label.color="${_SSDF_CM_SUBTEXT_1}" \
  label.padding_right=8 \
  script="$CONFIG_DIR/plugins/mem.sh"

# Disk item - Green
sketchybar --add item disk left \
  --set disk \
  update_freq=30 \
  icon="" \
  icon.color="${_SSDF_CM_GREEN}" \
  icon.padding_left=8 \
  icon.padding_right=4 \
  label.color="${_SSDF_CM_SUBTEXT_1}" \
  label.padding_right=8 \
  script="$CONFIG_DIR/plugins/disk.sh"
