# Design: worktrees + repo memory (v1)

## Decisions (locked)

| Topic | Choice |
|-------|--------|
| Worktree root | `~/wt/<gitlab_path>/...` |
| Canonical checkout | `~/src/<gitlab_path>/`, never deleted |
| Git ops | Human shell + `wt` plugin; agent emits commands |
| Chat retention | Ingest to `~/.cursor/memory/episodes/` keyed by `repo_id` |
| Best current model | `beliefs/*.yaml` → promoted `AGENTS.md` at home |

## Agent memory literature (practical takeaways)

1. **Dual store** (Zep, AriGraph): keep raw episodes; derive structured beliefs; link episodes → beliefs.
2. **Supersession, not erasure** (AriGraph): outdated facts get `superseded_by`, supporting "was X outmoded?"
3. **Lazy consolidation** (RecMem): queue ingest; run LLM synthesis when batching matters—saves tokens.
4. **Operations** (ACM TOIS survey): write (ingest) → manage (consolidate, merge, supersede) → read (query recipes).

We skip a graph database in v1. YAML + grep + agent reads are enough until scale hurts.

## FSA vs plugin

| FSA state | Human | Plugin |
|-----------|-------|--------|
| REGISTER | answers origin/home | `wt register` |
| NEW | branch + worktree name prompts | `wt init` |
| REMOVE | fzf select leaves | `wt edit` (after archive) |
| LIST | — | `wt status` |

Agent never substitutes for plugin execution.

## Gaps / next iterations

1. **Optional:** add `wt register` / `wt add` per `wt-registry/PLUGIN-ALIGNMENT.md`.
2. **Hook**: Cursor `hooks.json` on `sessionEnd` → `ingest-transcript.sh` (optional).
3. **Consolidation worker**: launchd + `cursor` agent job draining `pending-consolidation.yaml`.
4. **Belief merge UI**: lightweight canvas or weekly review skill—not quizzes unless `disputed`.
5. **Slug accuracy**: compare `slugify-path.py` output to real `~/.cursor/projects/` dir names; adjust if mismatch.

## Locked decisions (2025-11-09)

| Topic | Choice |
|-------|--------|
| Home root | Always `~/src/{gitlab_path}` (`gitlab_path_mirror`) |
| `repo_id` | From `origin` → `github-com-org-repo` (ingest script) |
| Consolidation | Weekly batch at most; **always confirm with you** before LLM merge into beliefs |
