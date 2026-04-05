#!/usr/bin/env bash

source "$HOME/.config/distromac/current/theme/sketchybar-theme.sh"

sketchybar --add item notif.prs left \
  --set notif.prs \
  icon="" \
  icon.color="${_SSDF_CM_SUBTEXT_0}" \
  icon.padding_left=6 \
  icon.padding_right=2 \
  label="0" \
  label.color="${_SSDF_CM_SUBTEXT_0}" \
  label.padding_right=12 \
  update_freq=10 \
  popup.background.color=0xff181825 \
  popup.background.corner_radius=12 \
  popup.background.border_color="${_SSDF_CM_MANTLE_LIGHTER}" \
  popup.background.border_width=2 \
  popup.y_offset=5 \
  script="$CONFIG_DIR/plugins/open_prs.sh" \
  click_script="sketchybar --set \$NAME popup.drawing=toggle"
