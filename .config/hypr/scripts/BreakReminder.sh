#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Break Reminder Script - Sends notification with Quran verse after unlocking screen
# This script monitors for hyprlock unlock events and reminds user to take a break

# Configuration
WAIT_TIME=5  # Wait time in seconds after unlock before sending notification
LOCK_FILE="/tmp/hyprlock_break_reminder.lock"
PID_FILE="/tmp/hyprlock_break_reminder.pid"

# Function to fetch random Quran verse
fetch_quran_verse() {
    # Using Al-Quran Cloud API - free and open API
    # Always use /random endpoint to ensure we get a TRULY RANDOM verse each time
    # Add random number to prevent caching and ensure different verse each time
    local random_seed=$((RANDOM + $(date +%s)))
    local api_urls=(
        "https://api.alquran.cloud/v1/ayah/random/quran-uthmani"
        "https://api.alquran.cloud/v1/ayah/random"
    )
    
    local response=""
    local api_url=""
    
    # Try each API endpoint with timeout (API can be slow)
    for api_url in "${api_urls[@]}"; do
        response=$(timeout 8 curl -s --max-time 8 --connect-timeout 3 "$api_url" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$response" ] && echo "$response" | grep -q "text"; then
            break
        fi
        response=""
    done
    
    if [ -n "$response" ]; then
        # Use python3 or jq if available for better JSON parsing, otherwise use grep/sed
        if command -v python3 >/dev/null 2>&1; then
            local arabic_text=$(echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('data', {}).get('text', ''))" 2>/dev/null)
            local surah_name=$(echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('data', {}).get('surah', {}).get('name', ''))" 2>/dev/null)
            local ayah_number=$(echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('data', {}).get('numberInSurah', ''))" 2>/dev/null)
            local surah_number=$(echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('data', {}).get('surah', {}).get('number', ''))" 2>/dev/null)
        elif command -v jq >/dev/null 2>&1; then
            local arabic_text=$(echo "$response" | jq -r '.data.text // empty' 2>/dev/null)
            local surah_name=$(echo "$response" | jq -r '.data.surah.name // empty' 2>/dev/null)
            local ayah_number=$(echo "$response" | jq -r '.data.numberInSurah // empty' 2>/dev/null)
            local surah_number=$(echo "$response" | jq -r '.data.surah.number // empty' 2>/dev/null)
        else
            # Fallback to grep/sed parsing
            local arabic_text=$(echo "$response" | grep -o '"text":"[^"]*"' | head -1 | sed 's/"text":"\(.*\)"/\1/' | sed 's/\\n/ /g' | sed 's/\\//g')
            local surah_name=$(echo "$response" | grep -o '"name":"[^"]*"' | head -1 | sed 's/"name":"\(.*\)"/\1/')
            local ayah_number=$(echo "$response" | grep -o '"numberInSurah":[0-9]*' | head -1 | sed 's/"numberInSurah"://')
            local surah_number=$(echo "$response" | grep -o '"number":[0-9]*' | head -1 | sed 's/"number"://')
        fi
        
        # Clean up Arabic text
        arabic_text=$(echo "$arabic_text" | sed 's/&nbsp;/ /g' | sed 's/&amp;/\&/g' | sed 's/\\u[0-9a-fA-F]\{4\}//g')
        
        if [ -n "$arabic_text" ] && [ -n "$surah_name" ]; then
            echo "$arabic_text|$surah_name|$ayah_number|$surah_number"
            return 0
        fi
    fi
    
    # Fallback verses if API fails (random selection)
    local fallback_verses=(
        "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ|البقرة|255|2"
        "وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ|هود|88|11"
        "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ|البقرة|201|2"
        "وَمَا أُوتِيتُم مِّنَ الْعِلْمِ إِلَّا قَلِيلًا|الإسراء|85|17"
        "وَاللَّهُ خَيْرٌ حَافِظًا وَهُوَ أَرْحَمُ الرَّاحِمِينَ|يوسف|64|12"
        "إِنَّ مَعَ الْعُسْرِ يُسْرًا|الشرح|6|94"
        "وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا|الطلاق|2|65"
        "رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا|آل عمران|8|3"
    )
    # Use $RANDOM for random selection
    local random_index=$((RANDOM % ${#fallback_verses[@]}))
    echo "${fallback_verses[$random_index]}"
    return 1
}

# Function to pause other media players
pause_other_media() {
    # Pause playerctl managed players (Spotify, VLC, etc.)
    if command -v playerctl >/dev/null 2>&1; then
        playerctl pause 2>/dev/null || true
    fi
    
    # Pause mpv instances
    pkill -STOP mpv 2>/dev/null || true
    
    # Pause vlc if running
    if pgrep -x vlc >/dev/null 2>&1; then
        pkill -STOP vlc 2>/dev/null || true
    fi
    
    # Pause other common media players
    pkill -STOP rhythmbox 2>/dev/null || true
    pkill -STOP audacious 2>/dev/null || true
    pkill -STOP mplayer 2>/dev/null || true
}

# Function to increase volume before playing
increase_volume() {
    local target_volume=80  # Target volume percentage
    
    if command -v pamixer >/dev/null 2>&1; then
        # Unmute if muted
        if [ "$(pamixer --get-mute)" = "true" ]; then
            pamixer -u 2>/dev/null
        fi
        
        # Get current volume
        local current_volume=$(pamixer --get-volume 2>/dev/null | tr -d '%' || echo "0")
        
        # Increase volume if below target
        if [ "$current_volume" -lt "$target_volume" ]; then
            pamixer --set-volume "$target_volume" --allow-boost 2>/dev/null
        fi
    elif command -v amixer >/dev/null 2>&1; then
        # Unmute if muted
        amixer set Master unmute >/dev/null 2>&1
        # Set volume
        amixer set Master "${target_volume}%" >/dev/null 2>&1
    fi
}

# Function to play audio for Quran verse
play_quran_audio() {
    local surah_number=$1
    local ayah_number=$2
    local arabic_text="$3"
    
    # Validate inputs
    if [ -z "$surah_number" ] || [ -z "$ayah_number" ] || [ "$surah_number" = "null" ] || [ "$ayah_number" = "null" ]; then
        echo "Error: Invalid surah or ayah number" >&2
        return 1
    fi
    
    # Pause other media before playing
    pause_other_media
    
    # Increase volume before playing
    increase_volume
    
    # Use Quran.com API to get audio URL for specific ayah
    local verse_key="${surah_number}:${ayah_number}"
    local api_url="https://api.quran.com/api/v4/recitations/1/by_ayah/${verse_key}"
    
    # Fetch audio URL from API (with longer timeout)
    local audio_path=""
    if command -v python3 >/dev/null 2>&1; then
        local api_response=$(curl -s --max-time 8 --connect-timeout 5 "$api_url" 2>/dev/null)
        if [ -n "$api_response" ] && echo "$api_response" | grep -q "audio_files"; then
            audio_path=$(echo "$api_response" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d['audio_files'][0]['url'] if 'audio_files' in d and len(d['audio_files']) > 0 else '')" 2>/dev/null)
        fi
    elif command -v jq >/dev/null 2>&1; then
        local api_response=$(curl -s --max-time 8 --connect-timeout 5 "$api_url" 2>/dev/null)
        if [ -n "$api_response" ]; then
            audio_path=$(echo "$api_response" | jq -r '.audio_files[0].url // empty' 2>/dev/null)
        fi
    fi
    
    # Construct full audio URL - prefer API-provided path for accuracy
    local audio_url=""
    if [ -n "$audio_path" ] && [ "$audio_path" != "null" ] && [ "$audio_path" != "" ]; then
        # Use API-provided path (most accurate)
        audio_url="https://verses.quran.com/${audio_path}"
    else
        # Fallback: construct URL directly
        local surah_padded=$(printf "%03d" "$surah_number")
        local ayah_padded=$(printf "%03d" "$ayah_number")
        audio_url="https://verses.quran.com/AbdulBaset/Mujawwad/mp3/${surah_padded}${ayah_padded}.mp3"
    fi
    
    # Download and play audio
    local temp_audio="/tmp/quran_verse_${surah_number}_${ayah_number}.mp3"
    
    # Download the audio file
    local download_success=false
    if curl -s --max-time 8 --connect-timeout 5 -o "$temp_audio" "$audio_url" 2>/dev/null; then
        if [ -f "$temp_audio" ] && [ -s "$temp_audio" ]; then
            download_success=true
        fi
    fi
    
    if [ "$download_success" = true ]; then
        # Check if file is valid audio (size > 1KB)
        local file_size=$(stat -c%s "$temp_audio" 2>/dev/null || stat -f%z "$temp_audio" 2>/dev/null)
        if [ -n "$file_size" ] && [ "$file_size" -gt 1024 ] 2>/dev/null; then
            # Get audio duration to stop playback after verse finishes
            local duration=0
            if command -v ffprobe >/dev/null 2>&1; then
                duration=$(ffprobe -i "$temp_audio" -show_entries format=duration -v quiet -of csv="p=0" 2>/dev/null | cut -d. -f1)
            elif command -v soxi >/dev/null 2>&1; then
                duration=$(soxi -D "$temp_audio" 2>/dev/null | cut -d. -f1)
            fi
            
            # If duration is 0 or very long (> 2 minutes), assume it's a full surah and limit playback
            # Most single ayahs are 10-60 seconds, so limit to 90 seconds max
            if [ -z "$duration" ] || [ "$duration" -eq 0 ] || [ "$duration" -gt 120 ]; then
                duration=90  # Limit to 90 seconds max for single ayah playback
            fi
            
            # Play audio using available player (will stop automatically after duration)
            if command -v mpv >/dev/null 2>&1; then
                # mpv will play the file and stop when it ends
                # Use a background process that kills mpv after max duration to ensure it stops
                local mpv_pid=""
                mpv --no-video --really-quiet "$temp_audio" 2>/dev/null &
                mpv_pid=$!
                
                # Kill mpv after max duration (90 seconds) to ensure it stops
                (
                    sleep 90
                    kill "$mpv_pid" 2>/dev/null || true
                    rm -f "$temp_audio" 2>/dev/null
                ) &
                return 0
            elif command -v pw-play >/dev/null 2>&1; then
                # pw-play doesn't support duration, so use timeout (limit to 90 seconds max)
                local play_duration=$duration
                if [ "$play_duration" -eq 0 ] || [ "$play_duration" -gt 90 ]; then
                    play_duration=90
                fi
                # Play audio in background with timeout
                timeout "$play_duration" pw-play "$temp_audio" 2>/dev/null &
                local play_pid=$!
                # Clean up after playback completes
                (sleep $((play_duration + 5)) && kill "$play_pid" 2>/dev/null || true; rm -f "$temp_audio" 2>/dev/null) &
                return 0
            elif command -v pa-play >/dev/null 2>&1; then
                local play_duration=$duration
                if [ "$play_duration" -eq 0 ] || [ "$play_duration" -gt 90 ]; then
                    play_duration=90
                fi
                timeout "$play_duration" pa-play "$temp_audio" 2>/dev/null &
                (sleep $((play_duration + 5)) && rm -f "$temp_audio" 2>/dev/null) &
                return 0
            elif command -v mpg123 >/dev/null 2>&1; then
                local play_duration=$duration
                if [ "$play_duration" -eq 0 ] || [ "$play_duration" -gt 90 ]; then
                    play_duration=90
                fi
                timeout "$play_duration" mpg123 -q "$temp_audio" 2>/dev/null &
                (sleep $((play_duration + 5)) && rm -f "$temp_audio" 2>/dev/null) &
                return 0
            fi
        fi
        rm -f "$temp_audio" 2>/dev/null
    fi
    
    return 1
}

# Function to send notification
send_break_notification() {
    # Try to fetch from API, but use fallback if it takes too long
    local verse_data=""
    
    # Use timeout to limit API call (increase timeout for reliability)
    if command -v timeout >/dev/null 2>&1; then
        verse_data=$(timeout 10 bash -c "$(declare -f fetch_quran_verse); fetch_quran_verse" 2>/dev/null)
    else
        # Fallback: try API but don't wait long
        verse_data=$(fetch_quran_verse)
    fi
    
    # If API failed or timed out, use fallback
    if [ -z "$verse_data" ] || [ ${#verse_data} -lt 10 ]; then
        local fallback_verses=(
            "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ|البقرة|255|2"
            "وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ|هود|88|11"
            "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ|البقرة|201|2"
            "وَمَا أُوتِيتُم مِّنَ الْعِلْمِ إِلَّا قَلِيلًا|الإسراء|85|17"
            "وَاللَّهُ خَيْرٌ حَافِظًا وَهُوَ أَرْحَمُ الرَّاحِمِينَ|يوسف|64|12"
        )
        local random_index=$((RANDOM % ${#fallback_verses[@]}))
        verse_data="${fallback_verses[$random_index]}"
    fi
    
    IFS='|' read -r arabic_text surah_name ayah_number surah_number <<< "$verse_data"
    
    # Clean up Arabic text (remove HTML entities if any)
    arabic_text=$(echo "$arabic_text" | sed 's/&nbsp;/ /g' | sed 's/&amp;/\&/g' | sed 's/\\u[0-9a-fA-F]\{4\}//g')
    
    # Truncate if too long (notifications have limits)
    if [ ${#arabic_text} -gt 200 ]; then
        arabic_text="${arabic_text:0:197}..."
    fi
    
    # Send notification with verse
    notify-send -u normal -t 15000 \
        "⏸️ Take a Break" \
        "📖 $surah_name - Ayah $ayah_number\n\n$arabic_text"
    
    # Play audio for the verse
    play_quran_audio "$surah_number" "$ayah_number" "$arabic_text"
}

# Function to monitor unlock events
monitor_unlock() {
    while true; do
        # Check if hyprlock is running
        if pgrep -x hyprlock > /dev/null; then
            # Lock screen is active, create lock file
            touch "$LOCK_FILE"
        else
            # Lock screen is not running
            if [ -f "$LOCK_FILE" ]; then
                # Screen was just unlocked (lock file exists but hyprlock is not running)
                rm -f "$LOCK_FILE"
                
                # Wait for specified time before sending notification
                sleep "$WAIT_TIME"
                
                # Check if screen is still unlocked (not locked again during wait)
                if ! pgrep -x hyprlock > /dev/null; then
                    send_break_notification
                fi
            fi
        fi
        
        # Check every 2 seconds
        sleep 2
    done
}

# Function to start daemon
start_daemon() {
    if [ -f "$PID_FILE" ]; then
        local old_pid=$(cat "$PID_FILE")
        if ps -p "$old_pid" > /dev/null 2>&1; then
            echo "Break reminder daemon is already running (PID: $old_pid)"
            exit 1
        else
            rm -f "$PID_FILE"
        fi
    fi
    
    # Start monitoring in background
    monitor_unlock &
    local daemon_pid=$!
    echo $daemon_pid > "$PID_FILE"
    echo "Break reminder daemon started (PID: $daemon_pid)"
}

# Function to stop daemon
stop_daemon() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            kill "$pid"
            rm -f "$PID_FILE" "$LOCK_FILE"
            echo "Break reminder daemon stopped"
        else
            echo "Daemon is not running"
            rm -f "$PID_FILE" "$LOCK_FILE"
        fi
    else
        echo "Daemon is not running"
    fi
}

# Function to check status
check_status() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "Break reminder daemon is running (PID: $pid)"
        else
            echo "Break reminder daemon is not running"
            rm -f "$PID_FILE"
        fi
    else
        echo "Break reminder daemon is not running"
    fi
}

# Main execution
case "$1" in
    --start)
        start_daemon
        ;;
    --stop)
        stop_daemon
        ;;
    --status)
        check_status
        ;;
    --test)
        # Test notification without waiting - use fallback for speed
        echo "Testing notification and audio (using fallback verse for speed)..."
        test_verse="اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ|البقرة|255|2"
        IFS='|' read -r arabic_text surah_name ayah_number surah_number <<< "$test_verse"
        notify-send -u normal -t 15000 \
            "⏸️ Take a Break (Test)" \
            "📖 $surah_name - Ayah $ayah_number\n\n$arabic_text"
        echo "Test notification sent!"
        # Play audio
        play_quran_audio "$surah_number" "$ayah_number" "$arabic_text"
        echo "Audio playback started!"
        ;;
    --test-api)
        # Test API fetch (may take a few seconds)
        echo "Testing API fetch..."
        verse_data=$(fetch_quran_verse)
        IFS='|' read -r arabic_text surah_name ayah_number surah_number <<< "$verse_data"
        echo "Surah: $surah_name, Ayah: $ayah_number"
        echo "Surah Number: $surah_number, Ayah Number: $ayah_number"
        echo "Text: $arabic_text"
        echo "Audio will be requested for Surah $surah_number, Ayah $ayah_number"
        notify-send -u normal -t 15000 \
            "⏸️ Take a Break (API Test)" \
            "📖 $surah_name - Ayah $ayah_number\n\n$arabic_text"
        # Play audio - make sure we pass the correct numbers
        play_quran_audio "$surah_number" "$ayah_number" "$arabic_text"
        echo "Audio playback started!"
        ;;
    *)
        echo "Usage: $0 {--start|--stop|--status|--test|--test-api}"
        echo "  --start     Start the break reminder daemon"
        echo "  --stop      Stop the break reminder daemon"
        echo "  --status    Check if daemon is running"
        echo "  --test      Test notification with fallback verse (fast)"
        echo "  --test-api  Test notification with API fetch (may be slow)"
        exit 1
        ;;
esac
