#!/usr/bin/env bash

echo -e "\n\033[1m--- AI Command Helper ---\033[0m\n"
read -p "Q: " prompt
echo -e "\033[33m------------------------------------\033[0m"
response=$(ai-command-helper "$prompt")
echo -e "$response" | sed $'s/^/\033[32m/' | sed $'s/$/\033[0m/'

# Copy to clipboard based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -n "$response" | tr -d '\n' | pbcopy
elif command -v xclip >/dev/null 2>&1; then
    echo -n "$response" | tr -d '\n' | xclip -selection clipboard
else
    echo "Warning: Clipboard functionality not available. Please install xclip."
fi

echo -e "\033[33m------------------------------------\033[0m"
echo -e "\033[3mResponse copied to clipboard (without newline).\033[0m\n"
exit 0