#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Configuration - Update this with your dotfiles repo URL
DOTFILES_REPO=""  # e.g., "git@github.com:yourusername/dotfiles.git"

# Auto-detect if we're already in a dotfiles repo
if [ -f "$(dirname "$0")/install.sh" ] && [ -d "$(dirname "$0")/.git" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    print_info "Detected dotfiles repo at: $SCRIPT_DIR"
    DOTFILES_REPO="local:$SCRIPT_DIR"
fi

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_warning "This script should not be run as root. Please run as your regular user."
    exit 1
fi

echo "========================================="
echo "  DevBox Setup Script"
echo "========================================="
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    print_error "Cannot detect OS"
    exit 1
fi

print_info "Detected OS: $OS $VER"

# Set package manager based on OS
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    PKG_MANAGER="apt"
    PKG_UPDATE="sudo apt update"
    PKG_INSTALL="sudo apt install -y"
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Amazon Linux"* ]]; then
    PKG_MANAGER="yum"
    PKG_UPDATE="sudo yum update -y"
    PKG_INSTALL="sudo yum install -y"
elif [[ "$OS" == *"Fedora"* ]]; then
    PKG_MANAGER="dnf"
    PKG_UPDATE="sudo dnf update -y"
    PKG_INSTALL="sudo dnf install -y"
else
    print_error "Unsupported OS: $OS"
    exit 1
fi

# Update package lists
print_info "Updating package lists..."
$PKG_UPDATE
print_success "Package lists updated"

# Install essential packages
print_info "Installing essential packages..."

PACKAGES=(
    "zsh"
    "git"
    "curl"
    "wget"
    "tmux"
    "vim"
    "python3"
    "python3-pip"
    "jq"
    "htop"
    "tree"
)

# Add OS-specific packages
if [[ "$PKG_MANAGER" == "apt" ]]; then
    PACKAGES+=("build-essential" "ripgrep" "fd-find")
elif [[ "$PKG_MANAGER" == "yum" ]] || [[ "$PKG_MANAGER" == "dnf" ]]; then
    PACKAGES+=("gcc" "gcc-c++" "make" "kernel-devel")
fi

for pkg in "${PACKAGES[@]}"; do
    if [ -n "$pkg" ]; then
        print_info "Installing $pkg..."
        $PKG_INSTALL "$pkg" 2>/dev/null || print_warning "Failed to install $pkg (may already be installed)"
    fi
done

print_success "Essential packages installed"

# Install Neovim
print_info "Installing Neovim..."
if command -v nvim &> /dev/null; then
    print_warning "Neovim already installed"
else
    $PKG_INSTALL neovim 2>/dev/null || print_warning "Could not install neovim via package manager"
    print_success "Neovim installed"
fi

# Install vim-plug for Neovim
print_info "Installing vim-plug for Neovim..."
if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    print_success "vim-plug installed"
else
    print_warning "vim-plug already installed"
fi

# Install vim-plug for Vim
print_info "Installing vim-plug for Vim..."
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    print_success "vim-plug for Vim installed"
else
    print_warning "vim-plug for Vim already installed"
fi

# Install Oh My Zsh
print_info "Installing Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_warning "Oh My Zsh already installed"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
fi

# Install Zsh plugins
print_info "Installing Zsh plugins..."

# zsh-autosuggestions
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    print_warning "zsh-autosuggestions already installed"
else
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    print_success "zsh-autosuggestions installed"
fi

# you-should-use
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use" ]; then
    print_warning "you-should-use already installed"
else
    git clone https://github.com/MichaelAquilina/zsh-you-should-use \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use"
    print_success "you-should-use installed"
fi

# Install NVM (Node Version Manager)
print_info "Installing NVM..."
if [ -d "$HOME/.nvm" ]; then
    print_warning "NVM already installed"
else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    print_success "NVM installed"

    # Install latest LTS Node.js
    print_info "Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
    print_success "Node.js LTS installed"
fi

# Install Claude Code CLI
print_info "Installing Claude Code CLI..."
if command -v claude &> /dev/null; then
    print_warning "Claude Code CLI already installed"
else
    # Make sure npm is available
    if command -v npm &> /dev/null; then
        npm install -g @anthropic-ai/claude-code
        print_success "Claude Code CLI installed"
    else
        print_warning "npm not found, skipping Claude Code CLI installation"
    fi
fi

# Install tmux plugin manager (TPM)
print_info "Installing tmux plugin manager..."
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    print_warning "TPM already installed"
else
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    print_success "TPM installed"
fi

# Install tmux plugins automatically
if [ -f "$HOME/.tmux.conf" ] && [ -d "$HOME/.tmux/plugins/tpm" ]; then
    print_info "Installing tmux plugins..."
    "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh" 2>/dev/null || print_warning "Could not install tmux plugins. Press 'Ctrl+a + I' in tmux to install manually"
    print_success "Tmux plugins installed"
fi

# Clone and install dotfiles
if [ -n "$DOTFILES_REPO" ]; then
    if [[ "$DOTFILES_REPO" == local:* ]]; then
        # We're already in the dotfiles repo
        DOTFILES_DIR="${DOTFILES_REPO#local:}"
        print_info "Using local dotfiles from: $DOTFILES_DIR"

        if [ -f "$DOTFILES_DIR/install.sh" ]; then
            cd "$DOTFILES_DIR"
            ./install.sh
            print_success "Dotfiles installed"
        else
            print_warning "install.sh not found in dotfiles directory"
        fi
    else
        # Clone from remote
        print_info "Cloning dotfiles repository..."
        if [ -d "$HOME/dotfiles" ]; then
            print_warning "Dotfiles directory already exists, skipping clone"
        else
            git clone "$DOTFILES_REPO" "$HOME/dotfiles"
            print_success "Dotfiles cloned"
        fi

        print_info "Installing dotfiles..."
        if [ -f "$HOME/dotfiles/install.sh" ]; then
            cd "$HOME/dotfiles"
            ./install.sh
            print_success "Dotfiles installed"
        else
            print_warning "install.sh not found in dotfiles repo"
        fi
    fi
else
    print_warning "DOTFILES_REPO not set, skipping dotfiles installation"
    print_info "To use dotfiles:"
    echo "  1. Update DOTFILES_REPO variable at the top of this script"
    echo "  2. Or manually clone: git clone <your-repo> ~/dotfiles"
    echo "  3. Then run: ~/dotfiles/install.sh"
fi

# Change default shell to Zsh
print_info "Checking default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
    print_info "Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
    print_success "Default shell changed to Zsh (will take effect on next login)"
else
    print_success "Zsh is already the default shell"
fi

# Install Neovim plugins
if [ -f "$HOME/.config/nvim/init.vim" ] && command -v nvim &> /dev/null; then
    print_info "Installing Neovim plugins..."
    nvim +PlugInstall +qall 2>/dev/null || print_warning "Could not install nvim plugins automatically. Run :PlugInstall in nvim"
    print_success "Neovim plugins installed"
fi

# Install Vim plugins (if .vimrc exists)
if [ -f "$HOME/.vimrc" ] && command -v vim &> /dev/null; then
    if grep -q "plug#begin" "$HOME/.vimrc"; then
        print_info "Installing Vim plugins..."
        vim +PlugInstall +qall 2>/dev/null || print_warning "Could not install vim plugins automatically. Run :PlugInstall in vim"
        print_success "Vim plugins installed"
    fi
fi

echo ""
echo "========================================="
echo "  Installation Complete!"
echo "========================================="
echo ""
print_info "Next steps:"
echo "  1. Log out and log back in (or run: exec zsh)"
echo "  2. Configure git with your name and email (if not in dotfiles):"
echo "     git config --global user.name \"Your Name\""
echo "     git config --global user.email \"your.email@example.com\""
echo "  3. Edit ~/.zshrc.local and ~/.gitconfig.local for local configs"
echo ""
print_success "Enjoy your new devbox!"
