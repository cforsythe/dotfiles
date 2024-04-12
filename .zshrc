# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/nail/home/forsythe/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#
# git plugin docs: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh
plugins=(
    git
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
source /etc/profile.d/yelpcustom.zsh
alias pv='pytest -vv'
alias pt=pytest
alias vim=nvim
alias yim-clean='rm ~/.*.tmp'
alias zshrc='vim ~/.zshrc'
alias update='source ~/.zshrc'
alias standup='python3 ~/standup.py'
clone-service() {
    git clone git@github.yelpcorp.com:services/"$1"
}
clone-package() {
    git clone git@github.yelpcorp.com:python-packages/"$1"
}
export PATH=~/.local/bin/:$PATH
log-latest() {
    echo "Grabbing latest alias"
    schema_alias=$(datapipe schema describe-source --namespace=$1 --source=$2 | awk '/alias/{getline;gsub(/"/,"");gsub(" ","");print}' | tail -n 1)
    echo "Logging stream of alias ${schema_alias} for namespace=$1 source=$2"
    datapipe stream tail --namespace=$1 --source=$2 --alias=${schema_alias}
}
alias prod='ssh -A adhoc-prod'
export TERM=xterm-256color
alias aws='aws --profile dev-bode'
alias gpom='git pull origin main'
alias gp='git push origin HEAD'
alias gpf='git push origin HEAD --force'
ya() {
  PKG_NAME="$1"

  if [[ $PKG_NAME == yrc-* ]]; then
    PKG_NAME="yelp-react-component${PKG_NAME:3}"
  fi

  LATEST_VERSION=$(yarn npm info "$PKG_NAME" --json | jq -r '.version')
  yarn add "$PKG_NAME@^$LATEST_VERSION"
}

function cdr() {
  YRC_PKG="$1"

  CD_PATH="/nail/home/$USER/pg/yelp-frontend/packages/yelp-react-component-$YRC_PKG"

  if [[ -d $CD_PATH ]]; then
    cd "$CD_PATH"
  else
    echo "Directory not found: $CD_PATH"
  fi
}

alias coverage='cd ~/pg/yelp-frontend/coverage/lcov-report && python -m http.server 12345'
