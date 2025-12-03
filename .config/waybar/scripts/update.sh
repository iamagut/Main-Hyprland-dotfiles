#!/usr/bin/env bash

# Count pacman updates
pacman_updates=$(checkupdates 2>/dev/null | wc -l)

# Count AUR updates if yay is installed
if command -v yay &>/dev/null; then
    aur_updates=$(yay -Qua 2>/dev/null | wc -l)
else
    aur_updates=0
fi

total=$((pacman_updates + aur_updates))

# Output JSON for Waybar
if [[ "$total" -gt 0 ]]; then
    echo "{\"text\": \"$total\", \"tooltip\": \"Updates available: $total\", \"class\": \"updates-available\"}"
else
    echo "{\"text\": \"0\", \"tooltip\": \"System up-to-date\", \"class\": \"updates-none\"}"
fi
