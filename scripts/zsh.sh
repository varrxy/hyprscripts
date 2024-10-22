#!/bin/bash

# Define colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Define log file
LOG_DIR="./log"
LOG_FILE="$LOG_DIR/zsh_setup.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to add a line to .zshrc if it doesn't exist
add_line() {
    if ! grep -qxF "$1" "$HOME/.zshrc"; then
        echo "$1" >> "$HOME/.zshrc"
        log "${GREEN}Added to .zshrc: $1${NC}"
    else
        log "${YELLOW}Line already exists in .zshrc: $1${NC}"
    fi
}

# Update system
log "${YELLOW}Updating system...${NC}"
if sudo pacman -Syu --noconfirm &>> "$LOG_FILE"; then
    log "${GREEN}System updated successfully.${NC}"
else
    log "${RED}Failed to update system.${NC}"
    exit 1
fi

# Install Zsh and necessary packages
log "${YELLOW}Installing Zsh, Git, and dependencies...${NC}"
if sudo pacman -S --noconfirm zsh git &>> "$LOG_FILE"; then
    log "${GREEN}Zsh and required packages installed successfully.${NC}"
else
    log "${RED}Failed to install Zsh and required packages.${NC}"
    exit 1
fi

# Install zsh-autosuggestions
log "${YELLOW}Installing zsh-autosuggestions...${NC}"
git clone https://github.com/zsh-users/zsh-autosuggestions.git "${HOME}/.zsh/zsh-autosuggestions" &>> "$LOG_FILE"

# Install zsh-syntax-highlighting
log "${YELLOW}Installing zsh-syntax-highlighting...${NC}"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.zsh/zsh-syntax-highlighting" &>> "$LOG_FILE"

# Install powerlevel10k
log "${YELLOW}Installing Powerlevel10k...${NC}"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${HOME}/.zsh/powerlevel10k" &>> "$LOG_FILE"

# Configure Zsh
log "${YELLOW}Configuring Zsh...${NC}"
if [ ! -f "${HOME}/.zshrc" ]; then
    touch "${HOME}/.zshrc"
fi

# Add lines to .zshrc
add_line 'source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh'
add_line 'source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
add_line 'source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme'
add_line 'HISTSIZE=10000'  # History size
add_line 'SAVEHIST=10000'  # Commands to save in history
add_line 'HISTFILE=~/.zsh_history'  # History file
add_line 'setopt APPEND_HISTORY'  # Append to history file
add_line 'setopt INC_APPEND_HISTORY'  # Incremental append
add_line 'setopt SHARE_HISTORY'  # Share history across sessions
add_line "alias ls='ls --color=auto'"  # Color

# Change the default shell to Zsh
echo "Changing default shell to Zsh..."
chsh -s "$(which zsh)"
if [ $? -eq 0 ]; then
    echo "Default shell changed to Zsh successfully."
else
    echo "Failed to change default shell to Zsh."
fi
