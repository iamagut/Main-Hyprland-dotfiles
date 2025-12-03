#!/usr/bin/env bash

LAYOUT_DIR="$HOME/.config/waybar/layouts"
STYLE_DIR="$HOME/.config/waybar/styles"

# list available layout names (without extension)
layouts=($(ls "$LAYOUT_DIR" | sed 's/.jsonc//'))

chosen=$(printf '%s\n' "${layouts[@]}" | rofi -dmenu -p "Waybar Layout:")

[[ -z "$chosen" ]] && exit

# Switch JSONC
ln -sf "$LAYOUT_DIR/$chosen.jsonc" "$HOME/.config/waybar/config.jsonc"

# Switch CSS (same name)
ln -sf "$STYLE_DIR/$chosen.css" "$HOME/.config/waybar/style.css"

# Restart waybar
pkill waybar
waybar &
