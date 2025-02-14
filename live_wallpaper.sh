#!/bin/bash

# Set the folder containing animation videos
THEME=$(gsettings get org.gnome.desktop.interface gtk-theme)
THEME=$(echo "$THEME" | tr -d "'")
THEME=$(echo "$THEME" | tr ' ' '\ ')
ANIMATIONS_DIR="$HOME/Videos/Wallpapers/$THEME/"

# Set log file
LOG_FILE="$HOME/.logs/livewallpaper.log"

# Set duration (in seconds) before changing to a new video
CHANGE_INTERVAL=600

# Get XFCE desktop window ID
get_wid() {
    local retries=0
    local max_retries=30

    while [[ $retries -lt $max_retries ]]; do
        WID=$(xdotool search --onlyvisible --class xfdesktop | head -n 1)

        if [[ -n "$WID" ]]; then
            break
        fi

        retries=$((retries + 1))
        sleep 2
    done

    if [[ -z "$WID" ]]; then
        echo "Error: Could not find XFCE desktop window ID after waiting." >> "$LOG_FILE"
        exit 1
    fi
}

# Ensure WID is available
get_wid

# Function to pick a random video
pick_random_video() {
    find "$ANIMATIONS_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" \) | shuf -n 1
}

# Main loop
while true; do
    VIDEO=$(pick_random_video)
    if [[ -z "$VIDEO" ]]; then
        echo "No video found in $ANIMATIONS_DIR" >> "$LOG_FILE"
	exit 1
    fi

    # Run mpv as wallpaper
    mpv --wid="$WID" --no-audio --loop --no-osc --no-input-default-bindings --no-border "$VIDEO" &

    # Wait for the set interval before changing the video
    sleep "$CHANGE_INTERVAL"

    # Kill previous wallpaper instances but keep other mpv processes running
    pkill -f "mpv --wid=$WID --no-audio --loop --no-osc --no-input-default-bindings"
done
