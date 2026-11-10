# Global agent notes (`~/.cursor`)

Personal infrastructure lives here, not in app repos, until patterns stabilize.

## Worktrees

- **Home:** `~/src/<gitlab_path>/` (canonical; never delete). Registry + `layout.md` (`gitlab_path_mirror`).
- **Tasks:** `~/wt/<gitlab_path>/<leaf>/` — agent **resolves or creates** via `resolve-implementation-checkout.sh` when you assign branch/MR work.
- **Employer workspace defaults:** `rules/worktree-layout.local.mdc` (machine-local; not in dotfiles).
- **Removal:** `wt edit` — human confirms; ingest repo-memory first.
- **Planning new layout:** skill **wt-workflow** mode B (copy-paste commands).

## Memory

Cross-worktree chat retention: skill **repo-memory**, store under `~/.cursor/memory/`, registry `~/.cursor/wt-registry/registry.yaml` (machine-local; **never** employer repos in dotfiles).

Before deleting a worktree directory, run:

```bash
~/.cursor/memory/bin/ingest-transcript.sh --workspace "$PWD" --topic "<short label>"
```

## Rules

- `rules/dotfiles-boundary.mdc` — public chezmoi repo vs machine-local employer config (always on)
- `rules/worktree-layout.mdc` — always on
- `rules/repo-memory.mdc` — memory queries and consolidation

## Skills (personal)

- `skills/wt-workflow/` — FSA + `wt` command elicitation
- `skills/repo-memory/` — episodic ingest, beliefs, AGENTS.md promotion

**wt:** `init` / `edit` / `status` / `doctor` — see `skills/wt-workflow/wt-commands.md`. Plugin defaults `~/src` + `~/wt` (`apply-wt-defaults.sh` if needed).
