#!/usr/bin/env bash

set -e

# Define installation directory
INSTALL_DIR="$HOME/.local/bin"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages based on the OS
install_package() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command_exists brew; then
            echo "Homebrew is required to install dependencies. Please install Homebrew first."
            exit 1
        fi
        brew install "$1"
    elif command_exists apt-get; then
        sudo apt-get update && sudo apt-get install -y "$1"
    elif command_exists yum; then
        sudo yum install -y "$1"
    else
        echo "Unsupported package manager. Please install $1 manually."
        exit 1
    fi
}

# Install dependencies
echo "Checking and installing dependencies..."
if ! command_exists jq; then
    install_package jq
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS already has pbcopy
    :
elif ! command_exists xclip; then
    install_package xclip
fi

# Create installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Download scripts
echo "Downloading scripts..."
curl -o "$INSTALL_DIR/command" https://raw.githubusercontent.com/yourusername/command/main/src/command.sh
curl -o "$INSTALL_DIR/ai" https://raw.githubusercontent.com/yourusername/command/main/src/alias.sh

# Make scripts executable
chmod +x "$INSTALL_DIR/command" "$INSTALL_DIR/ai"

# Add installation directory to PATH if not already present
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Adding installation directory to PATH..."
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.bashrc"
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.zshrc"
    echo "Please restart your shell or run 'source ~/.bashrc' or 'source ~/.zshrc' to update your PATH."
fi

echo "Running initial configuration..."
echo "You will be asked to enter your OpenAI API Key and choose a system prompt."
"$INSTALL_DIR/command" --config

echo "Installation complete! You can now use the 'ai' command."