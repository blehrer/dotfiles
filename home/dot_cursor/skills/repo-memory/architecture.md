# repo-memory architecture

## Problem

Cursor binds transcripts to **workspace path slugs**. Deleting `~/wt/org/repo/feature` orphans UI history while files may linger under `~/.cursor/projects/`. Git retains branches; **agent memory does not** unless we re-key by `repo_id`.

## Layers

```text
┌─────────────────────────────────────────────────────────┐
│ Canonical docs (AGENTS.md, docs/) — git, home checkout  │
└───────────────────────────▲─────────────────────────────┘
                            │ promote (human approval)
┌───────────────────────────┴─────────────────────────────┐
│ Semantic — beliefs/<repo-id>.yaml                       │
│   current | superseded | disputed                       │
└───────────────────────────▲─────────────────────────────┘
                            │ consolidate (lazy LLM)
┌───────────────────────────┴─────────────────────────────┐
│ Episodic — episodes/<repo-id>/*.yaml                    │
│   transcript_refs → ~/.cursor/projects/.../jsonl      │
└─────────────────────────────────────────────────────────┘
```

## Research mapping

| Pattern | Source | Our implementation |
|---------|--------|---------------------|
| Episode subgraph (raw + time) | Zep | Episode YAML + transcript refs |
| Semantic entities + supersession | AriGraph | Beliefs with `supersedes` / `superseded_by` |
| Defer LLM until signal | RecMem | `pending-consolidation.yaml` queue |
| Forgetting / merge | ACM survey | Mark `superseded`, don't delete episodes |

Full survey: [Rethinking Memory in LLM Agents (2025)](https://arxiv.org/html/2505.00675v3).

## Episode file (example)

```yaml
id: ep-20251109-fix-auth
repo_id: github-com-acme-widget
workspace_path: /Users/jesse/wt/acme/widget/fix-auth
branch: fix-auth
topic: auth timeout on refresh
tags: [auth, oauth]
transcript_refs:
  - slug: Users-jesse-wt-acme-widget-fix-auth
    files:
      - ~/.cursor/projects/Users-jesse-wt-acme-widget-fix-auth/agent-transcripts/abc.jsonl
ingested_at: 2025-11-09T17:00:00-08:00
consolidated: false
```

## Belief file (excerpt)

```yaml
beliefs:
  - id: bel-auth-refresh-01
    statement: Refresh tokens rotate on each use; stale refresh returns 401 and client must re-login.
    status: current
    tags: [auth]
    sources: [ep-20251109-fix-auth]
    created_at: 2025-11-10T10:00:00-08:00
  - id: bel-auth-refresh-00
    statement: Refresh tokens are valid for 30 days without rotation.
    status: superseded
    superseded_by: bel-auth-refresh-01
    sources: [ep-20251001-old]
```

## Queries (agent recipes)

| Question | Primary source | Fallback |
|----------|----------------|----------|
| What happened on X? | episodes by topic/tags | transcript grep |
| Is Y outdated? | beliefs `superseded` chain | episodes |
| How should we think about the repo? | `current` beliefs + AGENTS.md | queue + recent episodes |

## Pruning policy (human-tuned defaults)

- **Episodes**: keep until belief consolidation; optional archive tarball after 1y.
- **Transcript files**: do not delete from `~/.cursor/projects/` until episode ingested.
- **Beliefs**: never hard-delete; supersede only.

Adjust in `registry.yaml` → `memory.policy` when needed.
