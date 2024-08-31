#!/bin/bash

# Paths
WALLPAPER_DIR="$HOME/Wallpapers"
CSS_FILE="$HOME/.config/ags/style.css"
CONFIG_FILE="$HOME/.config/wallpaper_colors.conf"
THEME_FILE="$HOME/.config/rofi/config.rasi"
# Check if Hyprpaper is installed
command -v hyprpaper >/dev/null 2>&1 || { echo >&2 "Hyprpaper is required but not installed. Aborting."; exit 1; }

# Check if the wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Wallpaper directory does not exist."
    exit 1
fi

# Check if the configuration file exists, create it if it doesn't
if [ ! -f "$CONFIG_FILE" ]; then
    echo "# Wallpaper color configuration" > "$CONFIG_FILE"
    echo "# Format: wallpaper_name.jpg:primary_color,secondary_color,tertiary_color,quaternary_color,theme" >> "$CONFIG_FILE"
    echo "# Example: my_wallpaper.jpg:#a50000,#ffffff,#000000,#ffffff,'/usr/share/rofi/themes/Arc-Dark.rasi'" >> "$CONFIG_FILE"
    echo "Configuration file created at $CONFIG_FILE. Please add your wallpaper color schemes."
    exit 1
fi

# Get a list of files in the directory
files=("$WALLPAPER_DIR"/*)

# Check if there are any files
if [ ${#files[@]} -eq 0 ]; then
    echo "Error: No files found in the wallpaper directory."
    exit 1
fi

# Randomly select one file
selected_file="${files[RANDOM % ${#files[@]}]}"
wallpaper_name=$(basename "$selected_file")

# Read color scheme from configuration
color_scheme=$(grep "^$wallpaper_name:" "$CONFIG_FILE" | cut -d':' -f2)

if [ -z "$color_scheme" ]; then
    echo "Error: No color scheme found for $wallpaper_name in $CONFIG_FILE"
    exit 1
fi

# Split color scheme into individual colors
IFS=',' read -r primary secondary tertiary quaternary theme <<< "$color_scheme"

# Update CSS file
sed -i "s/@define-color primary .*/@define-color primary $primary;/" "$CSS_FILE"
sed -i "s/@define-color secondary .*/@define-color secondary $secondary;/" "$CSS_FILE"
sed -i "s/@define-color tertiary .*/@define-color tertiary $tertiary;/" "$CSS_FILE"
sed -i "s/@define-color quaternary .*/@define-color quaternary $quaternary;/" "$CSS_FILE"
sed -i "s|@theme .*|@theme \"$theme\"|" "$THEME_FILE"
# Create a temporary configuration file for hyprpaper
temp_config=$(mktemp)

# Write the configuration to the temporary file
echo "preload = $selected_file" > "$temp_config"
echo "wallpaper = eDP-1, $selected_file" >> "$temp_config"

# Execute hyprpaper with the temporary configuration file
hyprpaper -c "$temp_config"

# Remove the temporary configuration file
rm "$temp_config"

echo "Applied wallpaper: $selected_file"
echo "Updated CSS with colors: Primary: $primary, Secondary: $secondary, Tertiary: $tertiary, Quaternary: $quaternary"
echo "Updated rofi theme to $theme"

# Optionally, restart ags to apply the new CSS
if command -v ags >/dev/null 2>&1; then
    ags -q
    ags &
    echo "Restarted AGS to apply new styles"
else
    echo "AGS not found. You may need to restart it manually to apply new styles."
fi
