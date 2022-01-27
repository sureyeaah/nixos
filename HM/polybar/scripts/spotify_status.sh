#!/bin/sh

PLAYERCTL_CMD="playerctl"
PLAYERCTL_STATUS="$($PLAYERCTL_CMD status)"

if [ "$PLAYERCTL_STATUS" = "Stopped" ]; then
    echo "No music is playing"
elif [ "$PLAYERCTL_STATUS" = "Paused" ]; then
    echo " $($PLAYERCTL_CMD metadata --format "{{ title }} - {{ artist }}")"
else
    echo "$($PLAYERCTL_CMD metadata --format "{{ title }} - {{ artist }}")"
fi
