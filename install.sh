#!/usr/bin/env bash

set -e

# Define installation directory
INSTALL_DIR="$HOME/.local/bin/cli-mini-ai"
MAIN_SCRIPT="$INSTALL_DIR/cli-mini-ai"
CONFIG_FILE="$INSTALL_DIR/config"

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
curl -sSLo "$INSTALL_DIR/req.sh" https://raw.githubusercontent.com/Clasyc/cli-mini-ai/main/src/req.sh
echo "Downloaded: $INSTALL_DIR/req.sh"
curl -sSLo "$INSTALL_DIR/alias.sh" https://raw.githubusercontent.com/Clasyc/cli-mini-ai/main/src/alias.sh
echo "Downloaded: $INSTALL_DIR/alias.sh"

# Create main script
cat > "$MAIN_SCRIPT" << EOL
#!/usr/bin/env bash
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
"\$SCRIPT_DIR/req.sh" "\$@"
EOL
echo "Created main script: $MAIN_SCRIPT"

# Make scripts executable
chmod +x "$INSTALL_DIR/req.sh" "$INSTALL_DIR/alias.sh" "$MAIN_SCRIPT"
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

# Configuration
echo "Setting up configuration..."

# Default system prompts
UBUNTU_PROMPT='You are an Ubuntu 22.04 CLI command generator. Your task is to provide only the exact CLI command(s) that answer the user'\''s question or solve their problem. Do not provide any explanations, descriptions, or additional text. If multiple commands are needed, separate them with semicolons or newlines as appropriate for direct execution in the terminal. Do not use ```bash or similar style output. Output only command itself. Always assume the user has sudo privileges. If a command requires user input, use appropriate flags to provide that input directly in the command. If you cannot provide a command for the given request, respond with the text '\''No command available.'\'' Your responses should be ready for direct copy-paste execution in an Ubuntu 22.04 terminal.'

MACOS_PROMPT='You are a macOS CLI command generator. Your task is to provide only the exact CLI command(s) that answer the user'\''s question or solve their problem. Do not provide any explanations, descriptions, or additional text. If multiple commands are needed, separate them with semicolons or newlines as appropriate for direct execution in the terminal. Do not use ```bash or similar style output. Output only command itself. If a command requires user input, use appropriate flags to provide that input directly in the command. If you cannot provide a command for the given request, respond with the text '\''No command available.'\'' Your responses should be ready for direct copy-paste execution in a macOS terminal.'

while true; do
    read -p "Enter your OpenAI API Key: " API_KEY
    if [ -n "$API_KEY" ]; then
        break
    else
        echo "API Key cannot be empty. Please try again."
    fi
done

# Determine the default prompt based on the OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    DEFAULT_PROMPT="$MACOS_PROMPT"
    OS_NAME="macOS"
else
    DEFAULT_PROMPT="$UBUNTU_PROMPT"
    OS_NAME="Ubuntu"
fi

# Get the terminal height
terminal_height=$(tput lines)

echo -e "\e[0;90mDefault system prompt for $OS_NAME:"
echo "$DEFAULT_PROMPT"
echo -e "\e[0m"
echo ""

read -p "Do you want to use this default prompt? (Y/n): " use_default

if [[ $use_default =~ ^[Nn]$ ]]; then
    echo "Please enter your custom system prompt:"
    read -e SYSTEM_PROMPT
else
    SYSTEM_PROMPT="$DEFAULT_PROMPT"
fi

echo "API_KEY='${API_KEY//\'/\'\\\'\'}'" > "$CONFIG_FILE"
echo "SYSTEM_PROMPT='${SYSTEM_PROMPT//\'/\'\\\'\'}'" >> "$CONFIG_FILE"

echo "Configuration saved to $CONFIG_FILE"

echo "Installation complete!"
echo "You can now use the 'cli-mini-ai' command for direct access, or the 'ai' alias for the interactive interface."
echo "If the 'ai' alias doesn't work immediately, please restart your terminal or manually source your shell configuration file."