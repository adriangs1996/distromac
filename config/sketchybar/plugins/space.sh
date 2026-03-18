#!/usr/bin/env bash

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item
#

FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
used_spaces=$(aerospace list-workspaces --monitor focused --empty no)

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  icon="󰮯"
  color="0xfff9e2af"
elif [[ ${used_spaces[@]} =~ "$1" ]]; then
  icon="󰊠"
  color="0xffcba6f7"
else
  icon="󰊠"
  color=0xff74c7ec
  # color=0xffA6E3A1
fi

sketchybar --set "$NAME" icon="$icon" icon.color="$color"
