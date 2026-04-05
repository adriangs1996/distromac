#!/usr/bin/env bash

source "$HOME/.config/distromac/current/theme/sketchybar-theme.sh"

sketchybar --add item volume right \
  --set volume \
  icon="󰖁" \
  icon.color="${_SSDF_CM_TEAL}" \
  icon.padding_left=8 \
  icon.padding_right=4 \
  label="Muted" \
  label.color="${_SSDF_CM_SUBTEXT_1}" \
  label.padding_right=8 \
  script="$CONFIG_DIR/plugins/volume.sh" \
  --subscribe volume volume_change
