#!/bin/bash

LAPTOP_DISPLAY="eDP-1"
HDMI_DISPLAY="HDMI-A-1"

# notify-send "clamshell.sh: init (1: $1)"
monitorCount=$(hyprctl monitors -j | jq 'length')
if [[ $monitorCount != "1" ]]; then
    if [ "$1" = "open" ]; then
        hyprctl keyword monitor "${LAPTOP_DISPLAY},preferred,auto-left,1.6"
        notify-send "clamshell.sh: open"
    elif [ "$1" = "close" ]; then
        hyprctl keyword monitor "${LAPTOP_DISPLAY},disable"
        notify-send "clamshell.sh: closed"
    fi
elif 
    hyprctl keyword monitor "${HDMI_DISPLAY},disable"
    hyprctl keyword monitor "${LAPTOP_DISPLAY},preferred,auto,1.6"
fi
