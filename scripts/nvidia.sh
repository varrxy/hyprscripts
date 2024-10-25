#!/bin/bash

# Directory for logs
# Define colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Log file
LOG_DIR="./log"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/nvidia_setup.log"

# Function to log messages
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# Update the system
log "Updating the system..."
if sudo pacman -Syu --noconfirm linux-lts-headers; then
    echo -e "${GREEN}System updated successfully.${NC}"
    log "System updated successfully."
else
    echo -e "${RED}Failed to update system.${NC}"
    log "Failed to update system."
    exit 1
fi

# Install NVIDIA packages
log "Installing NVIDIA packages..."
if sudo pacman -S --noconfirm nvidia-dkms nvidia-utils egl-wayland libva-nvidia-driver nvidia-settings; then
    echo -e "${GREEN}NVIDIA packages installed successfully.${NC}"
    log "NVIDIA packages installed successfully."
else
    echo -e "${RED}Failed to install NVIDIA packages.${NC}"
    log "Failed to install NVIDIA packages."
    exit 1
fi

# Update mkinitcpio.conf
log "Updating /etc/mkinitcpio.conf..."
if ! grep -q "nvidia" /etc/mkinitcpio.conf; then
    sudo sed -i '/^MODULES=/ s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    log "Added NVIDIA modules to mkinitcpio.conf."
else
    log "NVIDIA modules already present in mkinitcpio.conf."
fi

# Rebuild the initramfs
log "Rebuilding initramfs..."
if sudo mkinitcpio -P; then
    log "Initramfs rebuilt successfully."
else
    log "Initramfs rebuild failed."
    exit 1
fi

# Enable NVIDIA suspend services
log "Enabling NVIDIA suspend services..."
if sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service; then
    log "NVIDIA suspend services enabled successfully."
else
    log "Failed to enable NVIDIA suspend services."
    exit 1
fi

# Final log and reboot reminder
log "NVIDIA setup completed. Please reboot your system to apply changes."
echo -e "${GREEN}Installation complete! The services are enabled and running.${NC}"
log "Installation complete! The services are enabled and running."
