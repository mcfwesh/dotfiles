# Set the root for pyenv
export PYENV_ROOT="$HOME/.pyenv"

# General environment settings
export TFENV_ARCH="amd64"
export GODEBUG=asyncpreemptoff=1
export MallocNanoZone=0 # For compatibility with some tools

if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"

if command -v rbenv &> /dev/null; then
  eval "$(rbenv init - zsh)"
fi

alias run-help='man'
alias which-command='whence'

# activate benevity_rc
source ~/.benevity_rc

# Git prompt helpers
parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

parse_git_repo() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        basename "$(git rev-parse --show-toplevel)" 2> /dev/null
    fi
}

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

# Defining some colors for the prompt
COLOR_DIR="%F{blue}"
COLOR_GIT="%F{yellow}"
COLOR_DEF="%f"

setopt PROMPT_SUBST

# Set the prompt structure
PROMPT='${COLOR_DIR}%~ ${COLOR_GIT}$(parse_git_repo) - $(parse_git_branch)${COLOR_DEF} $ '
RPROMPT='$(aws_profile_short)'

_set_colors() {
    case $1 in
        (red) set_bg_color 50 0 0 && set_tab_color 270 60 83 ;;
        (blue) set_bg_color 0 0 230 && set_tab_color 0 0 255 ;;
        (green) set_bg_color 0 33 0 && set_tab_color 57 197 77 ;;
        (purple) set_bg_color 40 10 50 && set_tab_color 120 30 120 ;;
        (yellow) set_bg_color 255 255 0 && set_tab_color 255 255 0 ;;
    esac
}

set_colors() {
    if [ -z "$1" ]; then
        echo "Profile name required to set colors"
        return
    fi
    case $1 in
        (benevity_live_prod) _set_colors red ;;
        (benevity_live_preprod) _set_colors green ;;
        (benevity_live_staging) _set_colors purple ;;
        (benevity_staging_uat) _set_colors green ;;
        (benevity_live_dr) _set_colors purple ;;
        (benevity_core_pipeline) _set_colors purple ;;
        (benevity_master) _set_colors purple ;;
        (benevity_mgmt_iam) _set_colors purple ;;
        (benevity_mgmt_security) _set_colors purple ;;
        (benevity_product_dev) _set_colors green ;;
        (benevity_product_devtools) _set_colors purple ;;
        (benevity_product_poc) _set_colors green ;;
        (benevity_product_qa) _set_colors green ;;
        (benevity_shared_prod) _set_colors red ;;
        (benevity_shared_qa) _set_colors green ;;
        (benevity_sre_qa) _set_colors green ;;
        (*) echo "Warning: $1 does not have a defined color scheme, using yellow!"; _set_colors yellow ;;
    esac
}

export PATH=/Users/nathan.ojieabu/Applications/sonar-scanner-7.1.0.4889-macosx-aarch64/bin:$PATH
export TFROOT=/Users/nathan.ojieabu/Documents/repos/terraform
export TASKROOT=/Users/nathan.ojieabu/Documents/repos/task-notes