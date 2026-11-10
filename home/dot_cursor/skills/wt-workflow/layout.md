# Path resolution (registry + nested GitLab)

Under `~/src` and `~/wt`, directory structure **mirrors the host project path** (`gitlab_path`).

| Field | Meaning |
|-------|---------|
| `gitlab_path` | Full project path on the host (e.g. `acme/team/widget`) |
| `org` | First path segment (metadata / grouping) |
| `repo` | Last path segment (project name; `wt init --repos` basename) |
| `home` | `~/src/<gitlab_path>/` canonical checkout (absolute in registry) |
| `wt_group` | `~/wt/<gitlab_path>/` worktree **group root** |
| Leaf | `~/wt/<gitlab_path>/<worktree-name>/` |

## Default policy (`layout_policy: gitlab_path_mirror`)

- **home** = `~/src/{gitlab_path}`
- **wt_group** = `~/wt/{gitlab_path}`
- Shallow remotes (`acme/widget`) → `~/src/acme/widget`

## Derive paths (agent + human)

```bash
python3 ~/.cursor/wt-registry/layout-from-origin.py "git@github.com:acme/team/widget.git"
```

## Resolve at runtime

1. Match `origin` against `registry.yaml` → use stored `home` / `wt_group`.
2. Unknown origin → layout script → **INIT_HOME** → write **local** `registry.yaml` only (never dotfiles).
3. Do not invent paths outside the registry once registered.

## Nested groups + project wikis

Multi-segment paths mirror as directories, e.g. `acme/team/widget` → `~/src/acme/team/widget`.

GitLab **project wikis** (`*.wiki.git`) use the same rule, e.g. `acme/team/widget.wiki`.

## Legacy flat worktree folders

Older setups sometimes kept many unrelated repos under one shared folder (e.g. `~/worktrees/bundle/`). **Per-repo** layout uses separate `wt_group` paths under `~/wt/<gitlab_path>/`.

**Full clones** (directory `.git`): `mv` into the matching `wt_group` leaf, or re-clone via **INIT_HOME**.

**Linked worktrees** (file `.git` → stale admin paths): broken after moving the old `~/src` tree. Repair from canonical **home** with `git worktree prune` and `git worktree add` (or `wt init`).
