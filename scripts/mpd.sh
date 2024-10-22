#!/bin/bash

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Create a directory for playlists
echo -e "${YELLOW}Creating playlists directory...${NC}"
mkdir -p ~/Music/playlists

# Install MPD and Ario
echo -e "${YELLOW}Installing MPD and Ario...${NC}"
if sudo pacman -Syu --noconfirm mpd ario; then
    echo -e "${GREEN}Installation successful!${NC}"
else
    echo -e "${RED}Installation failed! Please check for errors.${NC}"
    exit 1
fi

# Enable the MPD service for the current user
echo -e "${YELLOW}Enabling MPD service...${NC}"
if systemctl --user enable mpd.service; then
    echo -e "${GREEN}MPD service enabled successfully!${NC}"
else
    echo -e "${RED}Failed to enable MPD service!${NC}"
    exit 1
fi

echo -e "${GREEN}Setup complete! MPD and Ario installed, and MPD service enabled.${NC}"
