#!/usr/bin/env zsh
# Link home paths to files in this repo. Edit files here, not copies under ~.
set -euo pipefail

REPO="${0:A:h}"
HOME_DIR="${HOME:?HOME is not set}"

link_file() {
  local repo_rel="$1"
  local target="$2"
  local src="${REPO}/${repo_rel}"

  [[ -e "${src}" ]] || { echo "bootstrap: missing ${src}" >&2; exit 1; }
  mkdir -p "${target:h}"

  if [[ -e "${target}" || -L "${target}" ]]; then
    if [[ -L "${target}" && "$(readlink "${target}")" == "${src}" ]]; then
      echo "ok  ${target} -> ${src}"
      return 0
    fi
    rm -rf "${target}"
  fi

  ln -sfn "${src}" "${target}"
  echo "link ${target} -> ${src}"
}

link_file zshrc "${HOME_DIR}/.zshrc"
link_file benevity_rc "${HOME_DIR}/.benevity_rc"
link_file p10k.zsh "${HOME_DIR}/.p10k.zsh"
link_file gitconfig "${HOME_DIR}/.gitconfig"
link_file gitconfig-personal "${HOME_DIR}/.gitconfig-personal"
link_file gitmessage "${HOME_DIR}/.gitmessage"
link_file gitignore_global "${HOME_DIR}/.gitignore_global"
link_file git-template "${HOME_DIR}/.git-template"

for script in "${REPO}"/bin/*; do
  [[ -f "${script}" ]] || continue
  chmod +x "${script}"
  link_file "bin/${script:t}" "${HOME_DIR}/.local/bin/${script:t}"
done

mkdir -p "${HOME_DIR}/Library/LaunchAgents"
for plist in "${REPO}"/launchagents/*.plist; do
  [[ -f "${plist}" ]] || continue
  link_file "launchagents/${plist:t}" "${HOME_DIR}/Library/LaunchAgents/${plist:t}"
done

echo "bootstrap: done"
