#!/usr/bin/env bash
# plugins/tmux.sh — queries tmux for sessions and builds labels

source "${CONFIG_DIR}/theme/catppuccin.sh"

MAX_LABEL_LEN=50

sessions=$(tmux list-sessions -F '#{session_name}:#{session_attached}:#{window_name}' 2>/dev/null)

if [[ -z "$sessions" ]]; then
  sketchybar --set tmux_sessions \
    label="○ no sessions" \
    label.color="${_SSDF_CM_OVERLAY_0}"
  sketchybar --set tmux_window drawing=off
  exit 0
fi

label=""
active_window=""
has_attached=0

while IFS=':' read -r name attached window; do
  if [[ "$attached" == "1" ]]; then
    label="${label}● ${name}  "
    active_window="$window"
    has_attached=1
  else
    label="${label}○ ${name}  "
  fi
done <<< "$sessions"

# Trim trailing spaces
label="${label%  }"

# Truncate if too long
if [[ ${#label} -gt $MAX_LABEL_LEN ]]; then
  label="${label:0:$MAX_LABEL_LEN}…"
fi

# Set label color: green if attached session exists, gray otherwise
if [[ "$has_attached" == "1" ]]; then
  sketchybar --set tmux_sessions label="$label" label.color="${_SSDF_CM_GREEN}"
else
  sketchybar --set tmux_sessions label="$label" label.color="${_SSDF_CM_OVERLAY_0}"
fi

if [[ -n "$active_window" ]]; then
  sketchybar --set tmux_window label="$active_window" drawing=on
else
  sketchybar --set tmux_window drawing=off
fi
