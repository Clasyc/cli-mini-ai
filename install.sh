#!/usr/bin/env bash

set -e

# Define installation directory
INSTALL_DIR="$HOME/.local/bin/cli-mini-ai"
MAIN_SCRIPT="$INSTALL_DIR/cli-mini-ai"
CONFIG_SCRIPT="$INSTALL_DIR/configure.sh"

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
echo "Created directory: $INSTALL_DIR"

# Download scripts
echo "Downloading scripts..."
curl -o "$INSTALL_DIR/command.sh" https://raw.githubusercontent.com/Clasyc/cli-mini-ai/main/src/command.sh
echo "Downloaded: $INSTALL_DIR/command.sh"
curl -o "$INSTALL_DIR/alias.sh" https://raw.githubusercontent.com/Clasyc/cli-mini-ai/main/src/alias.sh
echo "Downloaded: $INSTALL_DIR/alias.sh"
curl -o "$CONFIG_SCRIPT" https://raw.githubusercontent.com/Clasyc/cli-mini-ai/main/src/configure.sh
echo "Downloaded: $CONFIG_SCRIPT"

# Create main script
cat > "$MAIN_SCRIPT" << EOL
#!/usr/bin/env bash
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
"\$SCRIPT_DIR/command.sh" "\$@"
EOL
echo "Created main script: $MAIN_SCRIPT"

# Make scripts executable
chmod +x "$INSTALL_DIR/command.sh" "$INSTALL_DIR/alias.sh" "$MAIN_SCRIPT" "$CONFIG_SCRIPT"
echo "Made scripts executable"

# Add installation directory to PATH if not already present
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "Adding ~/.local/bin to PATH..."
    echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$HOME/.bashrc"
    echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$HOME/.zshrc"
    echo "Updated: $HOME/.bashrc and $HOME/.zshrc"
    echo "Please restart your shell or run 'source ~/.bashrc' or 'source ~/.zshrc' to update your PATH."
fi

# Create alias
echo "Creating 'ai' alias..."
echo "alias ai='$INSTALL_DIR/alias.sh'" >> "$HOME/.bashrc"
echo "alias ai='$INSTALL_DIR/alias.sh'" >> "$HOME/.zshrc"
echo "Updated: $HOME/.bashrc and $HOME/.zshrc with 'ai' alias"

echo "Installation complete!"
echo "Now running configuration script..."
bash "$CONFIG_SCRIPT"
echo "Setup complete. Please restart your terminal or source your shell configuration file."
echo "You can then use the 'cli-mini-ai' command for direct access, or the 'ai' alias for the interactive interface."