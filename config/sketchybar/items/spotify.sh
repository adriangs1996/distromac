#!/usr/bin/env bash

source "${CONFIG_DIR}/theme/catppuccin.sh"

# Register spotify change event
sketchybar --add event spotify_change

# Next button
sketchybar --add item spotify.next right \
  --set spotify.next \
  icon="󰒭" \
  icon.font="JetBrainsMono Nerd Font:Bold:18.0" \
  icon.color="${_SSDF_CM_GREEN}" \
  icon.padding_left=4 \
  icon.padding_right=8 \
  label.drawing=off \
  click_script="osascript -e 'tell application \"Spotify\" to next track'; sleep 0.3; sketchybar --trigger spotify_change"

# Play/Pause button
sketchybar --add item spotify.play right \
  --set spotify.play \
  icon="󰐊" \
  icon.font="JetBrainsMono Nerd Font:Bold:18.0" \
  icon.color="${_SSDF_CM_GREEN}" \
  icon.padding_left=4 \
  icon.padding_right=4 \
  label.drawing=off \
  update_freq=2 \
  script="$CONFIG_DIR/plugins/spotify_play.sh" \
  click_script="osascript -e 'tell application \"Spotify\" to playpause'; sleep 0.2; sketchybar --trigger spotify_change" \
  --subscribe spotify.play spotify_change

# Previous button
sketchybar --add item spotify.prev right \
  --set spotify.prev \
  icon="󰒮" \
  icon.font="JetBrainsMono Nerd Font:Bold:18.0" \
  icon.color="${_SSDF_CM_GREEN}" \
  icon.padding_left=8 \
  icon.padding_right=4 \
  label.drawing=off \
  click_script="osascript -e 'tell application \"Spotify\" to previous track'; sleep 0.3; sketchybar --trigger spotify_change"

# Track info
sketchybar --add item spotify.track right \
  --set spotify.track \
  icon="" \
  icon.color="${_SSDF_CM_GREEN}" \
  icon.padding_left=12 \
  icon.padding_right=6 \
  label.color="${_SSDF_CM_SUBTEXT_1}" \
  label.width=60 \
  update_freq=1 \
  script="$CONFIG_DIR/plugins/spotify.sh" \
  click_script="open -a Spotify" \
  --subscribe spotify.track spotify_change
