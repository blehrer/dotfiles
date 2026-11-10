---
name: repo-memory
description: Use when archiving Cursor chats before removing a worktree, answering what happened on a past task, checking if a belief is outdated, consolidating mental models, or promoting updates into AGENTS.md
---

# repo-memory

## Overview

Three-layer memory (research-aligned, local-first):

1. **Episodic** — non-lossy pointers to Cursor transcripts + session metadata ([Zep](https://arxiv.org/abs/2501.13956)-style episodes).
2. **Semantic** — beliefs, supersession links, topic tags ([AriGraph](https://arxiv.org/pdf/2407.04363v3)-style graph as YAML).
3. **Canonical** — curated `AGENTS.md` / docs in the **home** checkout (human-approved promotion).

Consolidation is **lazy** ([RecMem](https://luneresearch.com/papers/94070f33-70ef-4aba-97f2-a95e41ff3c0e)): ingest is cheap; LLM synthesis runs from the queue, not every turn.

Read `@architecture.md` for file layout and query recipes.

**Announce when archiving or consolidating:** "Using repo-memory for …"

## Resolve repo id

```bash
git remote get-url origin
```

Normalize to `repo_id` (e.g. `github-com-acme-widget`). Cross-check `~/.cursor/wt-registry/registry.yaml`.

## Archive session (run before worktree delete)

**Inputs to elicit (one turn if missing):** `topic` (short label), optional `tags` (comma-separated).

**Run (human or agent shell, not LLM):**

```bash
~/.cursor/memory/bin/ingest-transcript.sh \
  --workspace "$PWD" \
  --topic "TOPIC" \
  --tags "tag1,tag2"
```

This:

- Finds `~/.cursor/projects/<slug>/agent-transcripts/`
- Appends an episode under `~/.cursor/memory/episodes/<repo-id>/`
- Enqueues consolidation in `~/.cursor/memory/queue/pending-consolidation.yaml`

Report episode id back to the human.

## Query: "What happened when we worked on X?"

1. List episodes: `grep -l "X" ~/.cursor/memory/episodes/<repo-id>/*.yaml` (or ripgrep on `topic` / `tags`).
2. Read matching episodes; follow `transcript_refs` to `.jsonl` if needed.
3. Summarize **timeline** and **outcomes**; cite episode ids.

## Query: "Is belief Y outdated?"

1. Read `~/.cursor/memory/beliefs/<repo-id>.yaml`.
2. Find beliefs matching Y (statement / tags).
3. If `status: superseded`, cite `supersedes` / `superseded_by`.
4. If no belief exists, search episodes; say "not yet consolidated."

## Query: "Current mental model for this codebase?"

1. Load beliefs with `status: current`.
2. Load home `AGENTS.md` if present (canonical home from registry).
3. Present: **stable conventions** (beliefs + AGENTS.md) vs **open questions** (`status: disputed` or recent unconsolidated episodes).

## Consolidate (semantic update)

**Cadence (locked):** at most **once per week** for batch work. **Always confirm with you first** — present pending count and scope, wait for explicit yes (`yes`, `consolidate`, etc.). Do not consolidate because a timer fired alone.

Triggers that still require confirm:

- Weekly memory review (human starts or follows a reminder)
- Human `/memory consolidate` (still summarize before starting if queue is large)
- After `wt rm` archive (episodes enter queue; beliefs update waits for weekly or explicit one-off yes)

**Process (only after confirm):**

1. Pick next queue item (oldest first).
2. Read referenced transcripts (or episode summaries if already partial).
3. Update `beliefs/<repo-id>.yaml`:
   - Add/revise beliefs
   - Mark outdated entries `status: superseded` + `superseded_by`
   - Link `sources: [episode-ids]`
4. Write a short **consolidation note** to `~/.cursor/memory/consolidations/<repo-id>/<date>.md`
5. Remove queue entry; set episode `consolidated: true`

**Do not quiz the human by default.** Optional: if `status: disputed` or two beliefs conflict, ask **one** resolving question.

## Promote to AGENTS.md

1. Draft a minimal patch section `## Agent memory (promoted YYYY-MM-DD)`.
2. Show diff against home `AGENTS.md`.
3. Apply only after explicit approval.

## Weekly review (default ritual)

1. Human runs (or cron only opens a chat):

```bash
~/.cursor/memory/bin/list-pending-consolidation.sh
```

2. Agent reads `~/.cursor/wt-registry/registry.yaml` → `defaults.memory.consolidate_requires_confirm`.
3. Agent lists repos/episodes pending and proposes: *"Consolidate N episodes across repos R1, R2?"*
4. **Stop** until you confirm. On no → exit; on yes → run **Consolidate** once per repo or as scoped in the reply.

Optional: `cursor-subscriptions-subscribe_timer` for a weekly nudge that only **reminds** you to open this flow — the agent must not auto-consolidate on timer wake without confirm.

See `@weekly-review.md`.

## Background automation (vNext)

Cron may run `list-pending-consolidation.sh` and open Cursor; it must **not** invoke consolidation without a human in the loop.

See `~/.cursor/memory/README.md`.

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Trusting sidebar history after `rm -rf ~/wt/...` | Archive first |
| Creating beliefs without episode sources | Require `sources:` |
| Auto-editing AGENTS.md | Proposal only |
