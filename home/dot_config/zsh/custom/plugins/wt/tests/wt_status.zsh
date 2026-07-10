#!/usr/bin/env zsh
set -euo pipefail

cd "${0:A:h}/.."
plugin="${PWD}/wt.plugin.zsh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

fake_bin="$tmpdir/bin"
mkdir -p "$fake_bin"

create_worktree() {
  local repo="$1"
  local wt_path="$2"
  local branch="$3"

  mkdir -p "$repo" "${wt_path:h}"
  git -C "$repo" init -q
  print "hello" > "$repo/README.md"
  git -C "$repo" add README.md
  GIT_AUTHOR_NAME="wt test" GIT_AUTHOR_EMAIL="wt@example.invalid" \
  GIT_COMMITTER_NAME="wt test" GIT_COMMITTER_EMAIL="wt@example.invalid" \
    git -C "$repo" commit -q -m "initial"
  git -C "$repo" worktree add -q -b "$branch" "$wt_path" HEAD
}

assert_contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "$haystack" != *"$needle"* ]]; then
    print -u2 "missing expected text: $needle"
    print -u2 -- "$haystack"
    return 1
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "$haystack" == *"$needle"* ]]; then
    print -u2 "unexpected text: $needle"
    print -u2 -- "$haystack"
    return 1
  fi
}

cat > "$fake_bin/starship" <<'EOF'
#!/usr/bin/env zsh
[[ "$1" == "prompt" ]] || exit 2
print -rn -- "%{"
printf '\033[31m'
print -rn -- "%}prompt:${PWD:t}%{"
printf '\033[0m'
print -r -- "%}"
print -r -- "❯"
EOF
chmod +x "$fake_bin/starship"

base="$tmpdir/worktrees"
root_one="$base/group-one"
root_two="$base/nested/group-two"
repo_one="$tmpdir/repos/repo-one"
repo_two="$tmpdir/repos/repo-two"
wt_one="$root_one/repo-one"
wt_two="$root_two/repo-two"

create_worktree "$repo_one" "$wt_one" "status-one"
create_worktree "$repo_two" "$wt_two" "status-two"
mkdir -p "$wt_one/deep/fake-worktree"
print -r -- "gitdir: /tmp/not-real" > "$wt_one/deep/fake-worktree/.git"

root_one_abs="${root_one:A}"
root_two_abs="${root_two:A}"
wt_one_abs="${wt_one:A}"
wt_two_abs="${wt_two:A}"

if ! output=$(PATH="$fake_bin:$PATH" bsl_wts="$base" zsh -fc "cd ${(q)wt_one}; source ${(q)plugin}; wt status" 2>&1); then
  print -u2 -- "$output"
  exit 1
fi
assert_contains "$output" "group-one"
assert_contains "$output" "prompt:repo-one"
assert_contains "$output" $'\n  \033[31mprompt:repo-one'
assert_contains "$output" $'\n  ❯'
assert_not_contains "$output" "+--"
assert_not_contains "$output" "|"
assert_not_contains "$output" $'\n  repo-one\n'
assert_not_contains "$output" "$root_one_abs"
assert_not_contains "$output" "$wt_one_abs"
assert_not_contains "$output" "$'\\n"
assert_not_contains "$output" "%{"
assert_not_contains "$output" "%}"

if ! output=$(PATH="$fake_bin:$PATH" bsl_wts="$base" zsh -fc "cd ${(q)base}; source ${(q)plugin}; wt status" 2>&1); then
  print -u2 -- "$output"
  exit 1
fi
assert_contains "$output" "group-one"
assert_contains "$output" "prompt:repo-one"
assert_contains "$output" $'\n\n\nnested/group-two'
assert_contains "$output" "prompt:repo-two"
assert_contains "$output" $'\n  \033[31mprompt:repo-one'
assert_contains "$output" $'\n  \033[31mprompt:repo-two'
assert_contains "$output" $'\n  ❯'
assert_not_contains "$output" "+--"
assert_not_contains "$output" "|"
assert_not_contains "$output" $'\n  repo-one\n'
assert_not_contains "$output" $'\n  repo-two\n'
assert_not_contains "$output" "$root_one_abs"
assert_not_contains "$output" "$wt_one_abs"
assert_not_contains "$output" "$root_two_abs"
assert_not_contains "$output" "$wt_two_abs"
assert_not_contains "$output" "group-one/repo-one/deep"
assert_not_contains "$output" "$'\\n"
assert_not_contains "$output" "%{"
assert_not_contains "$output" "%}"

if ! output=$(PATH="$fake_bin:$PATH" bsl_wts="$base" zsh -fc "cd ${(q)base}/nested; source ${(q)plugin}; wt status" 2>&1); then
  print -u2 -- "$output"
  exit 1
fi
assert_contains "$output" "nested/group-two"
assert_contains "$output" "prompt:repo-two"
assert_not_contains "$output" "group-one"
assert_not_contains "$output" "+--"
assert_not_contains "$output" "|"
