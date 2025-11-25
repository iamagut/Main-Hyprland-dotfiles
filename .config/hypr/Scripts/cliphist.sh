#!/usr/bin/env bash

# Directory to store temporary image previews
cache_dir="/tmp/cliphist_preview"
mkdir -p "$cache_dir"

# 1. Get the list from cliphist
# 2. Loop through the top 50 items (limit for performance)
# 3. Check if it is an image -> Decode to tmp file -> Print with icon
# 4. Pipe everything to rofi

cliphist list | head -n 50 | while read -r line; do
    # Extract the ID (first column)
    id=$(echo "$line" | cut -d' ' -f1)
    
    # Extract the content description
    content="${line#* }"

    # Check for image marker (cliphist marks images with [[ binary data ... ]])
    if [[ "$content" == "[[ binary data"* ]]; then
        # Extract extension (png, jpg) from the description to help Rofi
        ext=$(echo "$content" | awk '{print $4}')
        preview_file="${cache_dir}/${id}.${ext}"

        # Decode only if file doesn't exist (cache hit)
        if [ ! -f "$preview_file" ]; then
            cliphist decode "$id" > "$preview_file"
        fi

        # Pass the entry to Rofi with the icon syntax: text\0icon\x1f/path/to/icon
        echo -en "$line\0icon\x1f${preview_file}\n"
    else
        # Regular text item, print normally
        echo "$line"
    fi
done | rofi -dmenu \
    -show-icons \
    -p "Clipboard" \
    -display-columns 2 \
    -theme-str 'element-icon { size: 2.5ch; }' \
    | cliphist decode | wl-copy