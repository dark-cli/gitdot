#!/bin/bash
# Control window gaps dynamically
# Usage: GapControl.sh [inc|dec|reset]

action="$1"

# Get current gap values (handle both int and custom formats)
current_in=$(hyprctl getoption general:gaps_in -j | jq -r 'if .int then .int else (.custom | split(" ") | .[0] | tonumber) end')
current_out=$(hyprctl getoption general:gaps_out -j | jq -r 'if .int then .int else (.custom | split(" ") | .[0] | tonumber) end')

# Default/reset values
default_in=30
default_out=30

# Step size for increment/decrement
step=10

case "$action" in
    inc)
        # Increase gaps
        new_in=$((current_in + step))
        new_out=$((current_out + step))
        hyprctl keyword general:gaps_in $new_in
        hyprctl keyword general:gaps_out $new_out
        notify-send -u low -t 1000 "Gaps Increased" "In: $new_in | Out: $new_out"
        ;;
    dec)
        # Decrease gaps (minimum 0)
        new_in=$((current_in - step))
        new_out=$((current_out - step))
        if [ $new_in -lt 0 ]; then
            new_in=0
        fi
        if [ $new_out -lt 0 ]; then
            new_out=0
        fi
        hyprctl keyword general:gaps_in $new_in
        hyprctl keyword general:gaps_out $new_out
        notify-send -u low -t 1000 "Gaps Decreased" "In: $new_in | Out: $new_out"
        ;;
    reset)
        # Reset to default values
        hyprctl keyword general:gaps_in $default_in
        hyprctl keyword general:gaps_out $default_out
        notify-send -u low -t 1000 "Gaps Reset" "In: $default_in | Out: $default_out"
        ;;
    *)
        echo "Usage: $0 [inc|dec|reset]"
        exit 1
        ;;
esac
