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
text = target.read_text() if target.exists() else ""

def sections(src):
    found = []
    matches = list(re.finditer(r"^(\[[^\]]+\])\s*$", src, flags=re.M))
    for i, m in enumerate(matches):
        start = m.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(src)
        found.append((m.group(1), src[start:end]))
    return found

def upsert_key(block, key, value_line):
    pattern = rf"(?m)^[ \t]*{re.escape(key)}[ \t]*=.*$"
    if re.search(pattern, block):
        return re.sub(pattern, value_line, block, count=1)
    body = block.rstrip("\n")
    if body:
        return body + "\n" + value_line + "\n"
    return value_line + "\n"

for section, body in sections(fragment):
    kv_lines = []
    for line in body.splitlines():
        raw = line.strip()
        if not raw or raw.startswith("#"):
            continue
        if "=" not in raw:
            continue
        key = raw.split("=", 1)[0].strip()
        kv_lines.append((key, raw))
    if section in text:
        m = re.search(rf"(?m)^{re.escape(section)}\s*$", text)
        if not m:
            continue
        start = m.end()
        nxt = re.search(r"(?m)^\[[^\]]+\]\s*$", text[start:])
        end = start + nxt.start() if nxt else len(text)
        block = text[start:end]
        for key, value_line in kv_lines:
            block = upsert_key(block, key, value_line)
        if block and not block.endswith("\n"):
            block += "\n"
        text = text[:start] + block + text[end:]
    else:
        if text and not text.endswith("\n"):
            text += "\n"
        extra = "\n" + section + "\n"
        extra += "\n".join(line for _, line in kv_lines)
        extra += "\n"
        text += extra

target.write_text(text)
print(f"warp: merged p10k settings into {target}")
PY
fi

echo "bootstrap: done"
