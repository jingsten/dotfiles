# Dotfiles Setup Script

This repository contains an automated setup script for configuring a development environment on macOS and Linux systems.

## Features

The setup script installs and configures:

- **Homebrew/Linuxbrew**: Package manager for macOS/Linux
- **Oh My Zsh**: Framework for managing zsh configuration
- **zsh-syntax-highlighting**: Syntax highlighting for zsh commands
- **zsh-autosuggestions**: Fish-like autosuggestions for zsh
- **Starship**: Cross-shell prompt with Catppuccin Powerline theme
- **UV**: Fast Python package installer and resolver

## Quick Start

1. Clone this repository or download the setup script:
   ```bash
   git clone https://github.com/jingsten/dotfiles.git
   chmod +x setup.sh
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

3. Restart your terminal or run:
   ```bash
   exec zsh
   ```

## What the Script Does

### 1. OS Detection
- Automatically detects macOS or Linux
- Adapts installation commands accordingly

### 2. Homebrew Installation
- Installs Homebrew on macOS
- Installs Linuxbrew on Linux
- Configures PATH for Linux systems

### 3. Zsh Setup
- Installs zsh if not present
- Installs Oh My Zsh framework
- Sets zsh as default shell

### 4. Zsh Plugins
- Installs zsh-syntax-highlighting for command syntax highlighting
- Installs zsh-autosuggestions for command completion suggestions
- Automatically configures plugins in `.zshrc`

### 5. Starship Prompt
- Installs Starship cross-shell prompt
- Configures Catppuccin Powerline theme
- Adds initialization to shell configuration

### 6. Python Tools
- Installs UV for fast Python package management
- Configures PATH for UV binary

## Manual Steps (Optional)

After running the script, you may want to:

1. **Install a Nerd Font** for better icon support in Starship:
   - Download from [Nerd Fonts](https://www.nerdfonts.com/)
   - Popular choices: FiraCode Nerd Font, JetBrains Mono Nerd Font

2. **Customize Starship theme**:
   ```bash
   starship config
   ```

3. **Add additional zsh plugins** by editing `~/.zshrc`:
   ```bash
   plugins=(git zsh-syntax-highlighting zsh-autosuggestions docker kubectl)
   ```

## Troubleshooting

### Permission Issues
If you encounter permission issues, ensure the script is executable:
```bash
chmod +x setup.sh
```

### Path Issues
If commands aren't found after installation, restart your terminal or source your shell configuration:
```bash
source ~/.zshrc
```

### Starship Theme Not Applied
If the Starship theme doesn't appear correctly:
1. Ensure you have a Nerd Font installed and configured in your terminal
2. Restart your terminal application
3. Check that Starship is initialized in your `.zshrc`

## Supported Systems

- **macOS**: 10.15+ (Catalina and later)
- **Linux**: Ubuntu, Debian, CentOS, RHEL, Arch Linux, and other major distributions

## Safety Features

- Creates backups of existing configuration files
- Uses safe installation methods with error checking
- Provides colored output for easy monitoring
- Exits on errors to prevent partial installations

## License

This project is open source and available under the [MIT License](LICENSE).