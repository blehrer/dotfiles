# Local repo memory (`~/.cursor/memory`)

Cursor ties chat UI to **folder paths**. This store re-keys sessions by **`repo_id`** so work under `~/wt/...` stays discoverable after folders are removed.

## Layout

| Path | Purpose |
|------|---------|
| `episodes/<repo-id>/*.yaml` | Session index + transcript pointers |
| `beliefs/<repo-id>.yaml` | Current / superseded mental model |
| `queue/pending-consolidation.yaml` | Lazy LLM consolidation queue |
| `consolidations/<repo-id>/*.md` | Human-readable synthesis notes |
| `bin/` | Non-LLM ingest utilities |

Registry: `~/.cursor/wt-registry/registry.yaml`.

Skills: `~/.cursor/skills/repo-memory/`, `~/.cursor/skills/wt-workflow/`.

Rules: `~/.cursor/rules/worktree-layout.mdc`, `repo-memory.mdc`.

## Quick start

```bash
# Before removing a worktree folder
~/.cursor/memory/bin/ingest-transcript.sh --workspace "$PWD" --topic "short label"

# See what needs consolidation
~/.cursor/memory/bin/list-pending-consolidation.sh
```

Then ask the agent (with **repo-memory**): "consolidate pending for this repo" or "what happened when we worked on auth?"

## Weekly consolidation

- Episodes accumulate in the queue after ingest (e.g. before `wt rm`).
- **Once per week** (or when you ask): open agent with **repo-memory**, run `list-pending-consolidation.sh`, review the summary.
- You must **explicitly confirm** before beliefs are updated. Timers may remind only; they must not auto-consolidate.

Skill detail: `~/.cursor/skills/repo-memory/weekly-review.md`.

## Background job (optional)

Weekly reminder only (not auto-consolidate):

```bash
~/.cursor/memory/bin/list-pending-consolidation.sh
# open Cursor → "weekly repo-memory review"
```

vNext: launchd plist + optional `subscribe_timer` nudge.

## Promotion to git

Beliefs are **proposals** until merged into the repo's `AGENTS.md` at the canonical home path (human approves in chat).
