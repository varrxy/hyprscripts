#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file setup
LOG_DIR="$(dirname "$0")/log"
LOG_FILE="$LOG_DIR/installation.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages with timestamps
log() {
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

# Function to check if a package is installed
is_installed() {
    pacman -Qs "$1" > /dev/null 2>&1
}

# Function to check if a line exists in a file
line_exists() {
    grep -Fxq "$1" "$2"
}

# Update the system
log "${BLUE}Updating the system...${NC}"
if sudo pacman -Syu >> "$LOG_FILE" 2>&1; then
    log "${GREEN}System updated successfully.${NC}"
else
    log "${RED}Failed to update the system.${NC}"
    exit 1
fi

# Install NVIDIA drivers and utilities if not already installed
if ! is_installed "nvidia-dkms"; then
    log "${YELLOW}Installing NVIDIA driver and utilities...${NC}"
    if sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils egl-wayland >> "$LOG_FILE" 2>&1; then
        log "${GREEN}NVIDIA driver and utilities installed successfully.${NC}"
    else
        log "${RED}Failed to install NVIDIA driver and utilities.${NC}"
        exit 1
    fi
else
    log "${GREEN}NVIDIA driver and utilities are already installed.${NC}"
fi

# Configure Kernel Mode Setting
KERNEL_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

# Check if modules are already added
if ! line_exists "MODULES=(... $KERNEL_MODULES ...)" "$MKINITCPIO_CONF"; then
    log "${YELLOW}Adding NVIDIA modules to mkinitcpio.conf...${NC}"
    sudo sed -i "/MODULES=(/ s/)/ $KERNEL_MODULES \1/" "$MKINITCPIO_CONF" >> "$LOG_FILE" 2>&1
    log "${GREEN}NVIDIA modules added to mkinitcpio.conf.${NC}"
else
    log "${GREEN}NVIDIA modules are already present in mkinitcpio.conf.${NC}"
fi

# Create and edit NVIDIA configuration file
NVIDIA_CONF="/etc/modprobe.d/nvidia.conf"
if ! line_exists "options nvidia_drm modeset=1 fbdev=1" "$NVIDIA_CONF"; then
    log "${YELLOW}Creating nvidia.conf...${NC}"
    echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee "$NVIDIA_CONF" >> "$LOG_FILE" 2>&1
    log "${GREEN}NVIDIA configuration file created.${NC}"
else
    log "${GREEN}NVIDIA configuration already exists.${NC}"
fi

# Rebuild the initramfs if changes were made
log "${BLUE}Rebuilding initramfs...${NC}"
if sudo mkinitcpio -P >> "$LOG_FILE" 2>&1; then
    log "${GREEN}Initramfs rebuilt successfully.${NC}"
else
    log "${RED}Failed to rebuild initramfs.${NC}"
    exit 1
fi

# Install VA-API driver if not installed
if ! is_installed "libva-nvidia-driver"; then
    log "${YELLOW}Installing VA-API driver...${NC}"
    if sudo pacman -S libva-nvidia-driver >> "$LOG_FILE" 2>&1; then
        log "${GREEN}VA-API driver installed successfully.${NC}"
    else
        log "${RED}Failed to install VA-API driver.${NC}"
        exit 1
    fi
else
    log "${GREEN}VA-API driver is already installed.${NC}"
fi

# Enable NVIDIA suspend/resume services
log "${BLUE}Enabling NVIDIA suspend/resume services...${NC}"
for service in nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service; do
    if ! systemctl is-enabled "$service" > /dev/null 2>&1; then
        sudo systemctl enable "$service" >> "$LOG_FILE" 2>&1
        log "${GREEN}$service enabled.${NC}"
    else
        log "${GREEN}$service is already enabled.${NC}"
    fi
done

# Edit GRUB configuration
GRUB_CONF="/etc/default/grub"
if ! line_exists "nvidia.NVreg_PreserveVideoMemoryAllocations=1" "$GRUB_CONF"; then
    log "${YELLOW}Updating GRUB configuration...${NC}"
    sudo sed -i "/GRUB_CMDLINE_LINUX_DEFAULT/ s/\"/\"nvidia.NVreg_PreserveVideoMemoryAllocations=1 /" "$GRUB_CONF" >> "$LOG_FILE" 2>&1
    log "${YELLOW}Updating GRUB...${NC}"
    sudo grub-mkconfig -o /boot/grub/grub.cfg >> "$LOG_FILE" 2>&1
    log "${GREEN}GRUB configuration updated successfully.${NC}"
else
    log "${GREEN}GRUB configuration already includes NVIDIA options.${NC}"
fi

# Final message about reboot
log "${BLUE}Please reboot the system for changes to take effect.${NC}"
