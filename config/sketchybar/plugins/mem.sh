#!/usr/bin/env bash

# Get memory usage in GiB format (like waybar)
TOTAL_MEM=$(sysctl -n hw.memsize)
TOTAL_MEM_GB=$(echo "scale=2; $TOTAL_MEM / 1073741824" | bc)

# Get used memory via vm_stat
PAGES_FREE=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')
PAGES_WIRED=$(vm_stat | grep "Pages wired down" | awk '{print $4}' | tr -d '.')
PAGES_ACTIVE=$(vm_stat | grep "Pages active" | awk '{print $3}' | tr -d '.')
PAGES_COMPRESSED=$(vm_stat | grep "Pages occupied by compressor" | awk '{print $5}' | tr -d '.')

# Page size is 4096 bytes on macOS
PAGE_SIZE=4096

# Calculate used memory (active + wired + compressed)
USED_PAGES=$((PAGES_ACTIVE + PAGES_WIRED + PAGES_COMPRESSED))
USED_BYTES=$((USED_PAGES * PAGE_SIZE))
USED_GB=$(echo "scale=2; $USED_BYTES / 1073741824" | bc)

sketchybar --set "$NAME" label="${USED_GB} GiB"
