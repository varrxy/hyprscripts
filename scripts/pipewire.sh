#!/bin/bash

# Define colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Log file setup
LOG_DIR="$(dirname "$0")/log"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/pipewire.log"

# Function to log messages
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# Update System
log "Updating system..."
echo -e "${YELLOW}Updating system...${NC}"
if sudo pacman -Syu --noconfirm; then
    echo -e "${GREEN}System updated successfully.${NC}"
    log "System updated successfully."
else
    echo -e "${RED}Failed to update system.${NC}"
    log "Failed to update system."
    exit 1
fi

# Install PipeWire and Bluetooth Packages
log "Installing PipeWire and Bluetooth packages..."
echo -e "${YELLOW}Installing PipeWire and Bluetooth packages...${NC}"
if sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber bluez bluez-utils blueman network-manager-applet; then
    echo -e "${GREEN}PipeWire and Bluetooth packages installed successfully.${NC}"
    log "PipeWire and Bluetooth packages installed successfully."
else
    echo -e "${RED}Failed to install PipeWire and Bluetooth packages.${NC}"
    log "Failed to install PipeWire and Bluetooth packages."
    exit 1
fi

# Enable and Start PipeWire Services
log "Enabling and starting the necessary services..."
echo -e "${YELLOW}Enabling and starting the necessary services...${NC}"

if systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service; then
    echo -e "${GREEN}PipeWire services enabled.${NC}"
    log "PipeWire services enabled."
else
    echo -e "${RED}Failed to enable PipeWire services.${NC}"
    log "Failed to enable PipeWire services."
fi

if systemctl --user start pipewire.service pipewire-pulse.service wireplumber.service; then
    echo -e "${GREEN}PipeWire services started.${NC}"
    log "PipeWire services started."
else
    echo -e "${RED}Failed to start PipeWire services.${NC}"
    log "Failed to start PipeWire services."
fi

if sudo systemctl enable bluetooth.service; then
    echo -e "${GREEN}Bluetooth service enabled.${NC}"
    log "Bluetooth service enabled."
else
    echo -e "${RED}Failed to enable Bluetooth service.${NC}"
    log "Failed to enable Bluetooth service."
fi

if sudo systemctl start bluetooth.service; then
    echo -e "${GREEN}Bluetooth service started.${NC}"
    log "Bluetooth service started."
else
    echo -e "${RED}Failed to start Bluetooth service.${NC}"
    log "Failed to start Bluetooth service."
fi

echo -e "${GREEN}Installation complete! The services are enabled and running.${NC}"
log "Installation complete! The services are enabled and running."
