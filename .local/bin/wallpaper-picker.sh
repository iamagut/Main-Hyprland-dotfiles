#!/usr/bin/env bash

# Directories
WALLPAPER_DIR="$HOME/Pictures/wallpaper"
THEME_PATH="$HOME/.config/rofi/wallpaper-select.rasi"

# If no wallpaper argument is passed AND quickshell is running: toggle Quickshell UI
if [ -z "$1" ] && pgrep -x "quickshell" > /dev/null; then
    quickshell ipc call qsIpc toggleWallpaperSwitcher
    exit 0
fi

# Ensure awww-daemon is running
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 0.5
fi

# Check if a wallpaper path was passed as an argument
if [ -n "$1" ] && [ -f "$1" ]; then
    FULL_PATH="$1"
    SELECTED=$(basename "$1")
else
    # Ensure wallpaper folder exists
    if [ ! -d "$WALLPAPER_DIR" ]; then
        if command -v notify-send >/dev/null 2>&1; then
            notify-send -t 3000 "Wallpaper Selector" "Wallpaper folder not found at ~/Pictures/wallpaper"
        else
            echo "Error: Wallpaper folder not found at $WALLPAPER_DIR"
        fi
        exit 1
    fi

    # Gather wallpapers, format for rofi display-name\0icon\x1fpath
    # Supported formats: jpg, jpeg, png, webp, gif
    SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | sort | while read -r file; do
        rel_path="${file#$WALLPAPER_DIR/}"
        echo -en "$rel_path\0icon\x1f$file\n"
    done | rofi -dmenu -i -theme "$THEME_PATH" -p "Select Wallpaper")

    # If user cancelled, exit
    if [ -z "$SELECTED" ]; then
        exit 0
    fi

    # Construct full path to selected wallpaper
    FULL_PATH="$WALLPAPER_DIR/$SELECTED"
fi

# Apply wallpaper using matugen and awww
if [ -f "$FULL_PATH" ]; then
    # Run awww img command with chosen transitions
    awww img "$FULL_PATH" --transition-type center --transition-fps 60 --transition-duration 1
    
    # Run matugen image to generate colors
    matugen image --source-color-index 0 "$FULL_PATH"
    
    # Notify user
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -t 2000 "Wallpaper Picker" "Wallpaper set to: $SELECTED"
    fi
else
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -t 3000 "Wallpaper Picker" "Error: Selected file not found"
    fi
fi
