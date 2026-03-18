#!/usr/bin/env bash

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

LABEL=$(date '+%H:%M:%S')
sketchybar --set "$NAME" label="$LABEL"
