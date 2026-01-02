#!/bin/bash
# Advanced detection for XP-Pen express keys
# This will show more details about the button presses

echo "Press K9 button, then K10 button..."
echo "Watch for timing differences or patterns..."
echo "Press Ctrl+C to stop"
echo ""

counter=0
libinput debug-events --device /dev/input/event10 2>&1 | while IFS= read -r line; do
    if echo "$line" | grep -q "KEYBOARD_KEY"; then
        counter=$((counter + 1))
        timestamp=$(date +%s.%N)
        if echo "$line" | grep -q "pressed"; then
            echo "[$counter] PRESS detected at $timestamp"
            echo "   Full event: $line"
        elif echo "$line" | grep -q "released"; then
            echo "[$counter] RELEASE detected at $timestamp"
        fi
    fi
done
