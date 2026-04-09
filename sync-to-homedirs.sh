#!/usr/bin/env bash
# Syncs dotfiles to the homedirs repo (users/forsythe/).
# Dotfiles is the source of truth; run this after editing configs here,
# then commit and push in the homedirs repo to deploy via Puppet.
#
# Usage: ./sync-to-homedirs.sh <path-to-homedirs-repo>

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_info()    { echo -e "${BLUE}→${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOMEDIRS_REPO="${1:-}"
USERNAME="forsythe"
TARGET="$HOMEDIRS_REPO/users/$USERNAME"

if [ -z "$HOMEDIRS_REPO" ]; then
    print_error "Usage: $0 <path-to-homedirs-repo>"
    exit 1
fi

if [ ! -d "$HOMEDIRS_REPO/users" ]; then
    print_error "Not a homedirs repo (no users/ directory): $HOMEDIRS_REPO"
    exit 1
fi

echo "========================================="
echo "  Syncing dotfiles → homedirs"
echo "  Target: $TARGET"
echo "========================================="
echo ""

mkdir -p "$TARGET"
mkdir -p "$TARGET/.vim/autoload"
mkdir -p "$TARGET/.vim/colors"
mkdir -p "$TARGET/.config/nvim/lua"
mkdir -p "$TARGET/.config/nvim/colors"

copy_file() {
    local src="$1"
    local dest="$2"
    if [ -f "$src" ]; then
        cp "$src" "$dest"
        print_success "Copied $(basename "$dest")"
    else
        print_warning "Source not found, skipping: $src"
    fi
}

copy_file "$DOTFILES_DIR/zsh/zshrc"                          "$TARGET/.zshrc"
copy_file "$DOTFILES_DIR/git/gitconfig"                      "$TARGET/.gitconfig"
copy_file "$DOTFILES_DIR/git/gitignore"                      "$TARGET/.gitignore"
copy_file "$DOTFILES_DIR/tmux/tmux.conf"                     "$TARGET/.tmux.conf"
copy_file "$DOTFILES_DIR/vim/vimrc"                          "$TARGET/.vimrc"
copy_file "$DOTFILES_DIR/vim/vim/autoload/plug.vim"          "$TARGET/.vim/autoload/plug.vim"
copy_file "$DOTFILES_DIR/vim/vim/colors/badwolf.vim"         "$TARGET/.vim/colors/badwolf.vim"
copy_file "$DOTFILES_DIR/nvim/nvim/init.vim"                 "$TARGET/.config/nvim/init.vim"
copy_file "$DOTFILES_DIR/nvim/nvim/lua/config.lua"           "$TARGET/.config/nvim/lua/config.lua"
copy_file "$DOTFILES_DIR/nvim/nvim/colors/badwolf.vim"       "$TARGET/.config/nvim/colors/badwolf.vim"

# Create .gitconfig.local with Yelp identity if not already present
if [ ! -f "$TARGET/.gitconfig.local" ]; then
    cat > "$TARGET/.gitconfig.local" <<EOF
[user]
	name = $USERNAME
	email = $USERNAME@yelp.com
EOF
    print_success "Created .gitconfig.local (Yelp identity)"
else
    print_warning ".gitconfig.local already exists — not overwritten"
fi

if [ ! -f "$TARGET/.zshrc.local" ]; then
    print_warning ".zshrc.local not found — create $TARGET/.zshrc.local manually in the homedirs repo"
fi

echo ""
print_success "Sync complete."
print_info "Next steps:"
echo "  1. cd $HOMEDIRS_REPO"
echo "  2. Review changes: git diff"
echo "  3. git add users/$USERNAME && git commit -m 'Update $USERNAME dotfiles'"
echo "  4. git push → Puppet deploys within ~2 hours"
