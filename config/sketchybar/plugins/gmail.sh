#!/usr/bin/env bash

source "${CONFIG_DIR}/theme/catppuccin.sh"

# Gmail credentials file (create this with your email and app password)
CREDENTIALS_FILE="$HOME/.config/sketchybar/gmail_credentials"

# Check if credentials file exists
if [ -f "$CREDENTIALS_FILE" ]; then
  # Read credentials (format: email:app_password)
  GMAIL_CREDS=$(cat "$CREDENTIALS_FILE")

  # Fetch unread count from Gmail Atom feed
  COUNT=$(curl -su "$GMAIL_CREDS" "https://mail.google.com/mail/feed/atom" 2>/dev/null | grep -o "<fullcount>[0-9]*</fullcount>" | grep -o "[0-9]*")

  if [ -z "$COUNT" ]; then
    COUNT=0
  fi
else
  # No credentials - try Apple Mail
  COUNT=$(osascript -e 'tell application "Mail" to return unread count of inbox' 2>/dev/null)
  if [ -z "$COUNT" ]; then
    COUNT="?"
  fi
fi

if [ "$COUNT" != "?" ] && [ "$COUNT" -gt 0 ] 2>/dev/null; then
  sketchybar --set "$NAME" \
    label="$COUNT" \
    icon.color="${_SSDF_CM_RED}" \
    label.color="${_SSDF_CM_SUBTEXT_1}"
else
  sketchybar --set "$NAME" \
    label="$COUNT" \
    icon.color="${_SSDF_CM_SUBTEXT_0}" \
    label.color="${_SSDF_CM_SUBTEXT_0}"
fi
