#!/bin/bash
# Monitor XP-Pen M708 express keys K9 and K10
# This script detects button presses and sends Page Up/Down

# Function to send Page Up
send_page_up() {
    if command -v wtype &> /dev/null; then
        wtype Prior
    elif command -v ydotool &> /dev/null; then
        ydotool key 112:1 112:0  # Page Up scancode
    else
        echo "Error: Need wtype or ydotool installed"
        exit 1
    fi
}

# Function to send Page Down  
send_page_down() {
    if command -v wtype &> /dev/null; then
        wtype Next
    elif command -v ydotool &> /dev/null; then
        ydotool key 117:1 117:0  # Page Down scancode
    else
        echo "Error: Need wtype or ydotool installed"
        exit 1
    fi
}

# Monitor device events
# Note: This is a workaround for buttons showing -1 key code
# You may need to adjust timing/threshold based on your tablet

libinput debug-events --device /dev/input/event10 2>&1 | while IFS= read -r line; do
    # Look for button press events (even with -1 code)
    if echo "$line" | grep -q "KEYBOARD_KEY.*pressed"; then
        # Try to detect which button by timing or pattern
        # This is a simplified approach - you may need to refine this
        # based on testing which button press corresponds to K9 vs K10
        
        # For now, we'll use a simple counter approach
        # You'll need to test and adjust which is K9 and which is K10
        timestamp=$(date +%s%N)
        
        # Store last press time to differentiate buttons
        if [ -z "$last_press_time" ]; then
            last_press_time=$timestamp
            send_page_up  # Assume first press is K9
        else
            time_diff=$((timestamp - last_press_time))
            if [ $time_diff -lt 1000000000 ]; then  # Less than 1 second
                send_page_down  # Second press is K10
            else
                send_page_up  # New sequence, first is K9
            fi
            last_press_time=$timestamp
        fi
    fi
done
