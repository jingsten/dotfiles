#!/bin/bash

# Dotfiles Setup Script for macOS and Linux
# This script installs and configures development tools and shell enhancements

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    log_info "Detected OS: $OS"
}

# Install Homebrew/Linuxbrew
install_homebrew() {
    log_info "Installing Homebrew/Linuxbrew..."

    if command -v brew &> /dev/null; then
        log_success "Homebrew is already installed"
        return 0
    fi

    if [[ "$OS" == "macos" ]]; then
        log_info "Installing Homebrew for macOS..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    elif [[ "$OS" == "linux" ]]; then
        log_info "Installing Linuxbrew for Linux..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Wait for installation to complete
        sleep 2

        # Detect Homebrew installation path
        local brew_paths=(
            "/home/linuxbrew/.linuxbrew/bin/brew"
            "$HOME/.linuxbrew/bin/brew"
            "/opt/homebrew/bin/brew"
        )

        local brew_path=""
        for path in "${brew_paths[@]}"; do
            if [[ -x "$path" ]]; then
                brew_path="$path"
                break
            fi
        done

        if [[ -n "$brew_path" ]]; then
            log_info "Found Homebrew at: $brew_path"

            # Get the correct shellenv output
            local brew_shellenv="$($brew_path shellenv)"

            # Add to shell configuration files with proper formatting
            for rc_file in ~/.bashrc ~/.zshrc; do
                if [[ -f "$rc_file" ]]; then
                    # Check if Homebrew config already exists
                    if ! grep -q "# Homebrew" "$rc_file"; then
                        echo "" >> "$rc_file"
                        echo "# Homebrew" >> "$rc_file"
                        echo "$brew_shellenv" >> "$rc_file"
                        log_info "Added Homebrew configuration to $(basename "$rc_file")"
                    fi
                fi
            done

            # Apply to current session
            eval "$brew_shellenv"

            # Verify brew is now accessible
            if command -v brew &> /dev/null; then
                log_success "Linuxbrew PATH configured successfully"
            else
                log_warning "Homebrew installed but not yet in PATH. Please restart your shell."
            fi
        else
            log_warning "Could not find Homebrew installation after install attempt"
            log_info "You may need to manually add Homebrew to your PATH:"
            log_info "  echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> ~/.bashrc"
            log_info "  echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> ~/.zshrc"
        fi
    fi

    log_success "Homebrew/Linuxbrew installed successfully"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh is already installed"
        return 0
    fi

    # Install zsh if not present
    if ! command -v zsh &> /dev/null; then
        log_info "Installing zsh..."
        if [[ "$OS" == "macos" ]]; then
            brew install zsh
        elif [[ "$OS" == "linux" ]]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y zsh
            elif command -v yum &> /dev/null; then
                sudo yum install -y zsh
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm zsh
            else
                brew install zsh
            fi
        fi
    fi

    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    log_success "Oh My Zsh installed successfully"
}

# Install zsh-syntax-highlighting
install_zsh_syntax_highlighting() {
    log_info "Installing zsh-syntax-highlighting..."

    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

    if [[ -d "$plugin_dir" ]]; then
        log_success "zsh-syntax-highlighting is already installed"
        return 0
    fi

    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugin_dir"
    log_success "zsh-syntax-highlighting installed successfully"
}

# Install zsh-autosuggestions
install_zsh_autosuggestions() {
    log_info "Installing zsh-autosuggestions..."

    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

    if [[ -d "$plugin_dir" ]]; then
        log_success "zsh-autosuggestions is already installed"
        return 0
    fi

    git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir"
    log_success "zsh-autosuggestions installed successfully"
}

# Configure zsh plugins
configure_zsh_plugins() {
    log_info "Configuring zsh plugins..."

    local zshrc="$HOME/.zshrc"

    # Backup original .zshrc
    if [[ -f "$zshrc" ]]; then
        cp "$zshrc" "$zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up existing .zshrc"
    fi

    # Update plugins in .zshrc
    if grep -q "^plugins=" "$zshrc" 2>/dev/null; then
        sed -i.bak 's/^plugins=.*/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' "$zshrc"
    else
        echo "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)" >> "$zshrc"
    fi

    log_success "zsh plugins configured"
}

# Install Starship prompt
install_starship() {
    log_info "Installing Starship prompt..."

    if command -v starship &> /dev/null; then
        log_success "Starship is already installed"
    else
        yes | curl -sS https://starship.rs/install.sh | sh
        log_success "Starship installed successfully"
    fi

    # Configure Starship in .zshrc
    local zshrc="$HOME/.zshrc"
    if ! grep -q "starship init zsh" "$zshrc" 2>/dev/null; then
        echo 'eval "$(starship init zsh)"' >> "$zshrc"
        log_info "Added Starship initialization to .zshrc"
    fi

    # Install Catppuccin Powerline theme
    log_info "Installing Catppuccin Powerline theme for Starship..."
    mkdir -p "$HOME/.config"

    # Check if starship command is available in current session
    if command -v starship &> /dev/null; then
        starship preset catppuccin-powerline -o ~/.config/starship.toml
    else
        # If starship is not in PATH yet, use the installed location
        if [[ -f "/usr/local/bin/starship" ]]; then
            "/usr/local/bin/starship" preset catppuccin-powerline -o ~/.config/starship.toml
        else
            log_warning "Starship not found in PATH. You may need to restart your shell and run: starship preset catppuccin-powerline -o ~/.config/starship.toml"
        fi
    fi

    log_success "Starship Catppuccin Powerline theme configured"
}

