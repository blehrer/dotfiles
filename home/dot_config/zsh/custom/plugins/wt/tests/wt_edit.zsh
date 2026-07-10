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

assert_removed() {
  local repo="$1"
  local wt_path="$2"

  if [[ -e "$wt_path" ]]; then
    print -u2 "worktree directory still exists: $wt_path"
    exit 1
  fi

  if [[ "$(git -C "$repo" worktree list --porcelain)" == *"worktree $wt_path"* ]]; then
    print -u2 "worktree is still registered: $wt_path"
    exit 1
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "$haystack" != *"$needle"* ]]; then
    print -u2 "missing expected text: $needle"
    return 1
  fi
}

repo="$tmpdir/repo"
wt_root="$tmpdir/worktrees"
wt_path="$wt_root/repo"
create_worktree "$repo" "$wt_path" "edit-test"

cat > "$fake_bin/fzf" <<EOF
#!/usr/bin/env zsh
print -r -- "$wt_path"
EOF
chmod +x "$fake_bin/fzf"

if ! output=$(PATH="$fake_bin:$PATH" zsh -fc "source ${(q)plugin}; wt edit --worktree-root ${(q)wt_root}" 2>&1); then
  print -u2 -- "$output"
  exit 1
fi
assert_contains "$output" "Removing ["
assert_contains "$output" "removed: ${wt_path:A}"
assert_removed "$repo" "$wt_path"

repo2="$tmpdir/repo2"
wt_base2="$tmpdir/base2"
wt_root2="$wt_base2/group"
wt_path2="$wt_root2/repo2"
count_file="$tmpdir/fzf-count"
create_worktree "$repo2" "$wt_path2" "edit-test-2"

cat > "$fake_bin/fzf" <<EOF
#!/usr/bin/env zsh
count=0
[[ -f "$count_file" ]] && count=\$(< "$count_file")
(( count++ ))
print -r -- "\$count" > "$count_file"
if (( count == 1 )); then
  print -r -- "$wt_root2"
else
  print -r -- "$wt_path2"
fi
EOF
chmod +x "$fake_bin/fzf"

if ! output=$(PATH="$fake_bin:$PATH" bsl_wts="$wt_base2" zsh -fc "cd ${(q)tmpdir}; source ${(q)plugin}; wt edit" 2>&1); then
  print -u2 -- "$output"
  exit 1
fi
assert_contains "$output" "Removing ["
assert_contains "$output" "removed: ${wt_path2:A}"
assert_removed "$repo2" "$wt_path2"
