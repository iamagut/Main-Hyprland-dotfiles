#!/usr/bin/env bash
LAYOUT_DIR="$HOME/.config/waybar/layouts"

# list available layouts
layouts=($(ls "$LAYOUT_DIR" | sed 's/.jsonc//'))

chosen=$(printf '%s\n' "${layouts[@]}" | rofi -dmenu -p "Waybar Layout:")

[[ -z "$chosen" ]] && exit

# Switch JSONC
ln -sf "$LAYOUT_DIR/$chosen.jsonc" "$HOME/.config/waybar/config.jsonc"

# Restart waybar
pkill waybar
waybar &
