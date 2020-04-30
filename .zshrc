# If you come from bash you might have to change your $PATH.

export PATH=$HOME/bin:/usr/local/bin:/sbin:/usr/sbin:$PATH
# Add golang to path
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$(go env GOPATH)/bin
# Add snap path
export PATH=$PATH:/snap/bin

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes


ZSH_THEME="spaceship"
#ZSH_THEME="robbyrussell"


######### PLUGINS ###########
plugins=(git kubectl minikube docker virtualenv zsh-autosuggestions)

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
HIST_STAMPS="dd/mm/yyyy"

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
SPACESHIP_BATTERY_THRESHOLD="40"

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
source /home/nitish/.aliases

# Exports
# GPG issue fix https://stackoverflow.com/questions/39494631/gpg-failed-to-sign-the-data-fatal-failed-to-write-commit-object-git-2-10-0
export GPG_TTY=$(tty)

# Autocomplete for kubectx
autoload -U compinit && compinit

# Functions
startvm() { if  virsh start $1; then; sleep 8s; fi; ssh th3nyx@$1; }

penmount() { sudo mount -o rw,user,exec,umask=000 /dev/$1 /mnt/tmp; }

hddoff() { sudo udisksctl power-off -b /dev/$1; }

localServer() { if [[ $1 == 'start' ]]; then; docker run --rm --name local-nginx -v ~/Documents/localShare:/usr/share/nginx/html:ro -v ~/Documents/localShare/default.conf:/etc/nginx/conf.d/default.conf -p 80:80 -d nginx; fi; if [[ $1 == 'stop' ]]; then; docker stop local-nginx; fi; }
#alias config='/usr/bin/git --git-dir=/home/nitish/.cfg/ --work-tree=/home/nitish'

docker-restore() { unset DOCKER_TLS_VERIFY; unset DOCKER_HOST; unset DOCKER_CERT_PATH; unset DOCKER_MACHINE_NAME; }

## Stole from arush-sal
 if [ "$TMUX" = "" ]; then
 	 if [[ -n $(pgrep tmux) ]]; then	
 		 if tmux ls|grep -q -e "0: ."; then tmux attach-session -t 0; else tmux new-session -s 0; fi
     else 
		 tmux new-session -s 0
	 fi
 fi
