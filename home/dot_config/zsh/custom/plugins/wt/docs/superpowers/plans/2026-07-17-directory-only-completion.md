# Directory-only completion implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Exclude regular files from every interactive path completion prompt.

**Architecture:** A small wrapper creates a temporary ZLE keymap whose Tab widget calls zsh's `_directories` completer. It runs `vared`, then removes the widget and keymap so normal shell completion is unchanged.

**Tech Stack:** zsh, ZLE, zsh completion system, `zsh/zpty` integration test

## Global constraints

* Apply directory-only completion to the bare `wt`, `wt init`, and `wt mv` path prompts.
* Keep free-form worktree-name and branch-name prompts unchanged.
* Add no dependency.
* Restore completion state after success or failure.

---

### Task 1: Scope interactive path completion

**Files:**
* Modify: `wt.plugin.zsh`
* Test: `tests/wt_completion.zsh`

**Interfaces:**
* Produces: `_wt_vared_directory PROMPT PARAMETER`, which edits the named scalar parameter and returns the `vared` status.

- [ ] **Step 1: Write the failing integration test**

In `tests/wt_completion.zsh`, create a fixture with `child-dir` and `child-file`, start an interactive `zsh -f` through `zsh/zpty`, initialize completion, and invoke `_wt_vared_directory`. Send Tab and Enter, then require the single directory candidate to complete:

```zsh
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/child-dir"
print "file" > "$tmpdir/child-file"

zmodload zsh/zpty
zpty wt-directory zsh -f
zpty -w wt-directory "autoload -Uz compinit; compinit -d ${(q)tmpdir}/zcompdump"$'\n'
zpty -w wt-directory "source ${(q)PWD}/wt.plugin.zsh"$'\n'
zpty -w wt-directory "value=${(q)tmpdir}/; _wt_vared_directory 'Path: ' value; print -r -- RESULT:\$value"$'\n'
zpty -w wt-directory $'\t\n'
zpty -r wt-directory completion_output '*RESULT:*'
zpty -d wt-directory
assert_contains "$completion_output" "RESULT:$tmpdir/child-dir/"
```

- [ ] **Step 2: Run the test and verify it fails**

Run:

```sh
zsh tests/wt_completion.zsh
```

Expected: failure because `_wt_vared_directory` does not exist.

- [ ] **Step 3: Add the scoped directory prompt helper**

Add this function before the command implementations in `wt.plugin.zsh`:

```zsh
_wt_vared_directory() {
  local prompt="$1"
  local parameter="$2"
  local keymap="wt-directory-${$}-${RANDOM}"
  local widget="_wt-directory-complete-${$}-${RANDOM}"
  local rc

  autoload -Uz _directories
  zle -C "$widget" complete-word _directories
  bindkey -N "$keymap" main
  bindkey -M "$keymap" '^I' "$widget"

  if vared -M "$keymap" -p "$prompt" "$parameter"; then
    rc=0
  else
    rc=$?
  fi

  bindkey -D "$keymap"
  zle -D "$widget"
  return $rc
}
```

- [ ] **Step 4: Route every interactive path prompt through the helper**

Replace only these four path-prompt calls:

```zsh
_wt_vared_directory "Move to: " dest
_wt_vared_directory "Move to: " dest
_wt_vared_directory "Worktree root: " wt_dir
_wt_vared_directory "Worktree root: " wt_dir
```

Leave the worktree-name and starting-ref `vared` calls unchanged.

- [ ] **Step 5: Run all checks**

Run:

```sh
for test_file in tests/*.zsh; do zsh "$test_file" || exit; done
```

Expected: all test scripts exit with status 0.

This directory is not a Git repository, so there is no commit step.
