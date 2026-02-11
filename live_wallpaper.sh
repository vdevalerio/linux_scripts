#!/bin/bash

# Set the folder containing animation videos
THEME=$(gsettings get org.gnome.desktop.interface gtk-theme)
THEME=$(echo "$THEME" | tr -d "'")
THEME=$(echo "$THEME" | tr ' ' '\ ')
THEME="Harry Potter"
ANIMATIONS_DIR="$HOME/Videos/Wallpapers/$THEME/"

# Set log file
LOG_DIR="$HOME/.logs"
LOG_FILE="$LOG_DIR/livewallpaper.log"

# Configuration: Set to 1 to use different videos on each display, 0 for the same video
USE_DIFFERENT_VIDEOS=1

# Set duration (in seconds) before changing to a new video
CHANGE_INTERVAL=$((60*60*24))

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to pick a random video
pick_random_video() {
    find "$ANIMATIONS_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" \) | shuf -n 1
}

# Function to get display information
get_display_info() {
    log_message "Getting display information..."

    # Arrays to store display data
    local displays=()
    local widths=()
    local heights=()
    local x_offsets=()
    local y_offsets=()

    # Parse xrandr output to get display information and geometry
    while read -r line; do
        if [[ $line =~ ([a-zA-Z0-9\-]+)\ connected\ (primary\ )?([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+) ]]; then
            local display_name="${BASH_REMATCH[1]}"
            local width="${BASH_REMATCH[3]}"
            local height="${BASH_REMATCH[4]}"
            local x_offset="${BASH_REMATCH[5]}"
            local y_offset="${BASH_REMATCH[6]}"

            displays+=("$display_name")
            widths+=("$width")
            heights+=("$height")
            x_offsets+=("$x_offset")
            y_offsets+=("$y_offset")

            log_message "Detected display: $display_name ($width×$height at +$x_offset+$y_offset)"
        fi
    done < <(xrandr --query)

    # Return all arrays
    echo "${displays[@]}"
    echo "${widths[@]}"
    echo "${heights[@]}"
    echo "${x_offsets[@]}"
    echo "${y_offsets[@]}"
}

# Function to kill all previous wallpaper instances
kill_previous_wallpapers() {
    pkill -f "mpv.*livewallpaper"
    log_message "Killed all previous wallpaper instances"
}

# Check if animations directory exists
if [[ ! -d "$ANIMATIONS_DIR" ]]; then
    log_message "Error: Animations directory not found: $ANIMATIONS_DIR"
    exit 1
fi

# Main execution

# Read display information
IFS=$'\n' read -rd '' -a INFO < <(get_display_info)

# Make sure we got some output
if [[ ${#INFO[@]} -lt 5 ]]; then
    log_message "Error: Failed to get proper display information"
    exit 1
fi

# Split the output into separate arrays
IFS=' ' read -ra DISPLAYS <<< "${INFO[0]}"
IFS=' ' read -ra WIDTHS <<< "${INFO[1]}"
IFS=' ' read -ra HEIGHTS <<< "${INFO[2]}"
IFS=' ' read -ra X_OFFSETS <<< "${INFO[3]}"
IFS=' ' read -ra Y_OFFSETS <<< "${INFO[4]}"

if [[ ${#DISPLAYS[@]} -eq 0 ]]; then
    log_message "Error: No displays detected"
    exit 1
fi

log_message "Starting livewallpaper with ${#DISPLAYS[@]} display(s)"

# Get desktop environment
DESKTOP_ENV="unknown"
if [ -n "$XDG_CURRENT_DESKTOP" ]; then
    DESKTOP_ENV="$XDG_CURRENT_DESKTOP"
fi
log_message "Detected desktop environment: $DESKTOP_ENV"

# Main loop
while true; do
    # Kill previous instances
    kill_previous_wallpapers

    # If using the same video for all displays
    MAIN_VIDEO=""
    if [[ $USE_DIFFERENT_VIDEOS -eq 0 ]]; then
        MAIN_VIDEO=$(pick_random_video)
        if [[ -z "$MAIN_VIDEO" ]]; then
            log_message "Error: No videos found in $ANIMATIONS_DIR"
            exit 1
        fi
        log_message "Selected video for all displays: $MAIN_VIDEO"
    fi

    # Process each display
    for i in $(seq 0 $((${#DISPLAYS[@]}-1))); do
        DISPLAY_NAME="${DISPLAYS[$i]}"
        WIDTH="${WIDTHS[$i]}"
        HEIGHT="${HEIGHTS[$i]}"
        X_OFFSET="${X_OFFSETS[$i]}"
        Y_OFFSET="${Y_OFFSETS[$i]}"

        # Validate geometry values
        if [[ -z "$WIDTH" || -z "$HEIGHT" || -z "$X_OFFSET" || -z "$Y_OFFSET" ]]; then
            log_message "Error: Invalid geometry for display $DISPLAY_NAME"
            continue
        fi

        # Pick different videos for each display if configured
        VIDEO="$MAIN_VIDEO"
        if [[ $USE_DIFFERENT_VIDEOS -eq 1 || -z "$VIDEO" ]]; then
            VIDEO=$(pick_random_video)
            if [[ -z "$VIDEO" ]]; then
                log_message "Error: No videos found in $ANIMATIONS_DIR"
                continue
            fi
            log_message "Selected video for display $DISPLAY_NAME: $VIDEO"
        fi

        # Create a unique identifier for this instance
        INSTANCE_ID="livewallpaper_${DISPLAY_NAME}"

        # Different approach based on desktop environment
        if [[ "$DESKTOP_ENV" == *"XFCE"* ]]; then
            # XFCE specific approach
            # Try to find xfdesktop's window ID
            XFCE_DESKTOP_WID=$(xdotool search --class xfdesktop | head -n 1)
            log_message "XFCE desktop window ID: $XFCE_DESKTOP_WID"

            # Start mpv and then set window properties
            mpv \
                --title="$INSTANCE_ID" \
                --no-audio \
                --loop \
                --no-osc \
                --no-osd-bar \
                --no-input-default-bindings \
                --no-border \
                --geometry=${WIDTH}x${HEIGHT}+${X_OFFSET}+${Y_OFFSET} \
                --background="#000000" \
                --panscan=1.0 \
                --really-quiet \
                "$VIDEO" &

            # Give mpv time to start
            sleep 1

            # Get the window ID of our mpv instance
            WINDOW_ID=$(xdotool search --name "$INSTANCE_ID" | head -n 1)

            if [[ -n "$WINDOW_ID" ]]; then
                # Set window type to desktop
                xprop -id "$WINDOW_ID" -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE _NET_WM_WINDOW_TYPE_DESKTOP

                # Set window to stay below others
                xprop -id "$WINDOW_ID" -f _NET_WM_STATE 32a -set _NET_WM_STATE _NET_WM_STATE_BELOW

                log_message "Set window properties for $INSTANCE_ID with ID $WINDOW_ID"
            else
                log_message "Could not find window ID for $INSTANCE_ID"
            fi
        else
            # Generic approach for other desktop environments
            mpv \
                --fs \
                --fs-screen="$i" \
                --title="$INSTANCE_ID" \
                --no-audio \
                --loop \
                --no-osc \
                --no-osd-bar \
                --no-input-default-bindings \
                --no-border \
                --geometry=100%x100%+0+0 \
                --background="#000000" \
                --panscan=1.0 \
                --layer=background \
                --really-quiet \
                "$VIDEO" &

            # Wait a moment for window to initialize
            sleep 1

            # Get the window ID of our mpv instance
            WINDOW_ID=$(xdotool search --name "$INSTANCE_ID" | head -n 1)

            if [[ -n "$WINDOW_ID" ]]; then
                # Set window type to desktop
                xprop -id "$WINDOW_ID" -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE _NET_WM_WINDOW_TYPE_DESKTOP

                # Set window to stay below others
                xprop -id "$WINDOW_ID" -f _NET_WM_STATE 32a -set _NET_WM_STATE _NET_WM_STATE_BELOW

                log_message "Set window properties for $INSTANCE_ID with ID $WINDOW_ID"
            else
                log_message "Could not find window ID for $INSTANCE_ID"
            fi
        fi

        # Log which approach was used
        log_message "Started video on display $DISPLAY_NAME with PID: $!"
    done

    # Wait for the set interval before changing the videos
    log_message "Waiting $CHANGE_INTERVAL seconds before next change"
    sleep "$CHANGE_INTERVAL"
done
