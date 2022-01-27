#!/bin/sh
set -e

#SPOTIFY_STATUS_SCRIPT=$(echo "")
zscroll -l 20 \
        --delay 0.1 \
        --match-command "playerctl status" \
        --match-text "Playing" "--scroll true" \
        --match-text "Paused" "--scroll false" \
        --update-check true "$HOME/.config/polybar/scripts/spotify_status.sh" &

wait
