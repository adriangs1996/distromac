#!/usr/bin/env bash

# Check WiFi first
WIFI_SSID=$(networksetup -getairportnetwork en0 2>/dev/null | grep -v "not associated" | cut -d: -f2 | xargs)

if [ -n "$WIFI_SSID" ]; then
  sketchybar --set "$NAME" icon="󰤨" label="$WIFI_SSID"
  exit 0
fi

# Check if connected via Ethernet
ETHERNET_STATUS=$(ifconfig en3 2>/dev/null | grep "status: active")
ETHERNET_STATUS2=$(ifconfig en4 2>/dev/null | grep "status: active")
ETHERNET_STATUS3=$(ifconfig en5 2>/dev/null | grep "status: active")

if [ -n "$ETHERNET_STATUS" ] || [ -n "$ETHERNET_STATUS2" ] || [ -n "$ETHERNET_STATUS3" ]; then
  sketchybar --set "$NAME" icon="󰈀" label="Ethernet"
  exit 0
fi

# Not connected
sketchybar --set "$NAME" icon="󰤭" label="Disconnected"
