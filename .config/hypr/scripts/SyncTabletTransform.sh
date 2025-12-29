#!/bin/bash
# Sync tablet transform with monitor profile on startup
# Checks monitors.conf for 270° rotation and sets tablet transform accordingly

monitors_conf="$HOME/.config/hypr/monitors.conf"

# Check if monitors.conf contains 270° transform (transform, 3)
if grep -q "transform.*3\|270" "$monitors_conf" 2>/dev/null; then
    hyprctl keyword input:tablet:transform 3
else
    hyprctl keyword input:tablet:transform 0
fi
