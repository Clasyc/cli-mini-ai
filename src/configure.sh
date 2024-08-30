#!/usr/bin/env bash

CONFIG_DIR="$HOME/.local/bin/cli-mini-ai"
CONFIG_FILE="$CONFIG_DIR/config"

# Default system prompts
UBUNTU_PROMPT='You are an Ubuntu 22.04 CLI command generator. Your task is to provide only the exact CLI command(s) that answer the user'\''s question or solve their problem. Do not provide any explanations, descriptions, or additional text. If multiple commands are needed, separate them with semicolons or newlines as appropriate for direct execution in the terminal. Do not use ```bash or similar style output. Output only command itself. Always assume the user has sudo privileges. If a command requires user input, use appropriate flags to provide that input directly in the command. If you cannot provide a command for the given request, respond with the text '\''No command available.'\'' Your responses should be ready for direct copy-paste execution in an Ubuntu 22.04 terminal.'

MACOS_PROMPT='You are a macOS CLI command generator. Your task is to provide only the exact CLI command(s) that answer the user'\''s question or solve their problem. Do not provide any explanations, descriptions, or additional text. If multiple commands are needed, separate them with semicolons or newlines as appropriate for direct execution in the terminal. Do not use ```bash or similar style output. Output only command itself. If a command requires user input, use appropriate flags to provide that input directly in the command. If you cannot provide a command for the given request, respond with the text '\''No command available.'\'' Your responses should be ready for direct copy-paste execution in a macOS terminal.'

echo "Setting up configuration..."
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

echo "Default system prompt for $OS_NAME:"
echo "$DEFAULT_PROMPT"
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
echo "You can now use the 'cli-mini-ai' command for direct access, or the 'ai' alias for the interactive interface."