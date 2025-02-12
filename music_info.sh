#!/bin/bash

# Original script by Malte Gerken
# https://www.maltegerken.de/blog/2020/10/show-the-current-music-credits-in-the-xfce-panel/

# Configurations
scroll_speed=2
max_length=30
state_file="/tmp/genmon_scroll_state"

# Get active player
player="$(playerctl -l 2>/dev/null | head -n 1)"
playpausecmd="playerctl play-pause"

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
    # Wrap around when reaching the end
    (( pos = (pos + scroll_speed) % ${#text} ))
    echo "$pos" > "$state_file"

    # Extract scrolling text
    scroll_text="${text:pos:max_length}"
    if (( ${#scroll_text} < max_length )); then
        # Wrap the remaining part
        scroll_text+="${text:0:$((max_length - ${#scroll_text}))}"
    fi
else
    scroll_text="$text"
fi

# Print output for xfce4-genmon-plugin
printf "<tool>%s\n%s\n%s</tool>\n" "$title" "$artist" "$album" | sed 's/&/&amp;/g'
printf "<txt>%s</txt>\n" "$scroll_text" | sed 's/&/&amp;/g'
echo "<txtclick>$playpausecmd</txtclick>"
echo "<css>.genmon_value { padding-left: 5px; padding-right: 5px}</css>"
