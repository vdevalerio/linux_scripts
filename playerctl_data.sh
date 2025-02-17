#!/bin/bash

# Default configurations
scroll_speed=2
max_length=30
state_file="/tmp/scroll_state"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--speed) scroll_speed="$2"; shift 2 ;;
        -l|--length) max_length="$2"; shift 2 ;;
        -f|--file) state_file="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Get active player
player="$(playerctl -l 2>/dev/null | head -n 1)"

# Get metadata
if [[ "$player" ]]; then
    title="$(playerctl -p "$player" metadata title 2>/dev/null)"
    artist="$(playerctl -p "$player" metadata artist 2>/dev/null)"
    album="$(playerctl -p "$player" metadata album 2>/dev/null)"
fi

# Construct text
text="  "
if [ -n "$title" ]; then
    text+="${artist:+$artist - }$title"
else
    text+="No Music"
fi
text+="  "

# Read last position
pos=0
if [[ -f "$state_file" ]]; then
    pos=$(cat "$state_file")
fi

# Update scroll position
if (( ${#text} > max_length )); then
    (( pos = (pos + scroll_speed) % ${#text} ))
    echo "$pos" > "$state_file"

    # Extract scrolling text
    scroll_text="${text:pos:max_length}"
    if (( ${#scroll_text} < max_length )); then
        scroll_text+="${text:0:$((max_length - ${#scroll_text}))}"
    fi
else
    scroll_text="$text"
fi

# Output scrolling text
echo "$scroll_text"
