---
name: wt-workflow
description: Use when creating, listing, opening, or removing worktrees under ~/wt, registering a canonical repo home, or when git worktree maintenance would otherwise be done by the agent
---

# wt-workflow

## Overview

Git worktree filesystem work uses the **wt** zsh plugin (`~/.config/zsh/custom/plugins/wt/wt.plugin.zsh`) and registry paths in `~/.cursor/wt-registry/registry.yaml`.

Read `@fsa.md`, `@layout.md`, and `@wt-commands.md`. **Plugin facts:** subcommands are `init`, `edit`, `status`, `doctor`, `mv`. Defaults: `bsl_repos=$HOME/src`, `bsl_wts=$HOME/wt`.

## Two modes (pick from user intent)

### A — Implementation checkout (default for MR / branch work)

User names a **repo + branch** (or MR on a known branch). **Do not** tell them to open a wt leaf first.

1. Run `~/.cursor/wt-registry/resolve-implementation-checkout.sh <repo-basename> <branch> [leaf-name]`.
2. Use the printed absolute path as `cwd` for git, npm, and file edits (even if Cursor workspace is a multi-repo parent folder or home).
3. If creation failed, fall back to `wt init --yes` per `wt-commands.md` (existing local branch).

**Removal** of worktrees stays human-driven (`wt edit`) unless the user explicitly asks.

### B — Planning / layout FSA (no branch assigned yet)

**Announce:** "Using wt-workflow: I'll ask for the next FSA input and give you `wt` commands to run."

Elicit → validate → emit **copy-pasteable** commands → wait for `ok`. Many flows are interactive (fzf, vared). The agent does **not** run `wt edit` or delete leaves without explicit ask.

## Step 0: Resolve repo context

From the current workspace (if any):

```bash
git rev-parse --show-toplevel 2>/dev/null
git remote get-url origin 2>/dev/null
git branch --show-current 2>/dev/null
```

Load `~/.cursor/wt-registry/registry.yaml`. If `origin` matches a registered repo, you have **HAVE_REGISTRY**. Else → **REGISTER** in `fsa.md`.

If there is no git repo in the workspace, ask: *"Which repo (origin URL or registered name)?"*

## Step 1: Classify intent (one question)

| If you want… | FSA intent |
|-----------------|------------|
| New parallel branch / worktree | `NEW_WORKTREE` |
| Tear down finished worktrees | `REMOVE_WORKTREE` |
| See what's checked out | `LIST` (`wt status`) |
| Fresh machine: clone home(s) + registry | `INIT_HOME` (`INIT` in fsa) |
| Register home + wt group (already cloned) | `REGISTER` |
| Jump to canonical home | `OPEN_HOME` |
| Check .git gitdir health | `HEALTH` |

## Step 2: Elicit slots (per intent)

Path policy **`gitlab_path_mirror`** (see `layout.md`):

- `home` = `~/src/<gitlab_path>/`, `wt_group` = `~/wt/<gitlab_path>/`
- `repo` = project basename for `wt init --repos` (plugin finds `…/<repo>` under `~/src`)

Derive slots: `python3 ~/.cursor/wt-registry/layout-from-origin.py '<origin>'`

**INIT_HOME:** agent may `git clone` + write `registry.yaml`; you still run `wt` for worktrees.

For `NEW_WORKTREE`, read `home` / `wt_group` from registry; `--repos` = registry `repo`.

## Step 3: Emit wt commands

Single fenced `zsh` block (no `export` lines unless you use non-default paths).

After commands, say: *"Run in zsh; tell me `ok` or paste the error. Note any fzf/vared answers you chose."*

## Step 4: Post-success hooks

On `ok`:

1. **repo-memory**: after `wt edit` (remove), confirm archive ran; after `wt init`, optional ingest when closing the worktree later.
2. Update **local** `~/.cursor/wt-registry/registry.yaml` in **INIT_HOME** / **REGISTER** — not chezmoi/dotfiles.

## When NOT to use

- You explicitly asked for a raw git one-liner.
- Already in the right worktree and only coding.

## Common mistakes

| Mistake | Fix |
|---------|-----|
| `wt new` / `wt rm` | Use `wt init` / `wt edit` |
| Leaf path without group | Group is `wt_group`; leaves are siblings inside it |
| Old plugin default `~/src/worktrees` | Run `apply-wt-defaults.sh` on `wt.plugin.zsh` |
| `wt edit` without archive | ARCHIVE_CHECK in `fsa.md` |

## Quick reference

| State | Agent action |
|-------|----------------|
| `NEW_WORKTREE` | `wt init --worktree-root … --branch … --repos …` |
| `REMOVE_WORKTREE` | archive → `wt edit --worktree-root …` |
| `LIST` | `wt status` |
| `HEALTH` | `wt doctor` |
| `OPEN_HOME` | `cd` to registry `home` |
| `INIT_HOME` | layout script → clone → `registry.yaml` |
