#!/bin/bash

# Define log file
LOG_DIR="./log"
LOG_FILE="$LOG_DIR/hyprland_install.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Define colors
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Function to log messages
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if a swap file already exists
if sudo swapon --show | grep -q "/swapfile"; then
    log "${YELLOW}A swap file already exists. Skipping creation.${NC}"
else
    # Prompt the user for the swap file size in GB
    read -p "Enter the size of the swap file in GB (e.g., 1 for 1G): " SWAP_SIZE_GB

    # Validate input
    if ! [[ $SWAP_SIZE_GB =~ ^[0-9]+$ ]]; then
        log "${RED}Invalid input. Please enter a number.${NC}"
        exit 1
    fi

    # Convert GB to bytes for fallocate
    SWAP_SIZE="${SWAP_SIZE_GB}G"
    SWAPFILE="/swapfile"

    # Create the swap file
    log "${GREEN}Creating swap file of size $SWAP_SIZE...${NC}"
    if sudo fallocate -l $SWAP_SIZE $SWAPFILE; then
        log "${GREEN}Swap file created successfully.${NC}"
    else
        log "${RED}Failed to create swap file.${NC}"
        exit 1
    fi

    # Set the correct permissions
    log "${GREEN}Setting permissions on $SWAPFILE...${NC}"
    if sudo chmod 600 $SWAPFILE; then
        log "${GREEN}Permissions set successfully.${NC}"
    else
        log "${RED}Failed to set permissions.${NC}"
        exit 1
    fi

    # Set up the swap space
    log "${GREEN}Setting up swap space...${NC}"
    if sudo mkswap $SWAPFILE; then
        log "${GREEN}Swap space set up successfully.${NC}"
    else
        log "${RED}Failed to set up swap space.${NC}"
        exit 1
    fi

    # Enable the swap file
    log "${GREEN}Enabling swap file...${NC}"
    if sudo swapon $SWAPFILE; then
        log "${GREEN}Swap file enabled successfully.${NC}"
    else
        log "${RED}Failed to enable swap file.${NC}"
        exit 1
    fi

    # Confirm the swap is active
    log "${GREEN}Current swap space:${NC}"
    sudo swapon --show

    # Optionally, make the change permanent by adding it to fstab
    if ! grep -q "$SWAPFILE" /etc/fstab; then
        log "${GREEN}Adding swap file to /etc/fstab for persistence...${NC}"
        if echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab; then
            log "${GREEN}Swap file added to /etc/fstab successfully.${NC}"
        else
            log "${RED}Failed to add swap file to /etc/fstab.${NC}"
            exit 1
        fi
    fi
fi

log "${GREEN}Script executed successfully.${NC}"
