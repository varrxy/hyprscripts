#!/bin/bash

# Define colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Define log file
LOG_DIR="./log"
LOG_FILE="$LOG_DIR/pipewire_install.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Update System
log "${YELLOW}Updating system...${NC}"
if sudo pacman -Syu --noconfirm &>> "$LOG_FILE"; then
    log "${GREEN}System updated successfully.${NC}"
else
    log "${RED}Failed to update system.${NC}"
    exit 1
fi

# Install PipeWire and Bluetooth Packages
log "${YELLOW}Installing PipeWire and Bluetooth packages...${NC}"
if sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber bluez bluez-utils blueman &>> "$LOG_FILE"; then
    log "${GREEN}PipeWire and Bluetooth packages installed successfully.${NC}"
else
    log "${RED}Failed to install PipeWire and Bluetooth packages.${NC}"
    exit 1
fi

# Enable and Start PipeWire Services
log "${YELLOW}To enable and start the necessary services, run the following commands:${NC}"
echo -e "${YELLOW}systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service${NC}"
echo -e "${YELLOW}systemctl --user start pipewire.service pipewire-pulse.service wireplumber.service${NC}"
echo -e "${YELLOW}sudo systemctl enable bluetooth.service${NC}"
echo -e "${YELLOW}sudo systemctl start bluetooth.service${NC}"

log "${GREEN}Installation complete! Please run the above commands to enable the services.${NC}"
