#!/bin/bash

# Define colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Update System
echo -e "${YELLOW}Updating system...${NC}"
if sudo pacman -Syu --noconfirm; then
    echo -e "${GREEN}System updated successfully.${NC}"
else
    echo -e "${RED}Failed to update system.${NC}"
    exit 1
fi

# Install PipeWire and Bluetooth Packages
echo -e "${YELLOW}Installing PipeWire and Bluetooth packages...${NC}"
if sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber bluez bluez-utils blueman network-manager-applet; then
    echo -e "${GREEN}PipeWire and Bluetooth packages installed successfully.${NC}"
else
    echo -e "${RED}Failed to install PipeWire and Bluetooth packages.${NC}"
    exit 1
fi

# Enable and Start PipeWire Services
echo -e "${YELLOW}To enable and start the necessary services, run the following commands:${NC}"
echo -e "${YELLOW}systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service${NC}"
echo -e "${YELLOW}systemctl --user start pipewire.service pipewire-pulse.service wireplumber.service${NC}"
echo -e "${YELLOW}sudo systemctl enable bluetooth.service${NC}"
echo -e "${YELLOW}sudo systemctl start bluetooth.service${NC}"

echo -e "${GREEN}Installation complete! Please run the above commands to enable the services.${NC}"
