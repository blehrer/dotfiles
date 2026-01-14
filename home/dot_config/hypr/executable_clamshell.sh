#!/bin/bash

LAPTOP_MONITOR="eDP-1"

# notify-send "clamshell.sh: init (1: $1)"

if [ "$1" = "open" ]; then
    # When lid opens: re-enable laptop monitor if external connected, or just enable
    # Check if external monitor is connected (adapt this check as needed)
    if hyprctl monitors | grep -q "HDMI-A-1"; then
        notify-send "clamshell.sh: open.if"
        hyprctl keyword monitor "${LAPTOP_MONITOR},preferred,3440x1440,1" # Adjust resolution/position
    else
        notify-send "clamshell.sh: open.else"
        hyprctl keyword monitor "${LAPTOP_MONITOR},disable"
    fi
elif [ "$1" = "close" ]; then
    notify-send "clamshell.sh: close"
    # When lid closes: disable laptop monitor
    hyprctl keyword monitor "${LAPTOP_MONITOR},disable"
fi

