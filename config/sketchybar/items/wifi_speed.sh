#!/usr/bin/env bash

source "$HOME/.config/distromac/current/theme/sketchybar-theme.sh"

sketchybar --add item wifi_speed right \
  --set wifi_speed \
  update_freq=2 \
  icon="󰤨" \
  icon.color="${_SSDF_CM_TEAL}" \
  icon.padding_left=8 \
  icon.padding_right=4 \
  label="0 K" \
  label.color="${_SSDF_CM_SUBTEXT_1}" \
  label.padding_right=8 \
  script="$CONFIG_DIR/plugins/wifi_speed.sh"
