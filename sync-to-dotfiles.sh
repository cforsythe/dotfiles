#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

print_error() {
    echo -e "${RED}✗${NC} $1"
}

echo "========================================="
echo "  Sync dotfiles to existing git repo"
echo "========================================="
echo ""

# Check if dotfiles directory is provided as argument
if [ -n "$1" ]; then
    DOTFILES_DIR="$1"
else
    # Prompt for dotfiles directory location
    echo "Where is your existing dotfiles git repository?"
    echo "Examples:"
    echo "  - ~/dotfiles"
    echo "  - ~/github/dotfiles"
    echo "  - Or provide a git URL to clone it"
    echo ""
    read -p "Enter path or URL: " DOTFILES_DIR
fi

# Check if it's a URL (clone it)
if [[ "$DOTFILES_DIR" =~ ^(https?|git)://.*\.git$ ]] || [[ "$DOTFILES_DIR" =~ ^git@.*\.git$ ]]; then
    print_info "Cloning repository..."
    CLONE_DIR="$HOME/dotfiles"

    if [ -d "$CLONE_DIR" ]; then
        print_error "Directory $CLONE_DIR already exists!"
        read -p "Use existing directory? (y/n): " USE_EXISTING
        if [ "$USE_EXISTING" != "y" ]; then
            exit 1
        fi
    else
        git clone "$DOTFILES_DIR" "$CLONE_DIR"
        print_success "Cloned repository"
    fi

    DOTFILES_DIR="$CLONE_DIR"
fi

# Expand ~ to full path
DOTFILES_DIR="${DOTFILES_DIR/#\~/$HOME}"

# Check if directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    print_error "Directory does not exist: $DOTFILES_DIR"
    exit 1
fi

# Check if it's a git repo
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    print_error "Not a git repository: $DOTFILES_DIR"
    read -p "Initialize as git repository? (y/n): " INIT_GIT
    if [ "$INIT_GIT" = "y" ]; then
        cd "$DOTFILES_DIR"
        git init
        print_success "Initialized git repository"
    else
        exit 1
    fi
fi

cd "$DOTFILES_DIR"
print_info "Working in: $DOTFILES_DIR"

# Create directory structure if it doesn't exist
print_info "Creating directory structure..."
mkdir -p zsh vim nvim tmux git config

# Function to copy file
copy_file() {
    local source="$1"
    local dest="$2"
    local desc="$3"

    if [ -f "$source" ] || [ -d "$source" ]; then
        # Get the directory of dest
        dest_dir=$(dirname "$dest")
        mkdir -p "$dest_dir"

        cp -r "$source" "$dest"
        print_success "Updated: $desc"
        return 0
    else
        print_warning "Not found: $source"
        return 1
    fi
}

# Copy all dotfiles
print_info "Syncing current dotfiles..."

# Use sanitized versions if they exist, otherwise use originals
if [ -f "$HOME/.zshrc.sanitized" ]; then
    copy_file "$HOME/.zshrc.sanitized" "$DOTFILES_DIR/zsh/zshrc" ".zshrc (sanitized)"
else
    copy_file "$HOME/.zshrc" "$DOTFILES_DIR/zsh/zshrc" ".zshrc"
fi

# Copy .zshrc.local template (not the actual .local file)
if [ -f "$HOME/.zshrc.local.template" ]; then
    copy_file "$HOME/.zshrc.local.template" "$DOTFILES_DIR/zsh/zshrc.local.template" ".zshrc.local.template"
fi

copy_file "$HOME/.vimrc" "$DOTFILES_DIR/vim/vimrc" ".vimrc"
copy_file "$HOME/.vim" "$DOTFILES_DIR/vim/vim" ".vim/"
copy_file "$HOME/.config/nvim" "$DOTFILES_DIR/nvim" ".config/nvim/"
copy_file "$HOME/.tmux.conf" "$DOTFILES_DIR/tmux/tmux.conf" ".tmux.conf"
copy_file "$HOME/.tmux_init" "$DOTFILES_DIR/tmux/tmux_init" ".tmux_init"

# Use sanitized gitconfig if it exists
if [ -f "$HOME/.gitconfig.sanitized" ]; then
    copy_file "$HOME/.gitconfig.sanitized" "$DOTFILES_DIR/git/gitconfig" ".gitconfig (sanitized)"
else
    copy_file "$HOME/.gitconfig" "$DOTFILES_DIR/git/gitconfig" ".gitconfig"
fi

# Copy .gitconfig.local template (not the actual .local file)
if [ -f "$HOME/.gitconfig.local.template" ]; then
    copy_file "$HOME/.gitconfig.local.template" "$DOTFILES_DIR/git/gitconfig.local.template" ".gitconfig.local.template"
fi

copy_file "$HOME/.gitignore" "$DOTFILES_DIR/git/gitignore" ".gitignore"

# Copy setup scripts
print_info "Copying setup scripts..."
if [ -f "$HOME/devbox-setup.sh" ]; then
    copy_file "$HOME/devbox-setup.sh" "$DOTFILES_DIR/devbox-setup.sh" "devbox-setup.sh"
    chmod +x "$DOTFILES_DIR/devbox-setup.sh" 2>/dev/null
fi

if [ -f "$HOME/sync-to-dotfiles.sh" ]; then
    copy_file "$HOME/sync-to-dotfiles.sh" "$DOTFILES_DIR/sync-to-dotfiles.sh" "sync-to-dotfiles.sh"
    chmod +x "$DOTFILES_DIR/sync-to-dotfiles.sh" 2>/dev/null
fi

# Only copy Claude Code settings (not history/debug/todos)
print_info "Syncing Claude Code settings..."
if [ -f "$HOME/.claude/settings.json" ]; then
    mkdir -p "$DOTFILES_DIR/config/claude"
    cp "$HOME/.claude/settings.json" "$DOTFILES_DIR/config/claude/settings.json"
    print_success "Updated: Claude settings.json"
fi

if [ -f "$HOME/.claude/mcp_servers.json" ]; then
    cp "$HOME/.claude/mcp_servers.json" "$DOTFILES_DIR/config/claude/mcp_servers.json"
    print_success "Updated: Claude mcp_servers.json"
fi

if [ -d "$HOME/.claude/commands" ]; then
    cp -r "$HOME/.claude/commands" "$DOTFILES_DIR/config/claude/"
    print_success "Updated: Claude commands/"
fi

if [ -d "$HOME/.claude/plugins" ]; then
    cp -r "$HOME/.claude/plugins" "$DOTFILES_DIR/config/claude/"
    print_success "Updated: Claude plugins/"
fi

# Create or update install.sh if it doesn't exist
if [ ! -f "$DOTFILES_DIR/install.sh" ]; then
    print_info "Creating install.sh..."
    cat > "$DOTFILES_DIR/install.sh" << 'INSTALL_EOF'
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

# Install .zshrc.local template if it exists and no .zshrc.local present
if [ -f "$DOTFILES_DIR/zsh/zshrc.local.template" ] && [ ! -f "$HOME/.zshrc.local" ]; then
    cp "$DOTFILES_DIR/zsh/zshrc.local.template" "$HOME/.zshrc.local"
    print_info "Created ~/.zshrc.local from template (edit for local config)"
fi
create_symlink "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"
[ -d "$DOTFILES_DIR/vim/vim" ] && create_symlink "$DOTFILES_DIR/vim/vim" "$HOME/.vim"
if [ -d "$DOTFILES_DIR/nvim" ]; then
    mkdir -p "$HOME/.config"
    create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
fi
create_symlink "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
if [ -f "$DOTFILES_DIR/tmux/tmux_init" ]; then
    create_symlink "$DOTFILES_DIR/tmux/tmux_init" "$HOME/.tmux_init"
    chmod +x "$HOME/.tmux_init" 2>/dev/null
fi
create_symlink "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/git/gitignore" "$HOME/.gitignore"

# Install .gitconfig.local template if it exists and no .gitconfig.local present
if [ -f "$DOTFILES_DIR/git/gitconfig.local.template" ] && [ ! -f "$HOME/.gitconfig.local" ]; then
    cp "$DOTFILES_DIR/git/gitconfig.local.template" "$HOME/.gitconfig.local"
    print_info "Created ~/.gitconfig.local from template (edit for local config)"
fi

# Install Claude configs (selectively)
if [ -f "$DOTFILES_DIR/config/claude/settings.json" ]; then
    mkdir -p "$HOME/.claude"
    create_symlink "$DOTFILES_DIR/config/claude/settings.json" "$HOME/.claude/settings.json"
fi

if [ -f "$DOTFILES_DIR/config/claude/mcp_servers.json" ]; then
    mkdir -p "$HOME/.claude"
    create_symlink "$DOTFILES_DIR/config/claude/mcp_servers.json" "$HOME/.claude/mcp_servers.json"
fi

if [ -d "$DOTFILES_DIR/config/claude/commands" ]; then
    create_symlink "$DOTFILES_DIR/config/claude/commands" "$HOME/.claude/commands"
fi

if [ -d "$DOTFILES_DIR/config/claude/plugins" ]; then
    create_symlink "$DOTFILES_DIR/config/claude/plugins" "$HOME/.claude/plugins"
fi

echo ""
print_success "Dotfiles installed!"
[ -d "$BACKUP_DIR" ] && print_info "Backups: $BACKUP_DIR"
INSTALL_EOF

    chmod +x "$DOTFILES_DIR/install.sh"
    print_success "Created install.sh"
fi

# Create or update README if it doesn't exist
if [ ! -f "$DOTFILES_DIR/README.md" ]; then
    print_info "Creating README.md..."
    cat > "$DOTFILES_DIR/README.md" << 'README_EOF'
# Dotfiles

Personal configuration files for development environment.

## Quick Start (New Machine)

```bash
# Clone this repository
git clone <this-repo> ~/dotfiles
cd ~/dotfiles

# Run the setup script (installs everything + dotfiles)
./devbox-setup.sh
```

## Manual Installation (Dotfiles Only)

If you already have the required tools installed:

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Contents

- **zsh/**: Zsh shell configuration
- **vim/**: Vim configuration
- **nvim/**: Neovim configuration
- **tmux/**: Tmux terminal multiplexer configuration
- **git/**: Git configuration
- **config/**: Other application configs

## Updating

To sync your current dotfiles to this repo, run the sync script on your source machine.
README_EOF

    print_success "Created README.md"
fi

# Create .gitignore if it doesn't exist
if [ ! -f "$DOTFILES_DIR/.gitignore" ]; then
    print_info "Creating .gitignore..."
    cat > "$DOTFILES_DIR/.gitignore" << 'GITIGNORE_EOF'
# Vim swap files and history
*.swp
*.swo
*~
.netrwhist

# OS files
.DS_Store

# Local/private configs (not tracked)
*.local
git/gitconfig.local
zsh/zshrc.local

# Claude session data (not needed in dotfiles)
config/claude/history.jsonl
config/claude/debug/
config/claude/todos/
config/claude/file-history/
config/claude/projects/
config/claude/shell-snapshots/
GITIGNORE_EOF

    print_success "Created .gitignore"
fi

# Show git status
echo ""
print_info "Git status:"
git status --short

echo ""
print_info "Review the changes above."
read -p "Commit and push changes? (y/n): " COMMIT_CHANGES

if [ "$COMMIT_CHANGES" = "y" ]; then
    git add -A

    echo ""
    echo "Enter commit message (or press Enter for default):"
    read -p "> " COMMIT_MSG

    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="Update dotfiles - $(date +%Y-%m-%d)"
    fi

    git commit -m "$COMMIT_MSG"
    print_success "Committed changes"

    read -p "Push to remote? (y/n): " PUSH_CHANGES
    if [ "$PUSH_CHANGES" = "y" ]; then
        # Get current branch name
        BRANCH=$(git rev-parse --abbrev-ref HEAD)

        # Check if remote is set
        if git remote | grep -q origin; then
            git push -u origin "$BRANCH"
            print_success "Pushed to remote (origin/$BRANCH)"
        else
            print_warning "No remote 'origin' found. Add remote first:"
            echo "  git remote add origin <your-repo-url>"
        fi
    fi
fi

echo ""
echo "========================================="
echo "  Sync complete!"
echo "========================================="
echo ""
print_info "Dotfiles location: $DOTFILES_DIR"
print_info "To use on a new machine:"
echo "  1. Clone the repo: git clone <your-repo> ~/dotfiles"
echo "  2. Run: cd ~/dotfiles && ./install.sh"
