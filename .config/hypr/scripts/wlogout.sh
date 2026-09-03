#!/usr/bin/env bash

if pgrep -x "quickshell" > /dev/null; then
    quickshell ipc call qsIpc toggleLogoutMenu
    exit 0
fi

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

wlogout -C $HOME/.config/wlogout/style.css -l $HOME/.config/wlogout/layout --protocol layer-shell &
