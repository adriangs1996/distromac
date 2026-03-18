#!/usr/bin/env bash

MAX_LENGTH=20
SCROLL_SPEED=1
STATE_FILE="/tmp/sketchybar_spotify_scroll"

# Check if Spotify is running
if ! pgrep -x "Spotify" > /dev/null; then
  sketchybar --set "$NAME" label="Not Playing" icon.color=0xff666666
  rm -f "$STATE_FILE" 2>/dev/null
  exit 0
fi

# Get player state
STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)

if [ "$STATE" = "playing" ] || [ "$STATE" = "paused" ]; then
  TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
  ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)

  if [ -n "$TRACK" ] && [ -n "$ARTIST" ]; then
    FULL_TEXT="${ARTIST} - ${TRACK}"
    TEXT_LENGTH=${#FULL_TEXT}

    if [ "$TEXT_LENGTH" -gt "$MAX_LENGTH" ]; then
      # Add spacing for continuous scroll
      SCROLL_TEXT="${FULL_TEXT}     ${FULL_TEXT}"

      # Read current position
      if [ -f "$STATE_FILE" ]; then
        read -r POS PREV_TEXT < "$STATE_FILE"
        # Reset position if song changed
        if [ "$PREV_TEXT" != "$FULL_TEXT" ]; then
          POS=0
        fi
      else
        POS=0
      fi

      # Extract visible portion
      DISPLAY_TEXT="${SCROLL_TEXT:$POS:$MAX_LENGTH}"

      # Update position for next iteration
      NEXT_POS=$((POS + SCROLL_SPEED))
      if [ "$NEXT_POS" -ge "$((TEXT_LENGTH + 5))" ]; then
        NEXT_POS=0
      fi

      # Save state
      echo "$NEXT_POS $FULL_TEXT" > "$STATE_FILE"

      sketchybar --set "$NAME" label="$DISPLAY_TEXT"
    else
      sketchybar --set "$NAME" label="$FULL_TEXT"
      rm -f "$STATE_FILE" 2>/dev/null
    fi
  else
    sketchybar --set "$NAME" label="Not Playing"
  fi
else
  sketchybar --set "$NAME" label="Not Playing"
fi
