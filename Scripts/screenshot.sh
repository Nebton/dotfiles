#!/bin/bash

# Directory to save screenshots
Screenshots_dir="${XDG_SCREENSHOTS_DIR:-$HOME/Screenshots}"

# Ensure the screenshots directory exists
mkdir -p "$Screenshots_dir"

# Function to show a notification
notify() {
  dunstify "$1" -t 1000
}

# Function to check if required dependencies are installed
check_dependencies() {
  for cmd in zenity grim slurp wl-copy wl-paste dunstify; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "$cmd is required but not installed. Exiting."
      exit 1
    fi
  done
}

# Check for necessary dependencies
check_dependencies

# Take a screenshot
if [ "$1" = "region" ]; then
  # Take a screenshot of the selected region
  screenshot_data=$(grim -g "$(slurp -w 0)" - | wl-copy -t image/png && wl-paste)
  notify "Screenshot of the region taken"
else
  # Take a screenshot of the whole screen
  screenshot_data=$(grim - | wl-copy -t image/png && wl-paste)
  notify "Screenshot of the whole screen taken"
fi

# Prompt for screenshot name after taking it
screenshot_name=$(zenity --entry --title="Screenshot Name" --text="Enter a name for the screenshot:" --entry-text="Screenshot-$(date +%F_%T)")

# Check if a name was provided
if [ -z "$screenshot_name" ]; then
  exit 1
fi

# Save the screenshot
echo "$screenshot_data" > "$Screenshots_dir/$screenshot_name.png"
notify "Screenshot saved as $screenshot_name.png"

