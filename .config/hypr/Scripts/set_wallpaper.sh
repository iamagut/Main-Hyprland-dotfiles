#!/usr/bin/env bash
wall="$1"

ln -sf "$wall" ~/.config/current_wallpaper

swww img "$wall" --transition-step 120 --transition-fps 90 --transition-type any

matugen apply

pkill waybar && waybar &
swaync-client --reload >/dev/null 2>&1

kitty @ set-colors --all ~/.config/kitty/colors.conf

spicetify apply &
