#!/usr/bin/env bash

# Configuration
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/command"
CONFIG_FILE="$CONFIG_DIR/config"

# Default system prompts
UBUNTU_PROMPT='You are an Ubuntu 22.04 CLI command generator. Your task is to provide only the exact CLI command(s) that answer the user'\''s question or solve their problem. Do not provide any explanations, descriptions, or additional text. If multiple commands are needed, separate them with semicolons or newlines as appropriate for direct execution in the terminal. Do not use ```bash or similar style output. Output only command itself. Always assume the user has sudo privileges. If a command requires user input, use appropriate flags to provide that input directly in the command. If you cannot provide a command for the given request, respond with the text '\''No command available.'\'' Your responses should be ready for direct copy-paste execution in an Ubuntu 22.04 terminal.'

MACOS_PROMPT='You are a macOS CLI command generator. Your task is to provide only the exact CLI command(s) that answer the user'\''s question or solve their problem. Do not provide any explanations, descriptions, or additional text. If multiple commands are needed, separate them with semicolons or newlines as appropriate for direct execution in the terminal. Do not use ```bash or similar style output. Output only command itself. If a command requires user input, use appropriate flags to provide that input directly in the command. If you cannot provide a command for the given request, respond with the text '\''No command available.'\'' Your responses should be ready for direct copy-paste execution in a macOS terminal.'

# Function to load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo "Config file not found. Please run the script with --config option to set it up."
        exit 1
    fi
}

# Function to set up configuration
setup_config() {
    echo "Setting up configuration..."
    read -p "Enter your OpenAI API Key: " API_KEY

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

    mkdir -p "$CONFIG_DIR"
    echo "API_KEY='${API_KEY//\'/\'\\\'\'}'" > "$CONFIG_FILE"
    echo "SYSTEM_PROMPT='${SYSTEM_PROMPT//\'/\'\\\'\'}'" >> "$CONFIG_FILE"

    echo "Configuration saved to $CONFIG_FILE"
}

# Function to make API request
make_request() {
    local user_prompt="$1"

    response=$(curl -s https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d '{
        "model": "gpt-4",
        "messages": [
            {"role": "system", "content": "'"${SYSTEM_PROMPT//\"/\\\"}"'"},
            {"role": "user", "content": "'"${user_prompt//\"/\\\"}"'"}
        ]
    }')

    echo "$response" | jq -r '.choices[0].message.content'
}

# Main script logic
if [ "$1" == "--config" ]; then
    setup_config
    exit 0
fi

load_config

if [ $# -eq 0 ]; then
    echo "Usage: $0 <prompt>"
    echo "Or use $0 --config to set up the configuration"
    exit 1
fi

make_request "$*"