# Install UV for Python package management
install_uv() {
    log_info "Installing UV for Python package management..."

    if command -v uv &> /dev/null; then
        log_success "UV is already installed"
        return 0
    fi

    curl -LsSf https://astral.sh/uv/install.sh | sh

    # Add UV environment sourcing to shell configs
    local uv_source='source $HOME/.local/bin/env'

    for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [[ -f "$rc_file" ]] && ! grep -q 'source $HOME/.local/bin/env' "$rc_file"; then
            echo "$uv_source" >> "$rc_file"
        fi
    done

    log_success "UV installed successfully"
}

# Change default shell to zsh
change_shell_to_zsh() {
    log_info "Setting zsh as default shell..."

    if [[ "$SHELL" == *"zsh"* ]]; then
        log_success "zsh is already the default shell"
        return 0
    fi

    local zsh_path

    if [[ "$OS" == "linux" ]]; then
        # Linux-specific: Try multiple methods to find zsh
        local zsh_candidates=(
            "$(command -v zsh 2>/dev/null)"
            "$(which zsh 2>/dev/null)"
            "/usr/bin/zsh"
            "/bin/zsh"
            "/usr/local/bin/zsh"
            "/home/linuxbrew/.linuxbrew/bin/zsh"
        )

        for candidate in "${zsh_candidates[@]}"; do
            if [[ -n "$candidate" && -x "$candidate" ]]; then
                zsh_path="$candidate"
                break
            fi
        done

        if [[ -z "$zsh_path" ]]; then
            log_error "zsh not found in any expected location"
            log_info "Please ensure zsh is installed and try running the script again"
            return 1
        fi

        log_info "Found zsh at: $zsh_path"

        # Add zsh to /etc/shells if not present and /etc/shells exists
        if [[ -f /etc/shells ]]; then
            if ! grep -Fxq "$zsh_path" /etc/shells 2>/dev/null; then
                log_info "Adding $zsh_path to /etc/shells"
                if echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null 2>&1; then
                    log_success "Added zsh to /etc/shells"
                else
                    log_warning "Could not add zsh to /etc/shells (may need manual intervention)"
                fi
            else
                log_info "zsh already present in /etc/shells"
            fi
        else
            log_warning "/etc/shells not found, skipping shell validation"
        fi

        # Change default shell with better error handling for Linux
        log_info "Changing default shell to zsh..."
        if chsh -s "$zsh_path" 2>/dev/null; then
            log_success "Default shell changed to zsh"
            log_warning "Please restart your terminal or run 'exec zsh' to use the new shell"
        else
            # Try alternative method for Linux systems
            log_warning "chsh command failed, trying alternative method..."
            if command -v usermod &> /dev/null; then
                if sudo usermod -s "$zsh_path" "$USER" 2>/dev/null; then
                    log_success "Default shell changed to zsh using usermod"
                    log_warning "Please restart your terminal or run 'exec zsh' to use the new shell"
                else
                    log_error "Failed to change default shell"
                    log_info "You can manually change it by running: chsh -s $zsh_path"
                fi
            else
                log_error "Failed to change default shell automatically"
                log_info "Please manually run: chsh -s $zsh_path"
                log_info "Or contact your system administrator if you don't have permission"
            fi
        fi

    else
        # macOS: Use simple method (which works fine)
        zsh_path=$(which zsh)

        if [[ -n "$zsh_path" ]]; then
            # Add zsh to /etc/shells if not present
            if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
                echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
            fi

            # Change default shell
            chsh -s "$zsh_path"
            log_success "Default shell changed to zsh"
            log_warning "Please restart your terminal or run 'exec zsh' to use the new shell"
        else
            log_error "zsh not found in PATH"
        fi
    fi
}

adjust_zshrc() {
    log_info "Adjusting .zshrc..."
    echo "alias c='clear&&clear'">> "$HOME/.zshrc"
    source "$HOME/.zshrc"
}

setup_sudo() {
    log_info "Setup passwordless sudo for script..."
    # Grant temporary full sudo access without a password
    echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/setup_temp
}

reset_sudo() {
    log_info "Reset passwordless sudo access..."
    # Clean up and remove the elevated privilege
    sudo rm /etc/sudoers.d/setup_temp
}


# Main installation function
main() {
    log_info "Starting dotfiles setup..."
    setup_sudo
    detect_os
    install_homebrew
    install_oh_my_zsh
    install_zsh_syntax_highlighting
    install_zsh_autosuggestions
    configure_zsh_plugins
    install_starship
    install_uv
    change_shell_to_zsh
    adjust_zshrc
    reset_sudo

    log_success "Dotfiles setup completed successfully!"
    log_info "Please restart your terminal or run 'exec zsh' to apply all changes"
    log_info "You may also want to install a Nerd Font for better Starship theme support"
}

# Run main function
main "$@"
