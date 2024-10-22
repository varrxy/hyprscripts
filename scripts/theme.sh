#!/bin/bash

# Define colors
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Define log file
LOG_DIR="./log"
LOG_FILE="$LOG_DIR/theme_apply.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Define themes and fonts
GTK_THEME='catppuccin-macchiato-blue-standard+default'
ICON_THEME='Tokyonight-Moon'
CURSOR_THEME='catppuccin-macchiato-blue-cursors'
FONT_NAME='JetBrainsMono Nerd Font 10'
MONOSPACE_FONT_NAME='JetBrainsMono Nerd Font 10'

# Set the GNOME schema for GTK applications
gnome_schema="org.gnome.desktop.interface"

# Function to apply settings and log the outcome
apply_setting() {
    local setting_name="$1"
    local setting_value="$2"
    
    if gsettings set "$gnome_schema" "$setting_name" "$setting_value"; then
        log "${GREEN}Successfully applied $setting_name: $setting_value${NC}"
    else
        log "${RED}Failed to apply $setting_name: $setting_value${NC}"
    fi
}

# Apply the themes and font settings
apply_setting "gtk-theme" "$GTK_THEME"
apply_setting "icon-theme" "$ICON_THEME"
apply_setting "cursor-theme" "$CURSOR_THEME"
apply_setting "font-name" "$FONT_NAME"
apply_setting "monospace-font-name" "$MONOSPACE_FONT_NAME"

log "${GREEN}Theme and font settings applied successfully.${NC}"
