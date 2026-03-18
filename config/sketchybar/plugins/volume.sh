#!/usr/bin/env bash

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  case "$VOLUME" in
    [6-9][0-9]|100)
      ICON="󰕾"
      LABEL="$VOLUME%"
      ;;
    [3-5][0-9])
      ICON="󰖀"
      LABEL="$VOLUME%"
      ;;
    [1-9]|[1-2][0-9])
      ICON="󰕿"
      LABEL="$VOLUME%"
      ;;
    *)
      ICON="󰖁"
      LABEL="Muted"
      ;;
  esac

  sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
fi
