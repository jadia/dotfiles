# If you come from bash you might have to change your $PATH.


#zmodload zsh/zprof

#export PATH=$HOME/bin:/usr/local/bin:/sbin:/usr/sbin:$PATH
## Add golang to path
#export PATH=$PATH:/usr/local/go/bin
#export PATH=$PATH:$(go env GOPATH)/bin
## Add snap path
#export PATH=$PATH:/snap/bin
#
## Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes


ZSH_THEME="spaceship"
#ZSH_THEME="robbyrussell"


######### PLUGINS ###########
plugins=(git
        virtualenv
        docker 
        zsh-autosuggestions
    )
        # kubectl 
        # minikube 


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

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

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
HIST_STAMPS="dd.mm.yyyy"
HISTSIZE=1000000000
SAVEHIST=$HISTSIZE

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

source $ZSH/oh-my-zsh.sh

# User configuration for terminal
SPACESHIP_USER_SHOW="always"
SPACESHIP_CHAR_SYMBOL=" >"
SPACESHIP_CHAR_SUFFIX=" "
SPACESHIP_BATTERY_THRESHOLD="50"
SPACESHIP_BATTERY_SHOW="charged"

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

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
 alias zshconfig="vim ~/.zshrc"
 alias ls="colorls --sd"
 alias ll="colorls -l --sd"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#source /home/nitish/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source /home/nitish/.aliases

# Exports
# GPG issue fix https://stackoverflow.com/questions/39494631/gpg-failed-to-sign-the-data-fatal-failed-to-write-commit-object-git-2-10-0
export GPG_TTY=$(tty)

# Fix same color issue for zsh autocomplete in ubuntu regolith
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

# Autocomplete for kubectx
autoload -U compinit && compinit
setopt HIST_IGNORE_SPACE

# Initialize variables containing passwords and keys
# if [ -f ~/.pass.sh ]; then
#     source ~/.pass.sh
# fi
eval "$(mcfly init zsh)"
