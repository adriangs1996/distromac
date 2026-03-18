#!/usr/bin/env bash

source "$HOME/.config/distromac/current/theme/sketchybar-theme.sh"

sketchybar --add item battery right \
  --set battery \
  update_freq=60 \
  icon="" \
  icon.color="${_SSDF_CM_GREEN}" \
  icon.padding_left=8 \
  icon.padding_right=4 \
  label.color="${_SSDF_CM_SUBTEXT_1}" \
  label.padding_right=8 \
  script="$CONFIG_DIR/plugins/power.sh" \
  --subscribe battery power_source_change
