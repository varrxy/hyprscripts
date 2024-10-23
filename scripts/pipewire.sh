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
echo -e "${YELLOW}Enabling and starting the necessary services...${NC}"

if systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service; then
    echo -e "${GREEN}PipeWire services enabled.${NC}"
else
    echo -e "${RED}Failed to enable PipeWire services.${NC}"
fi

if systemctl --user start pipewire.service pipewire-pulse.service wireplumber.service; then
    echo -e "${GREEN}PipeWire services started.${NC}"
else
    echo -e "${RED}Failed to start PipeWire services.${NC}"
fi

if sudo systemctl enable bluetooth.service; then
    echo -e "${GREEN}Bluetooth service enabled.${NC}"
else
    echo -e "${RED}Failed to enable Bluetooth service.${NC}"
fi

if sudo systemctl start bluetooth.service; then
    echo -e "${GREEN}Bluetooth service started.${NC}"
else
    echo -e "${RED}Failed to start Bluetooth service.${NC}"
fi

echo -e "${GREEN}Installation complete! The services are enabled and running.${NC}"
