# Weekly memory review

## Policy

| Setting | Value |
|---------|--------|
| Cadence | Weekly (at most one batch consolidation pass per 7 days unless you ask ad hoc) |
| Confirm | Required every time before LLM consolidation |
| `repo_id` | From `origin` URL (`github-com-org-repo`) — matches ingest script |

## Agent script (follow in order)

1. Run `~/.cursor/memory/bin/list-pending-consolidation.sh`.
2. If count is 0: report *"Nothing to consolidate"*; done.
3. If count > 0: summarize by `repo_id` (episode ids, topics if easy from filenames).
4. Ask: *"Consolidate these now? (yes / no / only repo X)"*
5. On **no** or silence: do nothing to beliefs or queue.
6. On **yes** or scoped yes: run consolidate steps in `SKILL.md` for approved repos only.
7. End with: optional *"Promote anything to AGENTS.md?"* — separate confirm.

## Ad hoc

- *"consolidate now"* in chat → still one-line scope confirm if queue > 3 episodes.
- *"skip this week"* → no consolidate; timer reminders OK next week.

## Weekly timer (optional)

Use Subscribe timer or system calendar. Timer text should be:

> Weekly repo-memory: run list-pending, summarize, ask for confirm — do not consolidate without yes.
