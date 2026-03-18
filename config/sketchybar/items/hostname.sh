#!/usr/bin/env bash
## ─────────────────────────────────────────────────────────────────────────────
## Displays hostname.
##
## Using `\\uf179` (nf-fa-apple) icon.
## ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item hostname left
sketchybar --set hostname icon="" script="${CONFIG_DIR}/plugins/hostname.sh"
