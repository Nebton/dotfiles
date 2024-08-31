#!/bin/bash

Screenshots_dir="${XDG_SCREENSHOTS_DIR:-$HOME/Screenshots}"

# Prompt for screenshot name
screenshot_name=$(zenity --entry --title="Screenshot Name" --text="Enter a name for the screenshot:" --entry-text="Screenshot-$(date +%F_%T)")

# Check if a name was provided
if [ -z "$screenshot_name" ]; then
  exit 1
fi

# Take the screenshot of the selected region
if [ "$1" = "region" ]; then
  grim -g "$(slurp -w 0)" - | wl-copy -t image/png && wl-paste > "$Screenshots_dir/$screenshot_name.png"
  dunstify "Screenshot of the region taken" -t 1000
else
  # Take the screenshot of the whole screen
  grim - | wl-copy -t image/png && wl-paste > "$Screenshots_dir/$screenshot_name.png"
  dunstify "Screenshot of the whole screen taken" -t 1000
fi

