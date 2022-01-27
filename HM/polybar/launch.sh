#!/usr/bin/env sh

# kill various scripts started by polybar
ps -ef | grep 'zscroll' | grep 'spotify' | grep 'polybar' | grep -v grep | awk '{print $2}' | xargs -r kill -9
pkill -f ~/.config/polybar/scripts/spotify.sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch main bar on both monitors
xrandr --listmonitors | grep "^ .:" | cut -d" " -f6 | while read m ;  do
  MONITOR=$m polybar -c ~/.config/polybar/config.ini -r main &
done
