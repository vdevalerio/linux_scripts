#!/bin/bash

# Get the tablet device name
TABLET=$(xinput list --name-only | grep -i "stylus\|tablet" | head -n 1)

# Get the list of connected monitors
MONITORS=($(xrandr --listmonitors | awk 'NR>1 {print $4}'))

# File to store the current monitor index
STATE_FILE="$HOME/.logs/tablet_monitor_state"

# Set log file
LOG_FILE="$HOME/.logs/toggle_wacom_monitor.log"

# Get current monitor index
if [[ -f "$STATE_FILE" ]]; then
    CURRENT_INDEX=$(cat "$STATE_FILE")
else
    CURRENT_INDEX=0
fi

# Toggle to the next monitor
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#MONITORS[@]} ))
NEXT_MONITOR=${MONITORS[$NEXT_INDEX]}

# Apply the mapping
if [[ -n "$TABLET" && -n "$NEXT_MONITOR" ]]; then
    xinput map-to-output "$TABLET" "$NEXT_MONITOR"
    echo "Tablet mapped to $NEXT_MONITOR" >> "$LOG_FILE"
    echo "$NEXT_INDEX" > "$STATE_FILE"
else
    echo "Error: No tablet or monitor detected." >> "$LOG_FILE"
    exit 1
fi
