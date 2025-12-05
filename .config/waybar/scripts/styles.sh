#!/usr/bin/env bash

STYLE_DIR="$HOME/.config/waybar/styles"

styles=($(ls "$STYLE_DIR" | sed 's/.css//'))

chosen=$(printf '%s\n' "${styles[@]}" | rofi -dmenu -p "Waybar Style:")

[[ -z "$chosen" ]] && exit

ln -sf "$STYLE_DIR/$chosen.css" "$HOME/.config/waybar/style.css"

pkill waybar
waybar &
