#!/usr/bin/env bash
# Resolve (or create) a linked worktree path for branch work on a registered repo.
set -euo pipefail

# Cursor/agent shells sometimes override $HOME to the workspace; use passwd db.
USER_HOME="$(python3 -c 'import os, pwd; print(pwd.getpwuid(os.getuid()).pw_dir)')"
REGISTRY="${REGISTRY:-$USER_HOME/.cursor/wt-registry/registry.yaml}"
REPO_BASENAME="${1:?usage: resolve-implementation-checkout.sh <repo-basename> <branch> [leaf-name]}"
BRANCH="${2:?usage: resolve-implementation-checkout.sh <repo-basename> <branch> [leaf-name]}"
LEAF_NAME="${3:-$BRANCH}"

registry_paths="$(python3 - "$REGISTRY" "$REPO_BASENAME" <<'PY'
import re, sys
from pathlib import Path
reg, repo = sys.argv[1], sys.argv[2]
text = Path(reg).read_text()
for block in re.split(r"\n(?=  \S)", text):
    if not re.search(rf"^\s+repo:\s+{re.escape(repo)}\s*$", block, re.M):
        continue
    home = re.search(r"^\s+home:\s+(\S+)\s*$", block, re.M)
    wt = re.search(r"^\s+wt_group:\s+(\S+)\s*$", block, re.M)
    if home and wt:
        print(home.group(1))
        print(wt.group(1))
        break
else:
    sys.exit(1)
PY
)" || {
  echo "resolve-implementation-checkout: no registry entry for repo=$REPO_BASENAME" >&2
  exit 1
}

HOME_PATH="$(printf '%s\n' "$registry_paths" | sed -n '1p')"
WT_GROUP="$(printf '%s\n' "$registry_paths" | sed -n '2p')"

git -C "$HOME_PATH" rev-parse --is-inside-work-tree &>/dev/null || {
  echo "resolve-implementation-checkout: home missing or not git: $HOME_PATH" >&2
  exit 1
}

while IFS= read -r line; do
  [[ "$line" == *"[$BRANCH]"* ]] || continue
  existing="${line%% *}"
  if [[ -d "$existing" ]]; then
    echo "$existing"
    exit 0
  fi
done < <(git -C "$HOME_PATH" worktree list)

if ! git -C "$HOME_PATH" show-ref --verify --quiet "refs/heads/$BRANCH"; then
  if git -C "$HOME_PATH" show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
    git -C "$HOME_PATH" branch -f "$BRANCH" "origin/$BRANCH"
  else
    echo "resolve-implementation-checkout: branch $BRANCH not on home or origin" >&2
    exit 1
  fi
fi

mkdir -p "$WT_GROUP"
TARGET="$WT_GROUP/$LEAF_NAME"
n=2
while [[ -e "$TARGET" ]]; do
  TARGET="$WT_GROUP/${LEAF_NAME}-${n}"
  ((n++))
done

git -C "$HOME_PATH" worktree add "$TARGET" "$BRANCH"
echo "$TARGET"
