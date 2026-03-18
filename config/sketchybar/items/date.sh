#!/usr/bin/env bash

source "$HOME/.config/distromac/current/theme/sketchybar-theme.sh"

sketchybar --add item calendar right \
  --set calendar \
  update_freq=60 \
  icon="" \
  icon.color="${_SSDF_CM_MAUVE}" \
  icon.padding_left=8 \
  icon.padding_right=4 \
  label.color="${_SSDF_CM_SUBTEXT_1}" \
  label.padding_right=8 \
  script="$CONFIG_DIR/plugins/date.sh"
