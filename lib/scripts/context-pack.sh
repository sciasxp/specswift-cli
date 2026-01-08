#!/usr/bin/env bash
#
# context-pack.sh
# Generate a compact "context pack" JSON to reduce LLM token usage.
#
# Usage:
#   _docs/scripts/bash/context-pack.sh --json [--ide cursor|windsurf] [--max-lines N] [--include-artifacts]
#

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

JSON=false
IDE=""
MAX_LINES="200"
INCLUDE_ARTIFACTS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=true; shift ;;
    --ide)
      IDE="${2:-}"
      shift 2
      ;;
    --max-lines)
      MAX_LINES="${2:-}"
      shift 2
      ;;
    --include-artifacts)
      INCLUDE_ARTIFACTS=true
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Usage:
  context-pack.sh --json [--ide cursor|windsurf] [--max-lines N] [--include-artifacts]

Outputs a compact JSON payload containing:
- repo/doc paths
- selected IDE rules dir (.cursor/.windsurf)
- high-signal excerpts (headings/bullets) to reduce LLM token usage
EOF
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

if [[ "$JSON" != true ]]; then
  echo "ERROR: --json is required" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 not found (required for context-pack)" >&2
  exit 1
fi

if [[ -n "$IDE" && ! "$IDE" =~ ^(cursor|windsurf)$ ]]; then
  echo "ERROR: --ide must be 'cursor' or 'windsurf'" >&2
  exit 1
fi

REPO_ROOT="$(get_repo_root)"

if [[ -z "$IDE" ]]; then
  if [[ -d "$REPO_ROOT/.cursor" ]]; then
    IDE="cursor"
  elif [[ -d "$REPO_ROOT/.windsurf" ]]; then
    IDE="windsurf"
  else
    IDE="cursor"
  fi
fi

RULES_DIR=""
if [[ "$IDE" == "cursor" ]]; then
  RULES_DIR="$REPO_ROOT/.cursor/rules"
else
  RULES_DIR="$REPO_ROOT/.windsurf/rules"
fi

# Feature paths (may or may not exist depending on context)
EVAL_OUTPUT="$(get_feature_paths)"
# shellcheck disable=SC2086
eval "$EVAL_OUTPUT"

README="$REPO_ROOT/README.md"
PRODUCT="$REPO_ROOT/_docs/PRODUCT.md"
STRUCTURE="$REPO_ROOT/_docs/STRUCTURE.md"
TECH="$REPO_ROOT/_docs/TECH.md"

python3 - "$REPO_ROOT" "$IDE" "$RULES_DIR" "$MAX_LINES" "$INCLUDE_ARTIFACTS" \
  "$README" "$PRODUCT" "$STRUCTURE" "$TECH" \
  "${PRD:-}" "${TECHSPEC:-}" "${TASKS:-}" "${RESEARCH:-}" "${DATA_MODEL:-}" "${QUICKSTART:-}" "${CONTRACTS_DIR:-}" <<'PY'
import json
import os
import re
import sys
from datetime import datetime

repo_root = sys.argv[1]
ide = sys.argv[2]
rules_dir = sys.argv[3]
max_lines = int(sys.argv[4]) if sys.argv[4].isdigit() else 200
include_artifacts = (sys.argv[5].lower() == "true")

readme, product, structure, tech = sys.argv[6:10]
prd, techspec, tasks, research, data_model, quickstart, contracts_dir = sys.argv[10:17]

def _read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()

def _extract_high_signal(md: str, limit: int) -> list[str]:
    out: list[str] = []
    in_code = False
    for raw in md.splitlines():
        line = raw.rstrip()
        if line.strip().startswith("```"):
            in_code = not in_code
            continue
        if in_code:
            continue
        if not line.strip():
            continue
        # headings
        if re.match(r"^\s{0,3}#{1,6}\s+\S", line):
            out.append(line.strip())
        # bullets
        elif re.match(r"^\s{0,6}[-*]\s+\S", line):
            out.append(line.strip())
        # tables (header/separator rows)
        elif "|" in line and re.search(r"\|\s*[-:]{2,}\s*\|", line):
            out.append(line.strip())
        # key-value bold lines like **Architecture**: ...
        elif re.match(r"^\s*\*\*[^*]+\*\*:\s+\S", line):
            out.append(line.strip())
        if len(out) >= limit:
            break
    return out

def _file_summary(path: str) -> dict:
    exists = bool(path) and os.path.exists(path)
    if not exists:
        return {"path": path, "exists": False}
    if os.path.isdir(path):
        # rules dir / contracts dir
        files = []
        for root, _, filenames in os.walk(path):
            for fn in filenames:
                if fn.startswith("."):
                    continue
                p = os.path.join(root, fn)
                files.append(os.path.relpath(p, repo_root))
        files.sort()
        return {
            "path": path,
            "exists": True,
            "type": "dir",
            "file_count": len(files),
            "files": files[:200],
            "truncated": len(files) > 200,
        }

    text = _read_text(path)
    sig = _extract_high_signal(text, max_lines)
    return {
        "path": path,
        "exists": True,
        "type": "file",
        "byte_len": len(text.encode("utf-8", errors="replace")),
        "high_signal": sig,
        "truncated": len(sig) >= max_lines,
    }

docs = {
    "README": _file_summary(readme),
    "PRODUCT": _file_summary(product),
    "STRUCTURE": _file_summary(structure),
    "TECH": _file_summary(tech),
    "RULES": _file_summary(rules_dir),
}

artifacts = {
    "PRD": _file_summary(prd) if include_artifacts else {"path": prd, "exists": bool(prd) and os.path.exists(prd)},
    "TECHSPEC": _file_summary(techspec) if include_artifacts else {"path": techspec, "exists": bool(techspec) and os.path.exists(techspec)},
    "TASKS": _file_summary(tasks) if include_artifacts else {"path": tasks, "exists": bool(tasks) and os.path.exists(tasks)},
    "RESEARCH": _file_summary(research) if include_artifacts else {"path": research, "exists": bool(research) and os.path.exists(research)},
    "DATA_MODEL": _file_summary(data_model) if include_artifacts else {"path": data_model, "exists": bool(data_model) and os.path.exists(data_model)},
    "QUICKSTART": _file_summary(quickstart) if include_artifacts else {"path": quickstart, "exists": bool(quickstart) and os.path.exists(quickstart)},
    "CONTRACTS_DIR": _file_summary(contracts_dir) if include_artifacts else {"path": contracts_dir, "exists": bool(contracts_dir) and os.path.exists(contracts_dir)},
}

payload = {
    "ok": True,
    "generated_at": datetime.utcnow().isoformat(timespec="seconds") + "Z",
    "repo_root": repo_root,
    "ide": ide,
    "docs": docs,
    "artifacts": artifacts,
    "notes": {
        "purpose": "High-signal excerpts to reduce LLM token usage. Use paths for full reads only when needed."
    },
}

print(json.dumps(payload, ensure_ascii=False))
PY

