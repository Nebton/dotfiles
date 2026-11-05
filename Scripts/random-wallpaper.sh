#!/bin/bash

# Paths
WALLPAPER_DIR="$HOME/Wallpapers"
CSS_FILE="$HOME/.config/ags/style.css"
CONFIG_FILE="$HOME/.config/wallpaper_colors.conf"
THEME_FILE="$HOME/.config/rofi/config.rasi"
HYPRLAND_FILE="$HOME/.config/hypr/hyprland.conf"
NVIM_FILE="$HOME/.config/nvim/init.lua"
ZSHLINE_FILE="$HOME/.config/zsh/prompt_purification_setup"
KITTY_FILE="$HOME/.config/kitty/kitty.conf"
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

# Serialize wallpaper changes and ignore directories/non-image files.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/random-wallpaper-$UID.lock"
flock -n 9 || exit 0
shopt -s nullglob nocaseglob
files=("$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp})

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
IFS=',' read -r primary secondary tertiary quaternary prompt_color theme nvim<<< "$color_scheme"

# Update CSS file
sed --follow-symlinks -i "s/@define-color primary .*/@define-color primary $primary;/" "$CSS_FILE"
sed --follow-symlinks -i "s/@define-color secondary .*/@define-color secondary $secondary;/" "$CSS_FILE"
sed --follow-symlinks -i "s/@define-color tertiary .*/@define-color tertiary $tertiary;/" "$CSS_FILE"
sed --follow-symlinks -i "s/@define-color quaternary .*/@define-color quaternary $quaternary;/" "$CSS_FILE"
sed --follow-symlinks -i "s|@theme .*|@theme \"$theme\"|" "$THEME_FILE"
primary=$(echo $primary | cut -f2 -d"#")"ee"
sed --follow-symlinks -i "s/col.active_border.*/col.active_border=rgba\($primary\)/g" "$HYPRLAND_FILE"
sed --follow-symlinks -i "s/vim.cmd.colorscheme.*/vim.cmd.colorscheme \"$nvim\"/g" "$NVIM_FILE"
echo "color is $prompt_color"
sed --follow-symlinks -i "s|=\"%F{.*}\"|=\"%F{$prompt_color}\"|g" "$ZSHLINE_FILE"
sed --follow-symlinks -i "s|selection_background .*|selection_background $prompt_color|g" "$KITTY_FILE"
# Hyprpaper 0.8+ uses wallpaper blocks. An empty monitor matches all outputs.
# Keep the selected wallpaper in the normal config so a restart restores it.
HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"
cat > "$HYPRPAPER_CONFIG" <<EOF
wallpaper {
    monitor =
    path = $selected_file
    fit_mode = cover
}
EOF

pkill -u "$UID" -x hyprpaper || true
# Wait for the old instance to release its socket before starting another.
for ((attempt = 0; attempt < 50; attempt++)); do
    pgrep -u "$UID" -x hyprpaper >/dev/null || break
    sleep 0.1
done
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
mkdir -p "$STATE_DIR"
nohup setsid hyprpaper -c "$HYPRPAPER_CONFIG" > "$STATE_DIR/hyprpaper.log" 2>&1 9>&- < /dev/null &

echo "Applied wallpaper: $selected_file"

# Refresh an existing bar without restarting it or starting a second instance.
if pgrep -u "$UID" -f '/ags-compat/launcher.js' >/dev/null; then
    "$HOME/.local/bin/ags" -r 'App.resetCss(); App.applyCss(App.configDir + "/style.css");' 9>&-
fi
