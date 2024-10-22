#!/bin/bash

# Directory for logs
LOG_DIR="./log"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/nvidia_setup.log"

# Function to log messages
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# Update the system
log "Updating the system..."
sudo pacman -Syu --noconfirm || { log "System update failed"; exit 1; }

# Install NVIDIA packages
log "Installing NVIDIA packages..."
sudo pacman -S --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils egl-wayland libva-nvidia-driver nvidia-settings linux-headers-$(uname -r) || { log "Installation failed"; exit 1; }

# Update mkinitcpio.conf
log "Updating /etc/mkinitcpio.conf..."
if ! grep -q "nvidia" /etc/mkinitcpio.conf; then
    sudo sed -i '/^MODULES=/ s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    log "Added NVIDIA modules to mkinitcpio.conf."
else
    log "NVIDIA modules already present in mkinitcpio.conf."
fi

# Create or update /etc/modprobe.d/nvidia.conf
log "Creating /etc/modprobe.d/nvidia.conf..."
echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee /etc/modprobe.d/nvidia.conf

# Rebuild the initramfs
log "Rebuilding initramfs..."
sudo mkinitcpio -P || { log "Initramfs rebuild failed"; exit 1; }

# Enable NVIDIA suspend services
log "Enabling NVIDIA suspend services..."
sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service

# Final log and reboot reminder
log "NVIDIA setup completed. Please reboot your system to apply changes."
