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

# Warp: honor shell PS1 (p10k) + MesloLGS NF per Warp/p10k docs.
if [[ -f "${REPO}/warp/p10k-settings.toml" ]]; then
  mkdir -p "${HOME_DIR}/.warp"
  WARP_SETTINGS="${HOME_DIR}/.warp/settings.toml"
  python3 - "${REPO}/warp/p10k-settings.toml" "${WARP_SETTINGS}" <<'PY'
import re
import sys
from pathlib import Path

fragment = Path(sys.argv[1]).read_text()
target = Path(sys.argv[2])

if target.exists():
    text = target.read_text()
else:
    text = ""

for section, body in re.findall(r"(\[[^\]]+\])\n((?:[^\[]|\n)*)", fragment):
    if section in text:
        for line in body.strip().splitlines():
            key = line.split("=", 1)[0].strip()
            if not key or key.startswith("#"):
                continue
            pattern = rf"^{re.escape(key)}\s*=.*$"
            if re.search(pattern, text, flags=re.M):
                text = re.sub(pattern, line.strip(), text, count=1, flags=re.M)
            elif section in text:
                text = re.sub(
                    rf"({re.escape(section)}\n)",
                    rf"\1{line.strip()}\n",
                    text,
                    count=1,
                )
    else:
        if text and not text.endswith("\n"):
            text += "\n"
        text += f"\n{section}\n{body.strip()}\n"

target.write_text(text)
print(f"warp: merged p10k settings into {target}")
PY
fi

echo "bootstrap: done"
