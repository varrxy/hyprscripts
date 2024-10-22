#!/bin/bash

# Directory for logs
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/nvidia_setup.log"

# Function to log messages
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    log "Please run as root."
    exit 1
fi

# Update the system
log "Updating the system..."
sudo pacman -Syu --noconfirm

# Install NVIDIA packages
log "Installing NVIDIA packages..."
sudo pacman -S --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils egl-wayland libva-nvidia-driver

# Update mkinitcpio.conf
log "Updating /etc/mkinitcpio.conf..."
if ! grep -q "nvidia" /etc/mkinitcpio.conf; then
    sed -i '/^MODULES=/ s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    log "Added NVIDIA modules to mkinitcpio.conf."
else
    log "NVIDIA modules already present in mkinitcpio.conf."
fi

# Create or update /etc/modprobe.d/nvidia.conf
log "Creating /etc/modprobe.d/nvidia.conf..."
echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee /etc/modprobe.d/nvidia.conf

# Rebuild the initramfs
log "Rebuilding initramfs..."
sudo mkinitcpio -P

# Enable NVIDIA suspend services
log "Enabling NVIDIA suspend services..."
sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service

# Final log and reboot
log "NVIDIA setup completed. Please reboot your system."
