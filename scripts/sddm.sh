#!/bin/bash

# Set up color output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Create log directory
LOG_DIR="./log"
mkdir -p "$LOG_DIR"

# Log file
LOG_FILE="$LOG_DIR/install_sddm.log"

# Function to log messages with timestamp
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Update system and install required packages
log "Updating system and installing SDDM and dependencies..."
if sudo pacman -Syu sddm qt5-graphicaleffects qt5-svg qt5-quickcontrols2 --noconfirm; then
    log "${GREEN}SDDM and dependencies installed successfully.${NC}"
else
    log "${RED}Failed to install SDDM and dependencies.${NC}"
    exit 1
fi

# Clone Simple SDDM theme
log "Cloning Simple SDDM theme..."
if git clone https://github.com/varrxy/simple-sddm; then
    log "${GREEN}Theme cloned successfully.${NC}"
else
    log "${RED}Failed to clone theme.${NC}"
    exit 1
fi

# Move theme to the appropriate directory
log "Moving theme to /usr/share/sddm/themes..."
if sudo mv simple-sddm /usr/share/sddm/themes; then
    log "${GREEN}Theme moved successfully.${NC}"
else
    log "${RED}Failed to move theme.${NC}"
    exit 1
fi

# Edit SDDM configuration
log "Editing /etc/sddm.conf..."
CONFIG_FILE="/etc/sddm.conf"
if grep -q "\[Theme\]" "$CONFIG_FILE"; then
    echo "Current=simple-sddm" | sudo tee -a "$CONFIG_FILE" > /dev/null
else
    echo -e "\n[Theme]\nCurrent=simple-sddm" | sudo tee -a "$CONFIG_FILE" > /dev/null
fi
log "${GREEN}SDDM configuration updated successfully.${NC}"

log "Installation and configuration complete. Check $LOG_FILE for details."
