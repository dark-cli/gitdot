#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For applying Pre-configured Monitor Profiles

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Variables
iDIR="$HOME/.config/swaync/images"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
monitor_dir="$HOME/.config/hypr/Monitor_Profiles"
target="$HOME/.config/hypr/monitors.conf"
rofi_theme="$HOME/.config/rofi/config-Monitors.rasi"
msg='❗NOTE:❗ This will overwrite $HOME/.config/hypr/monitors.conf'

# Define the list of files to ignore
ignore_files=(
  "README"
)

# list of Monitor Profiles, sorted alphabetically with numbers first
mon_profiles_list=$(find -L "$monitor_dir" -maxdepth 1 -type f | sed 's/.*\///' | sed 's/\.conf$//' | sort -V)

# Remove ignored files from the list
for ignored_file in "${ignore_files[@]}"; do
    mon_profiles_list=$(echo "$mon_profiles_list" | grep -v -E "^$ignored_file$")
done

# Rofi Menu
chosen_file=$(echo "$mon_profiles_list" | rofi -i -dmenu -config $rofi_theme -mesg "$msg")

if [[ -n "$chosen_file" ]]; then
    full_path="$monitor_dir/$chosen_file.conf"
    cp "$full_path" "$target"
    
    # Reload hyprland config to apply monitor changes
    hyprctl reload
    
    # Wait a moment for reload to complete, then set tablet transform
    sleep 0.1
    # Automatically set tablet transform based on profile
    # If profile contains "270", set tablet transform to 3 (270° rotation)
    # Otherwise, set it to 0 (normal/no rotation)
    if [[ "$chosen_file" == *"270"* ]]; then
        hyprctl keyword input:tablet:transform 3
        notify-send -u low -i "$iDIR/ja.png" "$chosen_file" "Monitor Profile Loaded\nTablet rotation: 270°"
    else
        hyprctl keyword input:tablet:transform 0
        notify-send -u low -i "$iDIR/ja.png" "$chosen_file" "Monitor Profile Loaded\nTablet rotation: Normal"
    fi
fi
