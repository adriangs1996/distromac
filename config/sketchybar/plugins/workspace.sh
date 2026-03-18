#!/usr/bin/env bash
# plugins/workspace.sh — returns the focused AeroSpace workspace number

WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
sketchybar --set "$NAME" label="${WORKSPACE:-?}"
