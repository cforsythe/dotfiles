# Dotfiles

Personal development environment configuration files.

## Quick Start (New Machine)

```bash
# Clone this repository
git clone git@github.com:yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the automated setup script
./devbox-setup.sh
```

The setup script will automatically:
- Install essential packages (git, zsh, vim, neovim, tmux, etc.)
- Install Oh My Zsh with plugins (zsh-autosuggestions, you-should-use)
- Install NVM and Node.js LTS
- Install vim-plug and all Vim/Neovim plugins
- Install tmux plugin manager (TPM) and plugins
- Install Claude Code CLI
- Symlink all dotfiles to your home directory
- Change your default shell to Zsh

## Manual Installation (Dotfiles Only)

If you already have the required tools installed and just want to install the dotfiles:

```bash
git clone git@github.com:yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Repository Structure

```
dotfiles/
├── zsh/
│   ├── zshrc                      # Main Zsh configuration
│   └── zshrc.local.template       # Template for local/private settings
├── vim/
│   ├── vimrc                      # Vim configuration
│   └── vim/                       # Vim plugins and colors
├── nvim/                          # Neovim configuration
│   ├── init.vim                   # Main Neovim config
│   ├── lua/                       # Lua configuration files
│   └── colors/                    # Color schemes
├── tmux/
│   ├── tmux.conf                  # Tmux configuration
│   └── tmux_init                  # Tmux session init script
├── git/
│   ├── gitconfig                  # Git configuration
│   ├── gitconfig.local.template   # Template for local git settings
│   └── gitignore                  # Global gitignore
├── config/
│   └── claude/                    # Claude Code settings
│       ├── settings.json
│       └── mcp_servers.json
├── devbox-setup.sh                # Automated setup script
├── sync-to-dotfiles.sh            # Script to update this repo
└── install.sh                     # Dotfiles installation script
```

## Local Configuration

Some files support `.local` versions for machine-specific or private configurations:

### Zsh Local Config (`~/.zshrc.local`)

Create this file for company-specific or machine-specific settings:

```bash
# Copy the template
cp ~/dotfiles/zsh/zshrc.local.template ~/.zshrc.local

# Edit with your local settings
vim ~/.zshrc.local
```

Use this for:
- Company-specific aliases and functions
- Internal tool configurations
- SSH/security settings
- Machine-specific PATH modifications

### Git Local Config (`~/.gitconfig.local`)

Create this file for local git settings:

```bash
# Copy the template
cp ~/dotfiles/git/gitconfig.local.template ~/.gitconfig.local

# Edit with your settings
vim ~/.gitconfig.local
```

Use this for:
- User name and email (if different per machine)
- Company-specific git configurations
- Safe directories

**Note:** `.local` files are not tracked in git (they're in `.gitignore`).

## What Gets Installed

### System Packages
- zsh, git, curl, wget, tmux, vim, neovim
- build-essential (gcc, make, etc.)
- python3, python3-pip
- jq, htop, tree
- ripgrep (if available)

### Zsh Setup
- Oh My Zsh framework
- Plugins: git, zsh-autosuggestions, you-should-use
- Robbyrussell theme (customizable)

### Vim/Neovim
- vim-plug plugin manager
- Multiple plugins (airline, gruvbox, LSP support, etc.)
- GitHub Copilot integration
- Auto-completion with nvim-cmp

### Tmux
- Custom keybindings (prefix: Ctrl+a)
- TPM (Tmux Plugin Manager)
- Plugins: tmux-sensible, tmux-resurrect

### Development Tools
- NVM (Node Version Manager) + Node.js LTS
- Claude Code CLI

## Updating Your Dotfiles

After making changes to your dotfiles on your main machine:

```bash
# Run the sync script
./sync-to-dotfiles.sh ~/dotfiles

# Or if sync script is in your dotfiles
cd ~/dotfiles
./sync-to-dotfiles.sh .

# Commit and push changes
git add .
git commit -m "Update dotfiles"
git push
```

## Syncing to Other Machines

On your other machines, pull the latest changes:

```bash
cd ~/dotfiles
git pull
```

The symlinks will automatically reflect the updated files.

## Troubleshooting

### Vim/Neovim plugins not installed

```bash
# For Neovim
nvim +PlugInstall +qall

# For Vim
vim +PlugInstall +qall
```

### Tmux plugins not working

```bash
# Inside tmux, press: Ctrl+a then Shift+I
# Or run manually:
~/.tmux/plugins/tpm/scripts/install_plugins.sh
```

### Zsh plugins not loading

```bash
# Source your zshrc
source ~/.zshrc

# Or restart your shell
exec zsh
```

### Shell didn't change to Zsh

```bash
chsh -s $(which zsh)
# Then log out and log back in
```

## SSH Key Setup for GitHub

If you haven't set up SSH keys for GitHub:

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: https://github.com/settings/ssh/new

# Test connection
ssh -T git@github.com
```

## Customization

### Change Zsh Theme

Edit `~/dotfiles/zsh/zshrc` and change:
```bash
ZSH_THEME="robbyrussell"
```

### Add More Vim Plugins

Edit `~/dotfiles/nvim/init.vim` and add:
```vim
Plug 'author/plugin-name'
```
Then run `:PlugInstall` in Neovim.

### Add Tmux Plugins

Edit `~/dotfiles/tmux/tmux.conf` and add:
```bash
set -g @plugin 'plugin-name'
```
Then press `Ctrl+a + I` in tmux.

## Requirements

- Linux or macOS
- sudo access (for package installation)
- Internet connection
- Git

## License

MIT License - feel free to use and modify as you wish.
