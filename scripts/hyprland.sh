#!/bin/bash

# Define colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Define log file
LOG_DIR="./log"
LOG_FILE="$LOG_DIR/hyprland_install.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Update System
log "${YELLOW}Updating system...${NC}"
if sudo pacman -Syu --noconfirm &>> "$LOG_FILE"; then
    log "${GREEN}System updated successfully.${NC}"
else
    log "${RED}Failed to update system.${NC}"
    exit 1
fi

# Install Hyprland and Related Applications
packages=(
    "hyprland"
    "kitty"
    "thunar"
    "wofi"
    "waybar"
    "wlogout"
    "swaync"
    "xdg-desktop-portal-hyprland"
    "qt5-wayland"
    "qt6-wayland"
    "qt5ct"
    "polkit-kde-agent"
    "ttf-jetbrains-mono-nerd"
    "grim"
    "slurp"
    "git"
    "hypridle"
    "hyprlock"
    "swww"
    "brightnessctl"
    "guvcview"
    "btop"
    "nwg-look"
)

# Install packages
for package in "${packages[@]}"; do
    log "${YELLOW}Installing $package...${NC}"
    if yay -S --noconfirm "$package" &>> "$LOG_FILE"; then
        log "${GREEN}$package installed successfully.${NC}"
    else
        log "${RED}Failed to install $package.${NC}"
        exit 1
    fi
done

# Clone the GitHub repository
log "${YELLOW}Cloning GitHub repository...${NC}"
if git clone https://github.com/varrxy/hyprwm-setup.git /tmp/hyprwm-setup &>> "$LOG_FILE"; then
    log "${GREEN}Repository cloned successfully.${NC}"
else
    log "${RED}Failed to clone repository.${NC}"
    exit 1
fi

# Create necessary directories if they don't exist
log "${YELLOW}Creating necessary directories...${NC}"
mkdir -p ~/.config/ ~/.icons/ ~/.themes/ ~/Pictures/Wallpapers

# Copy configuration files
log "${YELLOW}Copying configuration files...${NC}"
cp -r /tmp/hyprwm-setup/.config/* ~/.config/ &>> "$LOG_FILE" && \
cp -r /tmp/hyprwm-setup/.themes/* ~/.themes/ &>> "$LOG_FILE" && \
cp -r /tmp/hyprwm-setup/.icons/* ~/.icons/ &>> "$LOG_FILE" && \
cp -r /tmp/hyprwm-setup/wallpapers/* ~/Pictures/Wallpapers &>> "$LOG_FILE"

log "${GREEN}Configuration files copied successfully.${NC}"

# Clean up
log "${YELLOW}Cleaning up...${NC}"
rm -rf /tmp/hyprwm-setup
log "${GREEN}Installation script completed.${NC}"
