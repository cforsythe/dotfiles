#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "========================================="
echo "  Installing dotfiles"
echo "========================================="
echo ""

create_backup() {
    local file=$1
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        if [ ! -d "$BACKUP_DIR" ]; then
            mkdir -p "$BACKUP_DIR"
            print_info "Created backup directory: $BACKUP_DIR"
        fi
        mv "$file" "$BACKUP_DIR/"
        print_warning "Backed up: $file"
    fi
}

create_symlink() {
    local source=$1
    local target=$2

    if [ -e "$source" ]; then
        create_backup "$target"
        ln -sf "$source" "$target"
        print_success "Linked: $target"
    fi
}

# Install configs
create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"
[ -d "$DOTFILES_DIR/vim/vim" ] && create_symlink "$DOTFILES_DIR/vim/vim" "$HOME/.vim"
create_symlink "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
create_symlink "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/git/gitignore" "$HOME/.gitignore"
[ -d "$DOTFILES_DIR/config/claude" ] && create_symlink "$DOTFILES_DIR/config/claude" "$HOME/.claude"

echo ""
print_success "Dotfiles installed!"
[ -d "$BACKUP_DIR" ] && print_info "Backups: $BACKUP_DIR"
