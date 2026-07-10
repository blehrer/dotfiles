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
assert_contains "$output" "completion:Print zsh completion script"
assert_contains "$output" "--src-root[Source repo root]"

if ! help_output=$(zsh -fc 'source ./wt.plugin.zsh; wt --help' 2>&1); then
  print -u2 "wt help failed"
  print -u2 -- "$help_output"
  exit 1
fi

assert_contains "$help_output" "Usage: wt [init|edit|status|mv|move|completion] [-h|--help]"
assert_contains "$help_output" "edit       remove selected worktrees from a worktree group"
assert_contains "$help_output" "status     show Starship prompts for worktrees"
