#!/bin/bash

# ASCII Art
cat << "EOF"
░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓███████▓▒░░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 ░▒▓█▓▒▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
 ░▒▓█▓▒▒▓█▓▒░░▒▓████████▓▒░▒▓███████▓▒░░▒▓███████▓▒░ ░▒▓██████▓▒░ ░▒▓██████▓▒░
  ░▒▓█▓▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░
  ░▒▓█▓▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░
   ░▒▓██▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░
EOF

# Attribution
echo -e "                     Created by https://github.com/varrxy                   "
echo -e "============================================================================"

# Set the directory for the scripts
SCRIPT_DIR="./scripts"

# Function to run a script and check for success
run_script() {
    echo "Running $1..."
    if ! bash "$SCRIPT_DIR/$1"; then
        echo "Failed to run $1. Exiting."
        exit 1
    fi
}

# Ask user if they want to install Swap
read -p "Do you want to setup SWAPFILE? (y/n): " setup_swap
if [[ "$setup_swap" == "y" ]]; then
    run_script "swap.sh"
fi

# Ask user if they want to install Hibernate
read -p "Do you want to setup HIBERNATE? (y/n): " setup_hiber
if [[ "$setup_hiber" == "y" ]]; then
    run_script "hibernate.sh"
fi

# Ask user if they want to install Pipewire
read -p "Do you want to setup Pipewire-Audio? (y/n): " setup_pipe
if [[ "$setup_pipe" == "y" ]]; then
    run_script "pipewire.sh"
fi


# Install prerequisites
run_script "yay.sh"

# Ask user if they want to install NVIDIA
read -p "Do you want to install NVIDIA drivers? (y/n): " install_nvidia
if [[ "$install_nvidia" == "y" ]]; then
    run_script "nvidia.sh"
fi

# Ask user if they want to install Hyprland
read -p "Do you want to install Hyprland? (y/n): " install_hypr
if [[ "$install_hypr" == "y" ]]; then
    run_script "hyprland.sh"
fi

# Ask user if they want to install themes
read -p "Do you want to apply themes? (y/n): " install_themes
if [[ "$install_themes" == "y" ]]; then
    echo "Installing themes..."
    run_script "theme.sh"
fi

# Ask user if they want to setup MPD
read -p "Do you want to setup MPD? (y/n): " setup_mpd
if [[ "$setup_mpd" == "y" ]]; then
    run_script "mpd.sh"
fi

# Install Zsh last
read -p "Do you want to install Zsh? (y/n): " install_zsh
if [[ "$install_zsh" == "y" ]]; then
    run_script "zsh.sh"
fi

# Final message and reboot prompt
echo "Setup complete! Would you like to reboot now? (y/n): "
read -p "Reboot now? (y/n): " reboot_now
if [[ "$reboot_now" == "y" ]]; then
    echo "Rebooting..."
    sudo reboot
else
    echo "Setup complete! You can reboot later."
fi
