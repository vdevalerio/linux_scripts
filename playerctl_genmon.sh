#!/bin/bash

# Path to the music info script
MUSIC_SCRIPT="$HOME/.local/bin/linux_scripts/playerctl_data.sh"

# Custom settings
SCROLL_SPEED=2
MAX_LENGTH=30

# Get scrolling text with arguments
scroll_text="$($MUSIC_SCRIPT --speed $SCROLL_SPEED --length $MAX_LENGTH --file /tmp/genmon_scroll_state)"

# Get metadata for tooltip
player="$(playerctl -l 2>/dev/null | head -n 1)"
if [[ "$player" ]]; then
    title="$(playerctl -p "$player" metadata title 2>/dev/null)"
    artist="$(playerctl -p "$player" metadata artist 2>/dev/null)"
    album="$(playerctl -p "$player" metadata album 2>/dev/null)"
fi

# Print output for xfce4-genmon-plugin
printf "<tool>%s\n%s\n%s</tool>\n" "$title" "$artist" "$album" | sed 's/&/&amp;/g'
printf "<txt>%s</txt>\n" "$scroll_text" | sed 's/&/&amp;/g'
echo "<txtclick>playerctl play-pause</txtclick>"
echo "<css>.genmon_value { padding-left: 5px; padding-right: 5px}</css>"
