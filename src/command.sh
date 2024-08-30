#!/usr/bin/env bash

# Configuration
CONFIG_DIR="$HOME/.local/bin/cli-mini-ai"
CONFIG_FILE="$CONFIG_DIR/config"

# Function to load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo "Config file not found. Please run the installation script again."
        exit 1
    fi
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
load_config

if [ $# -eq 0 ]; then
    echo "Usage: $0 <prompt>"
    exit 1
fi

make_request "$*"