# wt.plugin.zsh ↔ Cursor workflow

## Chezmoi (dotfiles boundary)

- `chezmoi add` runs with **autocommit** and **autopush** on this machine — anything you add can land on GitHub immediately.
- **`registry.yaml` is chezmoiignored** — employer `repos:` entries stay in `~/.cursor/wt-registry/registry.yaml` only; never `chezmoi add` that file after populating it.
- After rewriting dotfiles history, update the remote with `git push --force-with-lease` from the chezmoi source dir (bad commits are not removed from GitHub until then).

## Layout defaults

| Path role | Default |
|-----------|---------|
| Source repos (`bsl_repos`) | `$HOME/src` |
| Worktree base (`bsl_wts`) | `$HOME/wt` |

Set at top of `wt.plugin.zsh` (after shebang):

```zsh
: ${bsl_repos:=$HOME/src}
: ${bsl_wts:=$HOME/wt}
```

One-shot patch on an old plugin copy (if defaults are missing):

```bash
~/.cursor/wt-registry/apply-wt-defaults.sh \
  ~/.config/zsh/custom/plugins/wt/wt.plugin.zsh
```

## Command cheat sheet

| Goal | Command |
|------|---------|
| Create worktree(s) | `wt init` / `mkwt` |
| Remove worktree(s) | `wt edit` (fzf multi) |
| Show branches/prompts | `wt status` |
| Repair .git gitdir | `wt doctor [--suggest]` |
| cd into a group | bare `wt` |
| Move whole group | `wt mv` |

## Nested groups

Group root = directory whose **immediate children** are worktrees (`.git` file each). Discovery: scan under `$bsl_wts` up to depth 8 (`gitlab_path_mirror` paths).

Example:

- Home: `~/src/acme/widget`
- Group: `~/wt/acme/widget/`
- Leaves: `~/wt/acme/widget/<name>/`

## Cursor agent boundaries

- **init / edit / doctor** run git inside the plugin — **you** run them, not the agent.
- **registry.yaml** is agent-maintained until a `wt register` exists.
- **Before `wt edit`:** `~/.cursor/memory/bin/ingest-transcript.sh` from each leaf being removed.

## Optional future plugin additions

1. `wt register` — write `registry.yaml`
2. `wt add` — single leaf into existing group
3. `wt home` — print canonical path for cwd repo
