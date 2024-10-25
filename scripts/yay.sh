#!/bin/bash

# Define log file
LOG_DIR="/tmp/log"
LOG_FILE="$LOG_DIR/yay_install.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages with color
log() {
    local COLOR="$1"
    local MESSAGE="$2"
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - \e[${COLOR}m${MESSAGE}\e[0m" | tee -a "$LOG_FILE"
}

# Define color codes
GREEN="32"
YELLOW="33"
RED="31"
BLUE="34"

# Check if yay is already installed
if command -v yay &> /dev/null; then
    log "$GREEN" "yay is already installed. Exiting."
    exit 0
fi

# Update the system and install dependencies
log "$BLUE" "Updating system and installing dependencies..."
if sudo pacman -S --noconfirm git base-devel &>> "$LOG_FILE"; then
    log "$GREEN" "Dependencies installed successfully."
else
    log "$RED" "Failed to install dependencies."
    exit 1
fi

# Clone yay repository
log "$BLUE" "Cloning yay repository..."
if git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin &>> "$LOG_FILE"; then
    log "$GREEN" "Successfully cloned yay repository."
else
    log "$RED" "Failed to clone yay repository."
    exit 1
fi

# Navigate to the yay directory
cd /tmp/yay-bin || { log "$RED" "Failed to change directory to /tmp/yay-bin."; exit 1; }

# Build and install yay
log "$BLUE" "Building and installing yay..."
if makepkg -si --noconfirm &>> "$LOG_FILE"; then
    log "$GREEN" "yay installed successfully."
else
    log "$RED" "Failed to install yay."
    exit 1
fi

log "$GREEN" "Script completed."
