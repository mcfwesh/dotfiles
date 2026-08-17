# Local machine bootstrap paths
# Cursor agent/integrated shells sometimes inherit a PATH with no /usr/bin,
# or wipe PATH mid-session when restoring shell state. Later prepends (brew,
# pyenv, etc.) never restore /usr/bin, so curl/sed/clear vanish. Re-seed when
# missing at startup and again before each prompt/command.
_ensure_system_path() {
  case ":${PATH}:" in
    *:/usr/bin:*) ;;
    *) export PATH="/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}" ;;
  esac
}
_ensure_system_path
export PATH="$HOME/.local/bin:$PATH"
# Powerlevel10k glyphs need UTF-8; Cursor/agent shells often start with LC_CTYPE=C.
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Warp renders prompt/input separately; skip instant prompt there (Warp + p10k docs).
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]] && [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# iTerm tab/bg colors via AppleScript — not supported in Warp.
[[ "$TERM_PROGRAM" == "WarpTerminal" ]] && export ENABLE_SET_BACKGROUND_COLOR=false

# Warp Shell prompt (p10k) hides Warp's clickable path chip. cdf restores
# "pick a Finder folder and cd" without dropping p10k.
cdf() {
  emulate -L zsh
  local dir escaped
  escaped=${PWD//\\/\\\\}
  escaped=${escaped//\"/\\\"}
  dir=$(osascript -e "POSIX path of (choose folder with prompt \"cd to folder\" default location POSIX file \"${escaped}\")" 2>/dev/null) || return
  cd -- "${dir%/}"
}

# Git prompt helpers
parse_git_branch() {
    git branch 2> /dev/null | /usr/bin/sed -n -e 's/^\* \(.*\)/[\1]/p'
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

# Catch mid-session PATH wipes (Cursor agent shell state restore).
autoload -Uz add-zsh-hook
add-zsh-hook precmd _ensure_system_path
add-zsh-hook preexec _ensure_system_path

# Powerlevel10k (config: ~/.p10k.zsh -> dotfiles/p10k.zsh)
source "${HOMEBREW_PREFIX:-/opt/homebrew}/share/powerlevel10k/powerlevel10k.zsh-theme"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# set_colors / _set_colors live in ~/.benevity_rc (sourced above)

export PATH=/Users/nathan.ojieabu/Applications/sonar-scanner-7.1.0.4889-macosx-aarch64/bin:$PATH
export TFROOT=/Users/nathan.ojieabu/repos/terraform
export TASKROOT=/Users/nathan.ojieabu/repos/task-notes
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PCT_TFPATH=/opt/homebrew/bin/terraform
export PATH="$PATH:/Users/nathan.ojieabu/.local/bin/pipenv"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

export ATLASSIAN_SITE_URL="https://benevity.atlassian.net"
[ -f "${HOME}/.secrets" ] && source "${HOME}/.secrets"

alias cursor-mcp-env-sync="${HOME}/.local/bin/cursor-mcp-env-sync"
alias claude-mcp-env-sync="${HOME}/.local/bin/cursor-mcp-env-sync"

cursor() {
    local bin="${HOME}/.local/bin/cursor"

    case "${1:-}" in
        -h|--help|-v|--version|-s|--status|tunnel|agent)
            "$bin" "$@"
            return
            ;;
    esac

    for arg in "$@"; do
        case "$arg" in
            --list-extensions|--install-extension|--uninstall-extension|--update-extensions|--add-mcp)
                "$bin" "$@"
                return
                ;;
        esac
    done

    local args=()
    local has_classic=0 has_glass=0 has_chat=0
    local has_new=0 has_reuse=0 has_add=0

    for arg in "$@"; do
        case "$arg" in
            --classic) has_classic=1 ;;
            --glass) has_glass=1 ;;
            --chat) has_chat=1 ;;
            -n|--new-window) has_new=1 ;;
            -r|--reuse-window) has_reuse=1 ;;
            -a|--add) has_add=1 ;;
        esac
    done

    (( !has_new && !has_reuse && !has_add )) && args+=(-n)
    (( !has_classic && !has_glass && !has_chat )) && args+=(--classic)

    "$bin" "${args[@]}" "$@"
}

cursor-mcp-env-add() {
    if [[ -z "$1" ]]; then
        echo "Usage: cursor-mcp-env-add ENV_VAR_NAME"
        return 1
    fi

    local vars_file="${HOME}/.cursor/mcp-env-vars"
    mkdir -p "${vars_file:h}"

    if grep -qx "$1" "${vars_file}" 2>/dev/null; then
        echo "$1 is already listed in ${vars_file}"
    else
        echo "$1" >> "${vars_file}"
        echo "Added $1 to ${vars_file}"
    fi

    "${HOME}/.local/bin/cursor-mcp-env-sync"
}

claude-mcp-env-add() {
    if [[ -z "$1" ]]; then
        echo "Usage: claude-mcp-env-add ENV_VAR_NAME"
        return 1
    fi

    local vars_file="${HOME}/.claude/mcp-env-vars"
    mkdir -p "${vars_file:h}"

    if grep -qx "$1" "${vars_file}" 2>/dev/null; then
        echo "$1 is already listed in ${vars_file}"
    else
        echo "$1" >> "${vars_file}"
        echo "Added $1 to ${vars_file}"
    fi

    "${HOME}/.local/bin/cursor-mcp-env-sync"
}

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/nathan.ojieabu/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Rancher Desktop exposes Docker at ~/.rd/docker.sock, not ~/.docker/run/docker.sock.
# pre-commit terraform-docs-docker and other Docker CLI tools need DOCKER_HOST set.
_rancher_docker_sock="${HOME}/.rd/docker.sock"
if [[ -S "${_rancher_docker_sock}" ]]; then
  export DOCKER_HOST="unix://${_rancher_docker_sock}"
fi
unset _rancher_docker_sock

alias rm='trash'

# zsh plugins (syntax-highlighting must be last)
[[ -r "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
  source "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -r "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
  source "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/nathan.ojieabu/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/nathan.ojieabu/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/nathan.ojieabu/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/nathan.ojieabu/google-cloud-sdk/completion.zsh.inc'; fi
