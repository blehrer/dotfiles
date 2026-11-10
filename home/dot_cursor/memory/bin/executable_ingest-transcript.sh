#!/usr/bin/env bash
set -euo pipefail

CURSOR_DATA="${CURSOR_DATA_DIR:-$HOME/.cursor}"
MEMORY_ROOT="$CURSOR_DATA/memory"
REGISTRY="$CURSOR_DATA/wt-registry/registry.yaml"
BIN_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
  echo "Usage: ingest-transcript.sh --workspace PATH --topic TOPIC [--tags a,b] [--cursor-slug SLUG]"
  exit 1
}

WORKSPACE=""
TOPIC=""
TAGS=""
CURSOR_SLUG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace) WORKSPACE="$2"; shift 2 ;;
    --topic) TOPIC="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    --cursor-slug) CURSOR_SLUG="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown arg: $1"; usage ;;
  esac
done

[[ -n "$WORKSPACE" && -n "$TOPIC" ]] || usage
WORKSPACE="$(cd "$WORKSPACE" && pwd -P)"

ORIGIN=""
if git -C "$WORKSPACE" rev-parse --is-inside-work-tree &>/dev/null; then
  ORIGIN="$(git -C "$WORKSPACE" remote get-url origin 2>/dev/null || true)"
  BRANCH="$(git -C "$WORKSPACE" branch --show-current 2>/dev/null || true)"
else
  BRANCH=""
fi

origin_to_repo_id() {
  local url="$1"
  url="${url%.git}"
  # SCP: git@github.com:org/repo
  if [[ "$url" =~ ^git@([^:]+):(.+)$ ]]; then
    echo "${BASH_REMATCH[1]}-${BASH_REMATCH[2]//\//-}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-'
    return
  fi
  # HTTPS
  if [[ "$url" =~ https?://([^/]+)/(.+) ]]; then
    echo "${BASH_REMATCH[1]}-${BASH_REMATCH[2]//\//-}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-'
    return
  fi
  echo "$url" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-'
}

if [[ -n "$ORIGIN" ]]; then
  REPO_ID="$(origin_to_repo_id "$ORIGIN")"
else
  REPO_ID="unknown-$(basename "$WORKSPACE" | tr '[:upper:]' '[:lower:]')"
fi

if [[ -n "$CURSOR_SLUG" ]]; then
  SLUG="$(echo "$CURSOR_SLUG" | tr '[:upper:]' '[:lower:]')"
else
  SLUG="$(python3 "$BIN_DIR/slugify-path.py" "$WORKSPACE")"
fi
TRANSCRIPT_DIR="$CURSOR_DATA/projects/$SLUG/agent-transcripts"

# ponytail: one find pass; excludes subagent side threads; upgrade to mtime filter if episodes get huge
mapfile -t JSONL < <(find "$TRANSCRIPT_DIR" -name '*.jsonl' ! -path '*/subagents/*' 2>/dev/null | sort || true)

TS="$(date -Iseconds)"
HASH_INPUT="$WORKSPACE|$SLUG"
HASH="$(printf '%s' "$HASH_INPUT" | (md5sum 2>/dev/null || shasum -a 256) | cut -c1-8)"
EP_ID="ep-${TS//[:+]/}-$HASH"
EP_DIR="$MEMORY_ROOT/episodes/$REPO_ID"
mkdir -p "$EP_DIR"

tags_yaml="[]"
if [[ -n "$TAGS" ]]; then
  tags_yaml="[$(echo "$TAGS" | awk -F, '{for(i=1;i<=NF;i++) printf "%s\"%s\"", (i>1?",":""), $i}')]"
fi

files_yaml="[]"
if ((${#JSONL[@]} > 0)); then
  files_yaml="["
  for f in "${JSONL[@]}"; do
  files_yaml+="\"$f\","
  done
  files_yaml="${files_yaml%,}]"
fi

cat >"$EP_DIR/${EP_ID}.yaml" <<EOF
id: $EP_ID
repo_id: $REPO_ID
workspace_path: $WORKSPACE
branch: ${BRANCH:-""}
topic: $TOPIC
tags: $tags_yaml
transcript_refs:
  - slug: $SLUG
    files: $files_yaml
ingested_at: $TS
consolidated: false
EOF

QUEUE="$MEMORY_ROOT/queue/pending-consolidation.yaml"
mkdir -p "$(dirname "$QUEUE")"
if ! grep -q "episode_id: $EP_ID" "$QUEUE" 2>/dev/null; then
  cat >>"$QUEUE" <<EOF

- repo_id: $REPO_ID
  episode_id: $EP_ID
  enqueued_at: $TS
  reason: ingest
EOF
fi

echo "Ingested $EP_ID (repo=$REPO_ID slug=$SLUG transcripts=${#JSONL[@]})"
