#!/bin/bash

# Define log file
LOG_DIR="./log"
LOG_FILE="$LOG_DIR/yay_install.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if yay is already installed
if command -v yay &> /dev/null; then
    log "yay is already installed. Exiting."
    exit 0
fi

# Update the system and install dependencies
log "Updating system and installing dependencies..."
if pacman -S --needed git base-devel &>> "$LOG_FILE"; then
    log "Dependencies installed successfully."
else
    log "Failed to install dependencies."
    exit 1
fi

# Clone yay repository
log "Cloning yay repository..."
if git clone https://aur.archlinux.org/yay-bin.git &>> "$LOG_FILE"; then
    log "Successfully cloned yay repository."
else
    log "Failed to clone yay repository."
    exit 1
fi

# Navigate to the yay directory
cd yay-bin || { log "Failed to change directory to yay-bin."; exit 1; }

# Build and install yay
log "Building and installing yay..."
if makepkg -si --noconfirm &>> "$LOG_FILE"; then
    log "yay installed successfully."
else
    log "Failed to install yay."
    exit 1
fi

log "Script completed."
