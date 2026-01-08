#!/usr/bin/env bash
#
# extract-artifacts.sh
# Extract deterministic inventories from PRD/TechSpec to reduce LLM token usage.
#
# Usage:
#   _docs/scripts/bash/extract-artifacts.sh --json
#

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

JSON=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=true; shift ;;
    -h|--help)
      cat <<'EOF'
Usage:
  extract-artifacts.sh --json

Outputs JSON including:
- FR/NFR inventory from PRD
- User stories inventory (US#) from PRD
- High-level tech choices + component name candidates from TechSpec
EOF
      exit 0
      ;;
    *) shift ;;
  esac
done

if [[ "$JSON" != true ]]; then
  echo "ERROR: --json is required" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 not found (required for extract-artifacts)" >&2
  exit 1
fi

EVAL_OUTPUT="$(get_feature_paths)"
# shellcheck disable=SC2086
eval "$EVAL_OUTPUT"

python3 - "${REPO_ROOT:-}" "${FEATURE_DIR:-}" "${PRD:-}" "${TECHSPEC:-}" <<'PY'
import json
import os
import re
import sys

repo_root, feature_dir, prd_path, techspec_path = sys.argv[1:5]

def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()

def normalize_space(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()

def extract_requirements(prd: str):
    fr = {}
    nfr = {}
    for i, raw in enumerate(prd.splitlines(), start=1):
        line = raw.strip()
        m = re.search(r"\b(FR-\d{3})\b", line)
        if m:
            rid = m.group(1)
            fr.setdefault(rid, {"id": rid, "line": i, "text": normalize_space(line)})
        m = re.search(r"\b(NFR-\d{3})\b", line)
        if m:
            rid = m.group(1)
            nfr.setdefault(rid, {"id": rid, "line": i, "text": normalize_space(line)})
    return sorted(fr.values(), key=lambda x: x["id"]), sorted(nfr.values(), key=lambda x: x["id"])

def extract_user_stories(prd: str):
    stories = []
    # Common patterns:
    # - "### US1: Title (Priority: P1)"
    # - "## Phase 3: US1 - Title"
    for i, raw in enumerate(prd.splitlines(), start=1):
        line = raw.strip()
        m = re.match(r"^#{2,6}\s+US(\d+)\s*:\s*(.+)$", line)
        if m:
            sid = f"US{m.group(1)}"
            title = normalize_space(m.group(2))
            stories.append({"id": sid, "title": title, "line": i})
            continue
        m = re.match(r"^#{2,6}\s+.*\bUS(\d+)\b\s*[-:]\s*(.+)$", line)
        if m:
            sid = f"US{m.group(1)}"
            title = normalize_space(m.group(2))
            stories.append({"id": sid, "title": title, "line": i})
    # De-dup by id, keep first
    seen = set()
    out = []
    for s in stories:
        if s["id"] in seen:
            continue
        seen.add(s["id"])
        out.append(s)
    return out

def extract_edge_cases(prd: str):
    lines = prd.splitlines()
    # Find "Edge Cases" section start
    start = None
    for idx, raw in enumerate(lines):
        if re.match(r"^#{2,6}\s+Edge Cases\b", raw.strip(), re.IGNORECASE) or re.match(r"^#{2,6}\s+Casos de Borda\b", raw.strip(), re.IGNORECASE):
            start = idx + 1
            break
    if start is None:
        return []
    out = []
    for raw in lines[start:]:
        if re.match(r"^#{1,6}\s+", raw.strip()):
            break
        if re.match(r"^\s*[-*]\s+\S", raw):
            out.append(normalize_space(raw.strip()))
        if len(out) >= 30:
            break
    return out

def extract_tech_kv(tech: str):
    kv = {}
    # Look for "**Key**: value" lines in Technical Context
    for raw in tech.splitlines():
        m = re.match(r"^\s*\*\*([^*]+)\*\*:\s*(.+)$", raw.strip())
        if m:
            k = normalize_space(m.group(1))
            v = normalize_space(m.group(2))
            if k and v and k not in kv:
                kv[k] = v
    return kv

def extract_component_candidates(text: str):
    candidates = set()
    # Heuristic: Swift-ish type names with common suffixes
    for m in re.finditer(r"\b([A-Z][A-Za-z0-9]{2,}(ViewModel|Service|Repository|Coordinator|Manager|Store|Client|API|Provider))\b", text):
        candidates.add(m.group(1))
    # Also capture "class Foo" / "struct Foo" / "enum Foo"
    for m in re.finditer(r"\b(class|struct|enum|actor)\s+([A-Z][A-Za-z0-9_]+)\b", text):
        candidates.add(m.group(2))
    out = sorted(candidates)
    return out[:200]

payload = {
    "ok": True,
    "repo_root": repo_root,
    "feature_dir": feature_dir,
    "prd": {"path": prd_path, "exists": False, "fr": [], "nfr": [], "user_stories": [], "edge_cases": []},
    "techspec": {"path": techspec_path, "exists": False, "key_values": {}, "components": []},
}

if prd_path and os.path.exists(prd_path) and os.path.isfile(prd_path):
    prd_text = read_text(prd_path)
    fr, nfr = extract_requirements(prd_text)
    payload["prd"].update(
        exists=True,
        fr=fr,
        nfr=nfr,
        user_stories=extract_user_stories(prd_text),
        edge_cases=extract_edge_cases(prd_text),
    )

if techspec_path and os.path.exists(techspec_path) and os.path.isfile(techspec_path):
    tech_text = read_text(techspec_path)
    payload["techspec"].update(
        exists=True,
        key_values=extract_tech_kv(tech_text),
        components=extract_component_candidates(tech_text),
    )

print(json.dumps(payload, ensure_ascii=False))
PY

