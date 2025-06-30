# Agent detection - only activate minimal mode for actual agents
if [[ -n "$npm_config_yes" ]] || [[ -n "$CI" ]] || [[ "$-" != *i* ]]; then
  export AGENT_MODE=true
else
  export AGENT_MODE=false
fi

if [[ "$AGENT_MODE" == "true" ]]; then
  POWERLEVEL9K_INSTANT_PROMPT=off
  # Disable complex prompt features for AI agents
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
  # Ensure non-interactive mode
  export DEBIAN_FRONTEND=noninteractive
  export NONINTERACTIVE=1
fi

# Enable Powerlevel10k instant prompt only when not in agent mode
if [[ "$AGENT_MODE" != "true" ]] && [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set Oh My Zsh theme conditionally - disable for agents only
if [[ "$AGENT_MODE" == "true" ]]; then
  ZSH_THEME=""  # Disable Powerlevel10k for agents
else
  ZSH_THEME="powerlevel10k/powerlevel10k"
fi

# Later in your .zshrc - minimal prompt for agents
if [[ "$AGENT_MODE" == "true" ]]; then
  PROMPT='%n@%m:%~%# '
  RPROMPT=''
  unsetopt CORRECT
  unsetopt CORRECT_ALL
  setopt NO_BEEP
  setopt NO_HIST_BEEP
  setopt NO_LIST_BEEP

  # Agent-friendly aliases to avoid interactive prompts
  alias rm='rm -f'
  alias cp='cp -f'
  alias mv='mv -f'
  alias npm='npm --no-fund --no-audit'
  alias yarn='yarn --non-interactive'
  alias pip='pip --quiet'
  alias git='git -c advice.detachedHead=false'
else
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

# Agent detection - only activate minimal mode for actual agents
if [[ -n "$VSCODE_SHELL_INTEGRATION" ]]; then
  POWERLEVEL9K_INSTANT_PROMPT=off
  # Disable complex prompt features for AI agents
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
  # Ensure non-interactive mode
  export DEBIAN_FRONTEND=noninteractive
  export NONINTERACTIVE=1
fi

# Your existing Powerlevel10k instant prompt setup...
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Theme selection - disable only for agents
if [[ -n "$VSCODE_SHELL_INTEGRATION" ]]; then
  ZSH_THEME=""  # Disable Powerlevel10k for agents
else
  ZSH_THEME="powerlevel10k/powerlevel10k"  # Full theme for IDE terminal
fi

# Later in your .zshrc - minimal prompt for agents
if [[ -n "$VSCODE_SHELL_INTEGRATION" ]]; then
  PROMPT='%n@%m:%~%# '
  RPROMPT=''
  unsetopt CORRECT
  unsetopt CORRECT_ALL
  setopt NO_BEEP
  setopt NO_HIST_BEEP
  setopt NO_LIST_BEEP

  # Agent-friendly aliases
  alias rm='rm -f'
  alias cp='cp -f'
  alias mv='mv -f'
  alias npm='npm --no-fund --no-audit'
  alias yarn='yarn --non-interactive'
  alias pip='pip --quiet'
  alias git='git -c advice.detachedHead=false'
else
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
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
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git)
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  brew
  # dotenv
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

export PATH="$HOME/go/bin/:$PATH"

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# added by terraform -install-autocomplete
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
alias '??'='gh copilot suggest -t shell'
alias 'git?'='gh copilot suggest -t git'
alias 'explain?'='gh copilot explain'

# used for gh cli auto completion
# see: https://cli.github.com/manual/gh_completion
[[ -d ~/.oh-my-zsh/completions ]] || mkdir ~/.oh-my-zsh/completions
gh completion -s zsh > ~/.oh-my-zsh/completions/_gh
autoload -U compinit
compinit -i

# command output behavior - send output to terminal
# see: https://superuser.com/questions/1698521/zsh-keep-all-command-outputs-on-terminal-screen
export PAGER=""

# History settings
HISTSIZE=500000
SAVEHIST=500000
# Do not put commands in history if they begin with a SPACE
setopt HIST_IGNORE_SPACE
# Trim excessive whitespace from commands before adding to history
setopt HIST_REDUCE_BLANKS
# Expire duplicate entries first when trimming history
# setopt HIST_EXPIRE_DUPS_FIRST

# Function: Deletes most recent line of history
# cannot be ran twice in a row (only once, otherwise it deletes 2 lines)
hrm() {
  ed -s ~/.zsh_history <<< $'-1,$d\nwq'
  # sed -i '' '$d' ~/.zsh_history # you need it to run twice the first time...
}

# use homebrew ruby if not on Codespaces
if [ $(whoami) != "codespace" ]; then export PATH="/opt/homebrew/opt/ruby/bin:$PATH"; fi

## Read benevity_rc
# This file contains environment variables and aliases that are specific to Benevity.
source ~/.benevity_rc

# AWS ENVIRONMENT
case "$AWS_PROFILE" in
    (*_prod | *_prod_*) color="%F{red}"  ;;
    (*_preprod | *_staging | *_stage*) color="%F{yellow}"  ;;
    (*_dev | *_qa | *_test*) color="%F{green}"  ;;
    (*) color="%F{cyan}"  ;;
esac

aws_profile_short () {
	if [[ -n "$AWS_PROFILE" ]]
	then
		local short_name="${AWS_PROFILE#benevity_}"
		local color=""
		case "$AWS_PROFILE" in
			(*_prod | *_prod_*) color="%F{red}"  ;;
			(*_preprod | *_staging | *_stage*) color="%F{yellow}"  ;;
			(*_dev | *_qa | *_test*) color="%F{green}"  ;;
			(*) color="%F{cyan}"  ;;
		esac
		echo " ${color}[aws:${short_name}]%f"
	fi
}

# Load colors and set prompt
autoload -U colors && colors

## Defining some colors for the prompt
COLOR_DIR="%F{blue}"
COLOR_GIT="%F{yellow}"
COLOR_DEF="%f"

setopt PROMPT_SUBST

## Set the prompt structure
PROMPT='${COLOR_DIR}%~ ${COLOR_GIT}$(parse_git_repo) - $(parse_git_branch)${COLOR_DEF} $ '
RPROMPT='$(aws_profile_short)'

# Set the root for pyenv
export PYENV_ROOT="$HOME/.pyenv"

# General environment settings
export TFENV_ARCH="amd64"
export MallocNanoZone=0 # For compatibility with some tools

# Personal helper alias
export TFROOT="$HOME/Documents/repos/terraform"
export TASKROOT="$HOME/Documents/repos/task-notes"

# # Set Oh My Zsh theme conditionally for cursor
# if [[ "$TERM_PROGRAM" == "vscode" ]]; then
#   ZSH_THEME=""  # Disable Powerlevel10k for Cursor
# else
#   ZSH_THEME="powerlevel10k/powerlevel10k"
# fi

# # Load Oh My Zsh
# source $ZSH/oh-my-zsh.sh

# # Use a minimal prompt in Cursor to avoid command detection issues
# if [[ "$TERM_PROGRAM" == "vscode" ]]; then
#   PROMPT='%n@%m:%~%# '
#   RPROMPT=''
# else
#   [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
# fi