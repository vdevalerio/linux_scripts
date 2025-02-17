#!/bin/bash

# Closebox73
# Simple script to get playerctl status then show as Icon
# It use Feather icon font

# Got from: https://www.gnome-look.org/p/1834287

PCTL=$(playerctl status)

if [[ ${PCTL} == "" ]]; then
        echo ""
        elif [[ ${PCTL} == "Stopped" ]]; then
                echo ""
        elif [[ ${PCTL} == "Playing" ]]; then
                echo ""
        elif [[ ${PCTL} == "Paused" ]]; then
                echo ""
else
        echo ""
fi
