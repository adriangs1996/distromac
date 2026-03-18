#!/usr/bin/env bash

# Background scroll daemon for Spotify
# Run this to enable smooth 300ms scrolling

while true; do
  if pgrep -x "sketchybar" >/dev/null; then
    sketchybar --trigger spotify_change 2>/dev/null
  else
    exit 0
  fi
  sleep 0.1
done
