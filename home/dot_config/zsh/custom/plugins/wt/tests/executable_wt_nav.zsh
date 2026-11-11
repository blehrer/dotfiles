#!/usr/bin/env zsh
set -euo pipefail

cd "${0:A:h}/.."
plugin=./executable_wt.plugin.zsh

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src_root="$tmpdir/src"
wt_base="$tmpdir/wt"
mkdir -p "$src_root/acme/widget" "$wt_base/acme/widget/feat-a/subdir"

git -C "$src_root/acme/widget" init -q
git -C "$src_root/acme/widget" -c user.name='wt test' -c user.email='wt@test' commit --allow-empty -q -m init

gitdir_real="$src_root/acme/widget/.git/worktrees/feat-a"
mkdir -p "$gitdir_real"
print -r -- "gitdir: $gitdir_real" > "$wt_base/acme/widget/feat-a/.git"

# shellcheck disable=SC1091
source "$plugin"

bsl_repos="$src_root"
bsl_wts="$wt_base"

repos=("${(@f)$(_wt_list_src_repos)}")
(( ${#repos[@]} == 1 )) || { print -u2 "expected one src repo, got ${#repos[@]}"; exit 1; }
[[ "${repos[1]:t}" == widget ]] || { print -u2 "unexpected repo: ${repos[1]}"; exit 1; }

leaves=("${(@f)$(_wt_list_all_worktree_leaves)}")
(( ${#leaves[@]} == 1 )) || { print -u2 "expected one worktree leaf, got ${#leaves[@]}"; exit 1; }
[[ "${leaves[1]:t}" == feat-a ]] || { print -u2 "unexpected leaf: ${leaves[1]}"; exit 1; }

leaf_dir="${wt_base:A}/acme/widget/feat-a"
cd "$leaf_dir/subdir"
leaf=$(_wt_nearest_worktree_leaf)
[[ "${leaf:A}" == "${leaf_dir:A}" ]] || {
  print -u2 "expected nearest leaf, got: $leaf"
  exit 1
}

repo_git=$(_wt_repo_git_dir_for_worktree "$leaf")
[[ "${repo_git:A}" == "${src_root:A}/acme/widget/.git" ]] || {
  print -u2 "unexpected repo git dir: $repo_git"
  exit 1
}

cd "$leaf_dir"
_wt_nav_src
[[ "${PWD:A}" == "${src_root:A}/acme/widget" ]] || {
  print -u2 "wt src from leaf expected home repo, got: $PWD"
  exit 1
}

group_dir="${wt_base:A}/acme/widget"
mirror_src=$(_wt_mirror_src_home_for_wt_group "$group_dir")
[[ "${mirror_src:A}" == "${src_root:A}/acme/widget" ]] || {
  print -u2 "mirror src failed: $mirror_src"
  exit 1
}

cd "$group_dir"
_wt_nav_src
[[ "${PWD:A}" == "${src_root:A}/acme/widget" ]] || {
  print -u2 "wt src from wt group expected home repo, got: $PWD"
  exit 1
}

cd "${src_root:A}/acme/widget"
wt_group=$(_wt_wt_group_for_cwd)
[[ "${wt_group:A}" == "${group_dir:A}" ]] || {
  print -u2 "expected mirrored wt group from src home, got: $wt_group"
  exit 1
}

print 'wt nav: ok'
