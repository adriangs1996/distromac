#!/usr/bin/env bash

# Get network throughput - check ethernet interfaces first, then wifi
for INTERFACE in en5 en3 en4 en0; do
  STATUS=$(ifconfig "$INTERFACE" 2>/dev/null | grep "status: active")
  if [ -n "$STATUS" ]; then
    break
  fi
done

# Get current bytes received
BYTES_IN=$(netstat -ibn | grep -e "$INTERFACE" | head -1 | awk '{print $7}')

# Store previous value
PREV_FILE="/tmp/sketchybar_net_prev"
if [ -f "$PREV_FILE" ]; then
  PREV_BYTES=$(cat "$PREV_FILE")
else
  PREV_BYTES=$BYTES_IN
fi

echo "$BYTES_IN" > "$PREV_FILE"

# Calculate difference (bytes per update interval)
DIFF=$((BYTES_IN - PREV_BYTES))
if [ $DIFF -lt 0 ]; then
  DIFF=0
fi

# Convert to KB/s (update_freq is 2 seconds)
SPEED=$((DIFF / 2 / 1024))

if [ $SPEED -gt 1024 ]; then
  SPEED_MB=$(echo "scale=1; $SPEED / 1024" | bc)
  LABEL="${SPEED_MB} M"
else
  LABEL="${SPEED} K"
fi

sketchybar --set "$NAME" label="$LABEL"
