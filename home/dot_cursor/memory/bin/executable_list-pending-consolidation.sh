#!/usr/bin/env bash
set -euo pipefail

CURSOR_DATA="${CURSOR_DATA_DIR:-$HOME/.cursor}"
QUEUE="$CURSOR_DATA/memory/queue/pending-consolidation.yaml"
JSON=false

[[ "${1:-}" == "--json" ]] && JSON=true

if [[ ! -f "$QUEUE" ]]; then
  $JSON && echo '{"count":0,"items":[]}' || echo "No queue file."
  exit 0
fi

# Count list items after header (lines starting with "  -" or "- repo_id")
COUNT="$(grep -c '^- repo_id:' "$QUEUE" 2>/dev/null || true)"

if $JSON; then
  python3 - <<'PY' "$QUEUE" "$COUNT"
import sys, pathlib
path = pathlib.Path(sys.argv[1])
count = int(sys.argv[2])
text = path.read_text()
import json
print(json.dumps({"count": count, "path": str(path), "tail": text.strip()[-2000:]}))
PY
else
  echo "Pending consolidation: $COUNT"
  grep -A3 '^- repo_id:' "$QUEUE" || true
fi
