#!/bin/bash
# Sync tablet transform with monitor profile on startup
# Checks monitors.conf for 270° or 90° rotation and sets tablet transform accordingly

monitors_conf="$HOME/.config/hypr/monitors.conf"

# Check if monitors.conf contains 270° transform (transform, 3) or 90° transform (transform, 1)
# When monitor is rotated 270° or 90°, set tablet to 90° rotation (transform = 1)
# Otherwise, set tablet to normal (transform = 0)
if grep -qE "(transform.*[[:space:]]*3|#.*270)" "$monitors_conf" 2>/dev/null || grep -qE "(transform.*[[:space:]]*1|#.*rotated.*90)" "$monitors_conf" 2>/dev/null; then
    hyprctl keyword input:tablet:transform 1
else
    hyprctl keyword input:tablet:transform 0
fi
