#!/usr/bin/env bash
# items/tmux.sh — tmux sessions and active window items for center island

source "${CONFIG_DIR}/theme/catppuccin.sh"

# Tmux sessions segment (middle of segmented bar)
sketchybar --add item tmux_sessions center \
  --set tmux_sessions \
  icon.drawing=off \
  label="○ no sessions" \
  label.font="JetBrainsMono Nerd Font:Bold:12.0" \
  label.color="${_SSDF_CM_OVERLAY_0}" \
  label.padding_left=10 \
  label.padding_right=10 \
  update_freq=5 \
  script="$CONFIG_DIR/plugins/tmux.sh"

# Active window segment (right end of segmented bar)
sketchybar --add item tmux_window center \
  --set tmux_window \
  icon.drawing=off \
  label="zsh" \
  label.font="JetBrainsMono Nerd Font:Bold:11.0" \
  label.color="${_SSDF_CM_SURFACE_2}" \
  label.padding_left=8 \
  label.padding_right=10 \
  background.color="${_SSDF_CM_SURFACE_0}" \
  background.corner_radius=10 \
  background.height=26 \
  background.drawing=on \
  drawing=off
