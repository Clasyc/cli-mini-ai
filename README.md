# cli-mini-ai

Look, I was just tired of constantly switching between my terminal and browser to ask ChatGPT how to do stuff in the command line. It's a pain, right? So I made this dead simple CLI tool that lets you ask AI for help right in your terminal. No frills, just straight-up command generation and quick answers.

![demo.gif](demo.gif)

## Features

- Generate CLI commands for Ubuntu and macOS
- Clipboard integration for convenient command copying

## Installation

Install cli-mini-ai with a single command:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Clasyc/cli-mini-ai/main/install.sh)
```

This script will:
1. Install necessary dependencies
2. Set up the cli-mini-ai scripts
3. Create configuration files
4. Add the tool to your PATH
5. Create an 'ai' alias for easy access

## Usage

After installation, simply use the `ai` command in your terminal:

```
ai
```

This will:
1. Prompt you to enter your query
2. Generate an AI-powered response or command based on your input
3. Display the response in the terminal
4. Automatically copy the response to your clipboard for easy use

## Configuration

The installation script will guide you through setting up your OpenAI API key and choosing a system prompt. If you need to modify these later, edit the config file at:

```
~/.local/bin/cli-mini-ai/config
```

## Troubleshooting

If the 'ai' alias doesn't work immediately after installation, try:
1. Restarting your terminal
2. Manually sourcing your shell configuration file:
   ```
   source ~/.bashrc  # for Bash
   source ~/.zshrc   # for Zsh
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT License](LICENSE)