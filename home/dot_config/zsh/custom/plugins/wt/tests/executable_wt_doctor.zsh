#!/usr/bin/env zsh
set -euo pipefail

cd "${0:A:h}/.."
plugin="${PWD}/wt.plugin.zsh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

fake_bin="$tmpdir/bin"
mkdir -p "$fake_bin"

write_wt_git() {
  local wt_path="$1"
  local repo="$2"

  print -r -- "gitdir: ${repo:A}" > "$wt_path/.git"
}

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
  write_wt_git "$wt_path" "$repo"
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

cat > "$fake_bin/apfel" <<'EOF'
#!/usr/bin/env zsh
[[ "$1" == "--stream" ]] || exit 2
print -r -- "apfel-suggestion:$2"
EOF
chmod +x "$fake_bin/apfel"

base="$tmpdir/worktrees"
root_one="$base/group-one"
root_two="$base/nested/group-two"
repo_one="$tmpdir/repos/repo-one"
repo_two="$tmpdir/repos/repo-two"
wt_one="$root_one/repo-one"
wt_two="$root_two/repo-two"

create_worktree "$repo_one" "$wt_one" "doctor-one"
create_worktree "$repo_two" "$wt_two" "doctor-two"

if ! output=$(PATH="$fake_bin:$PATH" bsl_wts="$base" zsh -fc "cd ${(q)wt_one}; source ${(q)plugin}; wt doctor" 2>&1); then
  print -u2 -- "$output"
  exit 1
fi
assert_contains "$output" "group-one"
assert_contains "$output" "group-one/repo-one"
[[ "$output" == *"group-one/repo-one"*"OK"* ]] || {
  print -u2 "expected group-one/repo-one to be OK"
  exit 1
}
assert_not_contains "$output" "NOT OK"
assert_not_contains "$output" "ORPHAN"
assert_not_contains "$output" "error ["

rm "$wt_one/.git"
if ! output=$(PATH="$fake_bin:$PATH" bsl_wts="$base" zsh -fc "cd ${(q)root_one}; source ${(q)plugin}; wt doctor --worktree-root ${(q)root_one}" 2>&1); then
  :
else
  print -u2 "expected failure when .git is missing"
  exit 1
fi
assert_contains "$output" "error [missing_git] group-one/repo-one"
[[ "$output" == *"group-one/repo-one"*"NOT OK"* ]] || {
  print -u2 "expected group-one/repo-one to be NOT OK"
  exit 1
}

rm -f "$wt_one/.git"
mkdir "$wt_one/.git"
if ! output=$(PATH="$fake_bin:$PATH" bsl_wts="$base" zsh -fc "cd ${(q)root_one}; source ${(q)plugin}; wt doctor --worktree-root ${(q)root_one}" 2>&1); then
  :
else
  print -u2 "expected failure when .git is a directory"
  exit 1
fi
assert_contains "$output" "error [gitdir_invalid]"
assert_contains "$output" ".git is a directory"

rm -rf "$wt_one/.git"
print -r -- "gitdir: /tmp/not-a-repo" > "$wt_one/.git"
if ! output=$(PATH="$fake_bin:$PATH" bsl_wts="$base" zsh -fc "cd ${(q)root_one}; source ${(q)plugin}; wt doctor" 2>&1); then
  :
else
  print -u2 "expected failure for invalid .git gitdir path"
  exit 1
fi
assert_contains "$output" "error [gitdir_invalid]"

write_wt_git "$wt_one" "$repo_one"
wt_orphan="$root_one/repo-orphan"
mkdir -p "$wt_orphan"
write_wt_git "$wt_orphan" "$repo_one"
if ! output=$(PATH="$fake_bin:$PATH" bsl_wts="$base" zsh -fc "cd ${(q)root_one}; source ${(q)plugin}; wt doctor" 2>&1); then
  :
else
  print -u2 "expected failure when repo does not know worktree"
  exit 1
fi
assert_contains "$output" "error [gitdir_worktree_unknown] group-one/repo-orphan"
[[ "$output" == *"group-one/repo-one"*"OK"* ]] || exit 1
[[ "$output" == *"group-one/repo-orphan"*"ORPHAN"* ]] || exit 1
assert_not_contains "$output" "error [gitdir_worktree_unknown] group-one/repo-one"

rm -rf "$wt_orphan"
if ! output=$(PATH="$fake_bin:$PATH" bsl_wts="$base" zsh -fc "cd ${(q)base}; source ${(q)plugin}; wt doctor --suggest" 2>&1); then
  print -u2 -- "$output"
  exit 1
fi
assert_contains "$output" "group-one"
assert_contains "$output" "nested/group-two"
[[ "$output" == *"group-one/repo-one"*"OK"* ]] || exit 1
[[ "$output" == *"group-two/repo-two"*"OK"* ]] || exit 1
assert_not_contains "$output" "NOT OK"
assert_not_contains "$output" "ORPHAN"
assert_not_contains "$output" "error ["
assert_not_contains "$output" "apfel-suggestion:"

rm "$wt_two/.git"
if ! output=$(PATH="$fake_bin:$PATH" bsl_wts="$base" zsh -fc "cd ${(q)base}/nested; source ${(q)plugin}; wt doctor --worktree-root ${(q)root_two} --suggest" 2>&1); then
  :
else
  print -u2 "expected failure for missing .git in scoped root"
  exit 1
fi
assert_contains "$output" "nested/group-two"
assert_not_contains "$output" "group-one"
assert_contains "$output" "error [missing_git] group-two/repo-two"
[[ "$output" == *"group-two/repo-two"*"NOT OK"* ]] || exit 1
assert_contains "$output" "suggest [missing_git] group-two/repo-two"
assert_contains "$output" "apfel-suggestion:"
