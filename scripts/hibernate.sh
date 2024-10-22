#!/bin/bash

# Log file and directory
LOG_DIR="./log"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/hibernation_setup.log"

# Color codes for output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RESET="\033[0m"

# Function to log messages
log() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# Check if hibernation is already set up
if grep -q "resume=" /etc/default/grub; then
    log "${YELLOW}Hibernation is already set up!${RESET}"
    exit 1
fi

# Check if a swap file exists
if [ ! -f /swapfile ]; then
    log "${YELLOW}Swap file not found. Creating a 4GB swap file...${RESET}"
    
    # Create a swap file
    sudo fallocate -l 4G /swapfile || { log "${RED}Failed to create swap file.${RESET}"; exit 1; }
    
    # Set permissions
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile

    # Make it permanent
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
else
    log "${GREEN}Swap file already exists.${RESET}"
fi

# Get the UUID of the root partition
UUID=$(findmnt / -o UUID -n)

# Get the resume offset using filefrag
RESUME_OFFSET=$(sudo filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}')

# Update GRUB configuration
log "${GREEN}Updating GRUB configuration...${RESET}"
if ! grep -q "resume=" /etc/default/grub; then
    sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=\"|&resume=UUID=${UUID} resume_offset=${RESUME_OFFSET} |" /etc/default/grub
    log "${GREEN}Added resume parameter to GRUB with UUID and offset.${RESET}"
else
    log "${YELLOW}Resume parameter already present in GRUB.${RESET}"
fi

# Update GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Modify mkinitcpio.conf
log "${GREEN}Updating /etc/mkinitcpio.conf...${RESET}"
if ! grep -q "\<resume\>" /etc/mkinitcpio.conf; then
    sudo sed -i 's|\(HOOKS=(.*udev\)\(.*\)|\1 resume\2|' /etc/mkinitcpio.conf
    log "${GREEN}Added resume hook to mkinitcpio.conf.${RESET}"
else
    log "${YELLOW}Resume hook already present in mkinitcpio.conf.${RESET}"
fi

# Rebuild initramfs
log "${GREEN}Rebuilding initramfs...${RESET}"
sudo mkinitcpio -P

log "${GREEN}Hibernation setup completed. Please test it by running 'sudo systemctl hibernate'.${RESET}"
