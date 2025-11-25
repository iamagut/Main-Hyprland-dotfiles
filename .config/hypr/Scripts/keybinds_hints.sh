# Path to your hyprland config
CONFIG="$HOME/.config/hypr/config/keybindings.conf"

# Grep lines starting with 'bind', clean them up, and show in rofi
grep -E "^bind" "$CONFIG" | \
    sed 's/bind = //g' | \
    sed 's/exec, //g' | \
    rofi -dmenu -p "Keybinds" -i -theme-str 'window {width: 800px;}'