#!/usr/bin/env bash

# Get CPU usage percentage
CPU=$(ps -A -o %cpu | awk '{s+=$1} END {s /= 8} END {printf "%.0f%%\n", s}')

sketchybar --set "$NAME" label="$CPU"
