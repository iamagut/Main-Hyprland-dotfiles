#!/usr/bin/env bash
# Usage: ./rofilaunch.sh [d|w|f]
# d = drun (apps), w = window, f = filebrowser

if pgrep -x "quickshell" > /dev/null; then
    quickshell ipc call qsIpc toggleAppLauncher
    exit 0
fi

case $1 in
    d)  r_mode="drun" ;;
    w)  r_mode="window" ;;
    f)  r_mode="filebrowser" ;;
    *)  r_mode="drun" ;;
esac

# Run rofi
rofi -show "$r_mode" -theme-str 'window {width: 850px;}'
