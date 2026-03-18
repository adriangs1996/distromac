#!/usr/bin/env bash
## ─────────────────────────────────────────────────────────────────────────────
## Displays the hostname.
## ─────────────────────────────────────────────────────────────────────────────
_SSDF_SB_HOSTNAME=$(hostname)
sketchybar --set "$NAME" label="${_SSDF_SB_HOSTNAME}"
