#!/bin/bash

# Wacom tablet monitor toggle script using xsetwacom
# More reliable for Wacom-specific features

# Configuration
STATE_FILE="$HOME/.config/wacom_monitor_state"
LOG_FILE="$HOME/.local/log/toggle_wacom_monitor.log"

# Create directories if they don't exist
mkdir -p "$(dirname "$STATE_FILE")" "$(dirname "$LOG_FILE")"

# Function to log messages with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if xsetwacom is available
if ! command -v xsetwacom &> /dev/null; then
    log "Error: xsetwacom command not found. Please install wacom tablet drivers."
    echo "Error: xsetwacom command not found. Install with: sudo pacman -S xf86-input-wacom"
    exit 1
fi

# Get Wacom devices using xsetwacom
DEVICES=($(xsetwacom list devices | awk '{print $1}'))

if [ ${#DEVICES[@]} -eq 0 ]; then
    log "Error: No Wacom devices found with xsetwacom"
    echo "Error: No Wacom devices detected"
    exit 1
fi

# Get the list of connected monitors
MONITORS=($(xrandr --query | grep " connected" | awk '{print $1}'))

if [ ${#MONITORS[@]} -eq 0 ]; then
    log "Error: No connected monitors found"
    echo "Error: No connected monitors found"
    exit 1
fi

# Get current monitor index
if [[ -f "$STATE_FILE" ]]; then
    CURRENT_INDEX=$(cat "$STATE_FILE")
else
    CURRENT_INDEX=0
fi

# Toggle to the next monitor
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#MONITORS[@]} ))
NEXT_MONITOR=${MONITORS[$NEXT_INDEX]}

# Apply mapping to all Wacom devices
SUCCESS=0
for DEVICE in "${DEVICES[@]}"; do
    # Get the device ID
    DEVICE_ID=$(xsetwacom list | grep "$DEVICE" | awk '{print $7}')

    if xsetwacom set "$DEVICE" MapToOutput "$NEXT_MONITOR" 2>/dev/null; then
        log "Device '$DEVICE' mapped to $NEXT_MONITOR"
        SUCCESS=1
    else
        log "Warning: Failed to map '$DEVICE' to $NEXT_MONITOR"
    fi
done

if [ $SUCCESS -eq 1 ]; then
    echo "$NEXT_INDEX" > "$STATE_FILE"
    log "Monitor state updated to index: $NEXT_INDEX ($NEXT_MONITOR)"

    # Display notification
    if command -v notify-send &> /dev/null; then
        notify-send "Wacom Tablet" "Moved to monitor: $NEXT_MONITOR" -t 3000
    fi

    echo "Wacom tablet moved to monitor: $NEXT_MONITOR"
else
    log "Error: No devices were successfully mapped"
    echo "Error: Failed to map Wacom devices to monitor"
    exit 1
fi
