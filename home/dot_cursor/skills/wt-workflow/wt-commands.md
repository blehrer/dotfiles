# wt plugin — actual commands

Source of truth: `~/.config/zsh/custom/plugins/wt/wt.plugin.zsh`.

Agents emit these commands for **you to run in zsh** (interactive flags + fzf). Do not invent subcommands that are not listed here.

## Layout defaults (in `wt.plugin.zsh`)

At plugin load:

```zsh
: ${bsl_repos:=$HOME/src}
: ${bsl_wts:=$HOME/wt}
```

No `export` in `~/.zshrc` required. Override `bsl_repos` / `bsl_wts` only when experimenting.

Apply once on an existing plugin copy:

```bash
~/.cursor/wt-registry/apply-wt-defaults.sh
```

## Filesystem layout

```text
~/src/<gitlab_path>/         # canonical home (never delete)
~/wt/<gitlab_path>/          # worktree **group root** (directory of siblings)
~/wt/<gitlab_path>/<name>/   # one linked worktree (child has .git file)
```

The plugin discovers **group roots** under `bsl_wts` (any depth ≤8) whose immediate children are worktrees.

Registry field `wt_group` = `~/wt/<gitlab_path>` (the group root, not a leaf checkout).

## Implemented subcommands

### Bare `wt`

fzf-pick a worktree **leaf** → `cd` into that checkout.

| Where you are | Behavior |
|---------------|----------|
| **Src home** with mirrored `~/wt/<same/gitlab_path>/` (registry or path mirror) | fzf that group’s leaves only |
| Inside a **wt group** (not a leaf) | fzf that group’s leaves only |
| **Wt leaf**, or nowhere with a matched group | fzf **all** leaves under `bsl_wts` |

```zsh
wt
```

### `wt src`

Jump to a canonical home repo under `bsl_repos`.

| Where you are | Behavior |
|---------------|----------|
| Under **`bsl_wts`** with mirrored home repo (leaf gitdir or `~/wt/...` group path) | `cd` to `~/src/...` mirror (no fzf) |
| Already in a **src home** checkout | fzf all repos under `bsl_repos` |
| Anywhere else | fzf all repos under `bsl_repos` |

```zsh
wt src
```

### `wt init` (alias `mkwt`)

Create one or more worktrees into a group directory (interactive fzf unless flags provided).

```zsh
wt init \
  --src-root "$HOME/src" \
  --worktree-root "$HOME/wt/acme/widget" \
  --branch BRANCH_NAME \
  --ref main \
  --repos repo-basename
```

**Existing local branch** (typical after branch import onto home): use `--branch` only; plugin runs `git worktree add PATH BRANCH` (no `-b`). Use `--new-branch` to force `-b`.

**Non-interactive** (agents, scripts): require `--worktree-root`, `--branch`, and usually `--name` + `--repos`. Optional `--yes` skips “add to existing group?” confirm. Example:

```zsh
wt init --yes \
  --worktree-root "$HOME/wt/acme/team/widget" \
  --branch feature/foo \
  --name feature-foo \
  --repos widget
```

Omit `--repos` for fzf multi-select under `src-root`. Omit `--branch` for detached worktree (interactive only). With `--worktree-root` set, skips the directory `vared` prompt; with `--name` / `--leaf`, skips the leaf name prompt.

Interactive leaf name: `Worktree name for 'repo':` prompt (defaults to repo basename; use branch slug when basename would collide).

### `wt rm` / `wt edit` / `wt remove`

fzf **multi-select** worktrees under a group; optional repo-memory archive; then `git worktree remove` + `rm -rf` if the directory still exists. **`rm` is the primary name; `edit` and `remove` are aliases.**

```zsh
wt rm --archive --worktree-root "$HOME/wt/acme/widget"
wt rm --worktree-root "$HOME/wt/acme/widget"          # interactive archive prompt
wt rm --skip-archive --worktree-root "$HOME/wt/acme/widget"   # scripts / already ingested
```

**Archive (`~/.cursor`):** The plugin calls `~/.cursor/memory/bin/ingest-transcript.sh` per selected leaf when archiving.

| Mode | Behavior |
|------|----------|
| (default, interactive) | Prompt `[Y/n]` to archive when ingest script exists |
| `--archive` | Archive each leaf before remove (fails if script missing) |
| `--skip-archive` | No archive (non-interactive default) |

Agents still run **ARCHIVE_CHECK** in `fsa.md`. When emitting commands for you, prefer `wt rm --archive`; use `--skip-archive` only after explicit ingest or waive.

### `wt status`

Starship prompt lines per worktree under group root(s).

```zsh
wt status
wt status --worktree-root "$HOME/wt/acme/widget"
```

### `wt doctor`

.git gitdir health; optional `apfel --stream` suggestions.

```zsh
wt doctor --worktree-root "$HOME/wt/acme/widget"
wt doctor --suggest
```

### `wt mv` / `wt move`

Relocate an entire worktree group (interactive fzf).

### `wt completion`

Print zsh completion definition.

## Registry (no wt subcommand)

`~/.cursor/wt-registry/registry.yaml` is updated by the **agent** after REGISTER elicitation, not by the plugin today.

Example entry:

```yaml
github-com-acme-widget:
  origin: git@github.com:acme/widget.git
  gitlab_path: acme/widget
  org: acme
  repo: widget
  home: /Users/jesse/src/acme/widget
  wt_group: /Users/jesse/wt/acme/widget
  default_branch: main
```

Nested path: `gitlab_path: acme/team/widget` → home `~/src/acme/team/widget`. See `layout.md` and `layout-from-origin.py`.

## FSA → command mapping

| Intent | Human runs |
|--------|------------|
| `NEW_WORKTREE` | `wt init` with `--worktree-root`, `--branch`, `--repos` (or interactive) |
| `REMOVE_WORKTREE` | `wt rm --archive --worktree-root …` (or `--skip-archive` after ingest) |
| `LIST` | `wt status` |
| `HEALTH` | `wt doctor` |
| `JUMP_LEAF` | bare `wt` (global fzf, or scoped in registry home) |
| `OPEN_HOME` | `wt src` (global fzf, or direct from a wt leaf) |
| `INIT_HOME` | agent: clone + `registry.yaml` |
| `REGISTER` | agent edits `registry.yaml` |

## Gaps (future plugin; agents must not use raw git)

| Desired | Today |
|---------|--------|
| `wt register` → registry.yaml | Agent writes YAML |
| Non-interactive add one leaf to existing group | Use `wt init` into existing `wt_group` or add `wt add` later |
| Print home path | Read `registry.yaml` `home` |

## Agent output templates

```zsh
# wt-workflow: NEW_WORKTREE (acme/widget)
wt init \
  --worktree-root "$HOME/wt/acme/widget" \
  --branch fix-auth-timeout \
  --ref main \
  --repos widget
# When prompted for worktree name, use: widget  (or your slug preference)
```

```zsh
# wt-workflow: REMOVE_WORKTREE
wt rm --archive --worktree-root "$HOME/wt/acme/widget"
# If chats already ingested this session:
# wt rm --skip-archive --worktree-root "$HOME/wt/acme/widget"
```
