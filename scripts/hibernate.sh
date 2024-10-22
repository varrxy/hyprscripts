#!/bin/bash

# Define colors
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Define log file
LOG_DIR="./log"
LOG_FILE="$LOG_DIR/hyprland_hibernation.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Variables
SWAP_FILE="/swapfile"  # Change this if your swap file is located elsewhere

# Function to check if command succeeded
check_command() {
    if [ $? -ne 0 ]; then
        log "${RED}Error: $1${NC}"
        exit 1
    fi
}

# Check if the swap file exists
if [ ! -f "$SWAP_FILE" ]; then
    log "${RED}Swap file $SWAP_FILE not found!${NC}"
    exit 1
fi

# Get the UUID of the root partition
UUID=$(findmnt / -o UUID -n)
check_command "Failed to get UUID of the root partition."

# Get the swap file's offset
OFFSET=$(sudo filefrag -v "$SWAP_FILE" | awk 'NR==4{gsub(/\./,"");print $4;}')
check_command "Failed to get swap file offset."

# Update /etc/default/grub
GRUB_CONFIG="/etc/default/grub"

# Check if hibernation is already configured
if grep -q "resume=UUID=$UUID resume_offset=$OFFSET" "$GRUB_CONFIG"; then
    log "${YELLOW}Hibernation is already set up correctly.${NC}"
    exit 0
fi

if grep -q "GRUB_CMDLINE_LINUX_DEFAULT" "$GRUB_CONFIG"; then
    sudo sed -i.bak "s|GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"|GRUB_CMDLINE_LINUX_DEFAULT=\"\1 resume=UUID=$UUID resume_offset=$OFFSET\"|" "$GRUB_CONFIG"
    check_command "Failed to update GRUB configuration."
else
    log "${RED}GRUB_CMDLINE_LINUX_DEFAULT not found in $GRUB_CONFIG.${NC}"
    exit 1
fi

# Create or update /etc/mkinitcpio.conf
MKINITCPIO_CONFIG="/etc/mkinitcpio.conf"

if grep -q "resume=UUID=$UUID resume_offset=$OFFSET" "$MKINITCPIO_CONFIG"; then
    log "${YELLOW}Hibernation configuration is already present in $MKINITCPIO_CONFIG.${NC}"
else
    sudo sed -i "s|^HOOKS=(.*)|HOOKS=(\1 resume)|" "$MKINITCPIO_CONFIG"
    check_command "Failed to update mkinitcpio hooks."
    echo "resume=UUID=$UUID resume_offset=$OFFSET" | sudo tee /etc/initcpio/resume.conf > /dev/null
    check_command "Failed to create initramfs resume configuration."
fi

# Update grub and initramfs
sudo grub-mkconfig -o /boot/grub/grub.cfg
check_command "Failed to update GRUB."
sudo mkinitcpio -P
check_command "Failed to update initramfs."

# Confirmation message
log "${GREEN}Hibernation configuration complete. You can test it with 'systemctl hibernate'.${NC}"
