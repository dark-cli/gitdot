#!/bin/bash
# Script to detect tablet express key codes
# Press K9 and K10 buttons to see their key codes

echo "=========================================="
echo "Tablet Key Code Detector"
echo "=========================================="
echo ""
echo "Press your K9 button now..."
echo "Then press your K10 button..."
echo "Press Ctrl+C to stop"
echo ""
echo "Looking for key codes..."
echo ""

libinput debug-events --device /dev/input/event10 2>&1 | grep --line-buffered "KEYBOARD_KEY" | while read line; do
    echo "$line"
done
