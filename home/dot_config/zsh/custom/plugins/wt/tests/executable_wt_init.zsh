#!/usr/bin/env zsh
set -euo pipefail

cd "${0:A:h}/.."
[[ -f wt.plugin.zsh ]] || ln -sf executable_wt.plugin.zsh wt.plugin.zsh

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

git -C "$tmpdir" init -q
git -C "$tmpdir" -c user.name='wt test' -c user.email='wt@test' commit --allow-empty -q -m init
git -C "$tmpdir" branch feature/wt-init-test

wtg="$tmpdir/wt-group"
mkdir -p "$wtg"
leaf="$wtg/leaf-a"

# shellcheck disable=SC1091
source ./wt.plugin.zsh

_wt_git_worktree_add "$tmpdir" "$leaf" feature/wt-init-test "" 0
[[ -f "$leaf/.git" ]] || { print -u2 'expected worktree .git file'; exit 1 }

dup="$wtg/leaf-b"
if _wt_git_worktree_add "$tmpdir" "$dup" feature/wt-init-test "" 0; then
  print -u2 'expected failure when branch already checked out'
  exit 1
fi

newleaf="$wtg/brand-new"
_wt_git_worktree_add "$tmpdir" "$newleaf" brand-new-branch "" 0
git -C "$tmpdir" show-ref --verify --quiet refs/heads/brand-new-branch

print 'wt init logic: ok'
