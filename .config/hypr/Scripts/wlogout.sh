#!/usr/bin/bash

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

wlogout -C $HOME/.config/wlogout/style.css -l $HOME/.config/wlogout/layout --protocol layer-shell &
