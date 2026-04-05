#!/usr/bin/env bash

source "$HOME/.config/distromac/current/theme/sketchybar-theme.sh"

# Fetch open PRs authored by me across all repos
PRS=$(gh search prs --author @me --state open --json number,repository,url,title 2>/dev/null)

if [ -z "$PRS" ] || [ "$PRS" = "null" ] || [ "$PRS" = "[]" ]; then
  sketchybar --set "$NAME" \
    icon="" \
    label="0 PRs" \
    icon.color="${_SSDF_CM_SUBTEXT_0}" \
    label.color="${_SSDF_CM_SUBTEXT_0}"

  # Remove any existing popup items
  sketchybar --remove '/pr\.item\..*/' 2>/dev/null
  exit 0
fi

COUNT=$(echo "$PRS" | jq 'length')

# Update the main item
sketchybar --set "$NAME" \
  icon="" \
  label="$COUNT PRs" \
  icon.color="${_SSDF_CM_GREEN}" \
  label.color="${_SSDF_CM_SUBTEXT_1}"

# Remove old popup items
sketchybar --remove '/pr\.item\..*/' 2>/dev/null

# Add each PR as a popup item
INDEX=0
echo "$PRS" | jq -c '.[]' | while read -r PR; do
  NUMBER=$(echo "$PR" | jq -r '.number')
  REPO=$(echo "$PR" | jq -r '.repository.name')
  URL=$(echo "$PR" | jq -r '.url')
  TITLE=$(echo "$PR" | jq -r '.title' | cut -c1-30)

  ITEM_NAME="pr.item.${INDEX}"

  sketchybar --add item "$ITEM_NAME" popup.notif.prs \
    --set "$ITEM_NAME" \
    icon="" \
    icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
    icon.color="${_SSDF_CM_GREEN}" \
    icon.padding_left=8 \
    icon.padding_right=4 \
    label="${REPO}#${NUMBER} ${TITLE}" \
    label.font="JetBrainsMono Nerd Font:Regular:12.0" \
    label.color="${_SSDF_CM_SUBTEXT_1}" \
    label.padding_right=8 \
    background.color="${_SSDF_CM_MANTLE_LIGHTER}" \
    background.corner_radius=8 \
    background.height=28 \
    background.drawing=on \
    background.padding_left=4 \
    background.padding_right=4 \
    click_script="open '$URL'; sketchybar --set notif.prs popup.drawing=off"

  INDEX=$((INDEX + 1))
done
