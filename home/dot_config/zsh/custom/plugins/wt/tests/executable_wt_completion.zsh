#!/usr/bin/env zsh
set -euo pipefail

cd "${0:A:h}/.."

assert_contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "$haystack" != *"$needle"* ]]; then
    print -u2 "missing expected text: $needle"
    return 1
  fi
}

if ! output=$(zsh -fc 'source ./wt.plugin.zsh; wt completion' 2>&1); then
  print -u2 "wt completion failed"
  print -u2 -- "$output"
  exit 1
fi

assert_contains "$output" "#compdef wt mkwt"
assert_contains "$output" "compdef _wt_completion wt mkwt"
assert_contains "$output" "init:Create a new worktree group"
assert_contains "$output" "edit:Remove selected worktrees"
assert_contains "$output" "status:Show Starship prompts for worktrees"
assert_contains "$output" "doctor:Check worktrees and suggest fixes"
assert_contains "$output" "completion:Print zsh completion script"
assert_contains "$output" "--src-root[Source repo root]"

if ! help_output=$(zsh -fc 'source ./wt.plugin.zsh; wt --help' 2>&1); then
  print -u2 "wt help failed"
  print -u2 -- "$help_output"
  exit 1
fi

assert_contains "$help_output" "Usage: wt [init|edit|status|doctor|mv|move|completion] [-h|--help]"
assert_contains "$help_output" "edit       remove selected worktrees from a worktree group"
assert_contains "$help_output" "status     show Starship prompts for worktrees"
assert_contains "$help_output" "doctor     check .git gitdir health and suggest fixes"

if ! helper_source=$(zsh -fc 'source ./wt.plugin.zsh; typeset -f _wt_vared_directory' 2>&1); then
  print -u2 "failed to load _wt_vared_directory"
  print -u2 -- "$helper_source"
  exit 1
fi

if ! complete_source=$(zsh -fc 'source ./wt.plugin.zsh; typeset -f _wt_directory_complete_word' 2>&1); then
  print -u2 "failed to load _wt_directory_complete_word"
  print -u2 -- "$complete_source"
  exit 1
fi

if ! fzf_source=$(zsh -fc 'source ./wt.plugin.zsh; typeset -f _wt_fzf_pick_lines' 2>&1); then
  print -u2 "failed to load _wt_fzf_pick_lines"
  print -u2 -- "$fzf_source"
  exit 1
fi

assert_contains "$fzf_source" 'commands[fzf]'
assert_contains "$fzf_source" "--height '~12'"
assert_contains "$fzf_source" '--layout reverse'

if ! match_source=$(zsh -fc 'source ./wt.plugin.zsh; typeset -f _wt_directory_match_prefix' 2>&1); then
  print -u2 "failed to load _wt_directory_match_prefix"
  print -u2 -- "$match_source"
  exit 1
fi

assert_contains "$complete_source" "_wt_directory_match_prefix"
assert_contains "$match_source" '[[ -d "$entry" ]]'
assert_contains "$helper_source" "bindkey -D"

path_prompt_count=$(grep -c '_wt_vared_directory "Worktree root: " wt_dir' wt.plugin.zsh)
(( path_prompt_count == 1 )) || {
  print -u2 "expected wt init to use directory prompt helper, got $path_prompt_count"
  exit 1
}

assert_contains "$(grep -n '_wt_pick_worktree_root' wt.plugin.zsh)" 'Select worktree group'

move_prompt_count=$(grep -c '_wt_vared_directory "Move to: " dest' wt.plugin.zsh)
(( move_prompt_count == 2 )) || {
  print -u2 "expected both wt mv destination prompts to use directory prompt helper, got $move_prompt_count"
  exit 1
}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/child-dir" "$tmpdir/other-dir"
print "file" > "$tmpdir/child-file"

source ./wt.plugin.zsh
_wt_directory_match_prefix "$tmpdir/" ""
matches=("${reply[@]}")
(( ${#matches[@]} == 2 )) || {
  print -u2 "expected two directory matches, got ${#matches[@]}"
  exit 1
}
for match in "${matches[@]}"; do
  [[ -d "$match" ]] || {
    print -u2 "match is not a directory: $match"
    exit 1
  }
  [[ "$match" == *child-file* ]] && {
    print -u2 "directory-only matches must exclude regular files"
    exit 1
  }
done

_wt_directory_match_prefix "$tmpdir/" "child"
matches=("${reply[@]}")
(( ${#matches[@]} == 1 )) || {
  print -u2 "expected one prefixed directory match, got ${#matches[@]}"
  exit 1
}
[[ "${matches[1]:t}" == child-dir ]] || {
  print -u2 "expected child-dir match, got ${matches[1]}"
  exit 1
}

nested_base="$tmpdir/nested-base"
nested_parent="$nested_base/container"
nested_root="$nested_parent/group-a"
mkdir -p "$nested_root/wt-child"
print -r -- "gitdir: /tmp/not-a-real-gitdir" > "$nested_root/wt-child/.git"
mkdir -p "$nested_base/container/group-b/other"
print -r -- "gitdir: /tmp/not-a-real-gitdir" > "$nested_base/container/group-b/other/.git"

_wt_nested_worktree_group_roots "$nested_base"
(( ${#reply[@]} == 2 )) || {
  print -u2 "expected two nested worktree group roots, got ${#reply[@]}"
  exit 1
}
[[ "${reply[1]:t}" == group-a ]] || {
  print -u2 "expected group-a in nested roots, got ${reply[1]}"
  exit 1
}
[[ "${reply[2]:t}" == group-b ]] || {
  print -u2 "expected group-b in nested roots, got ${reply[2]}"
  exit 1
}
