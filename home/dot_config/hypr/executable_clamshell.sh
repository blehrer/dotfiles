#!/bin/bash

LAPTOP_DISPLAY="eDP-1"
HDMI_DISPLAY="HDMI-A-1"

# notify-send "clamshell.sh: init (1: $1)"

if [ "$1" = "open" ]; then
    hyprctl keyword monitor "${LAPTOP_DISPLAY},preferred,auto-left,1"
    notify-send "clamshell.sh: open"
elif [ "$1" = "close" ]; then
    hyprctl keyword monitor "${LAPTOP_DISPLAY},disable"
    notify-send "clamshell.sh: closed"
fi

