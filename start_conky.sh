#!/bin/bash

# This command will close all active conky
killall conky &> /dev/null
sleep 2s

# Get conky files based on gtk theme
THEME=$(gsettings get org.gnome.desktop.interface gtk-theme)
THEME=$(echo "$THEME" | tr -d "'")
THEME=$(echo "$THEME" | tr ' ' '\ ')
PANEL="$HOME/.config/conky/$THEME/panel.conf"
CLOCK="$HOME/.config/conky/$THEME/clock.conf"

# Load conky files
conky -c "$PANEL" &> /dev/null &
conky -c "$CLOCK" &> /dev/null &

exit
