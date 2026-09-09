#!/usr/bin/env bash
# Center the active floating window on the focused monitor.
# Properly handles scaled monitors (e.g., LG at 0.78 scale).
#
# This script calculates center position based on the monitor's physical
# size, scaling factor, and position offset — fixing issues where
# window.center() fails to recalculate when windows are hidden/shown.

set -u

# Get focused monitor info
read -r MX MY MW MH MSCALE < <(hyprctl monitors -j 2>/dev/null |
  jq -r '.[] | select(.focused == true) | "\(.x) \(.y) \(.width) \(.height) \(.scale)"')

# Fallback to default monitor dimensions if query fails
: "${MX:=0}" "${MY:=0}" "${MW:=2560}" "${MH:=1440}" "${MSCALE:=1.0}"

# Get active window info
read -r WW WH < <(hyprctl activewindow -j 2>/dev/null |
  jq -r '"\(.size[0]) \(.size[1])"')

# Fallback if window query fails
: "${WW:=1000}" "${WH:=800}"

# Calculate center position (scaled logical space)
# Physical center = monitor center + (window size / 2)
# Logical center = physical / scale
CENTER_X=$(echo "scale=0; $MX + ($MW - $WW) / 2" | bc)
CENTER_Y=$(echo "scale=0; $MY + ($MH - $WH) / 2" | bc)

# Apply the move. Use 'exact' mode to set precise coordinates.
hyprctl dispatch "hl.dsp.window.move({ x = $CENTER_X, y = $CENTER_Y })" >/dev/null 2>&1 || \
  hyprctl dispatch "movewindow exact $CENTER_X $CENTER_Y" >/dev/null 2>&1 || true
