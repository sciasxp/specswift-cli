#!/usr/bin/env bash
#
# tasks-to-issues.sh
# Convert uncompleted tasks from tasks.md into GitHub issues.
#
# Usage:
#   _docs/scripts/bash/tasks-to-issues.sh --json [--dry-run] [--label <name>]... [--repo <owner/repo>]
#

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

JSON=false
DRY_RUN=false
REPO=""
LABELS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --repo) REPO="${2:-}"; shift 2 ;;
    --label) LABELS+=("${2:-}"); shift 2 ;;
    -h|--help)
      cat <<'EOF'
Usage:
  tasks-to-issues.sh --json [--dry-run] [--label <name>]... [--repo <owner/repo>]

Notes:
- In --dry-run mode, no issues are created.
- If --repo is omitted, the script uses `git remote get-url origin`.
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
  echo "ERROR: python3 not found (required for tasks-to-issues)" >&2
  exit 1
fi

EVAL_OUTPUT="$(get_feature_paths)"
# shellcheck disable=SC2086
eval "$EVAL_OUTPUT"

TASKS_FILE="${TASKS:-}"
if [[ -z "$TASKS_FILE" || ! -f "$TASKS_FILE" ]]; then
  printf '{"ok":false,"error":"tasks_missing","TASKS":"%s"}\n' "$TASKS_FILE"
  exit 0
fi

if [[ -z "$REPO" ]]; then
  if git remote get-url origin >/dev/null 2>&1; then
    REMOTE_URL="$(git remote get-url origin)"
    REPO="$(python3 - "$REMOTE_URL" <<'PY'
import re, sys
u = sys.argv[1].strip()
# Accept:
# - git@github.com:owner/repo.git
# - https://github.com/owner/repo.git
# - https://github.com/owner/repo
m = re.search(r"github\.com[:/](?P<o>[^/]+)/(?P<r>[^/.]+)(?:\.git)?$", u)
if not m:
    print("")
else:
    print(f"{m.group('o')}/{m.group('r')}")
PY
)"
  fi
fi

if [[ -z "$REPO" ]]; then
  printf '{"ok":false,"error":"repo_missing","message":"Could not determine GitHub repo. Provide --repo owner/repo or configure origin remote."}\n'
  exit 0
fi

# Validate repo looks like owner/repo
if [[ ! "$REPO" =~ ^[^/[:space:]]+/[^/[:space:]]+$ ]]; then
  printf '{"ok":false,"error":"repo_invalid","repo":"%s"}\n' "$REPO"
  exit 0
fi

# Ensure gh exists if not dry run
if [[ "$DRY_RUN" != true ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    printf '{"ok":false,"error":"gh_missing","message":"gh CLI not found. Install GitHub CLI or run with --dry-run."}\n'
    exit 0
  fi
fi

LABEL_ARGS=()
for l in "${LABELS[@]}"; do
  [[ -n "$l" ]] && LABEL_ARGS+=("--label" "$l")
done

PLAN_JSON="$(python3 - "$TASKS_FILE" "$REPO" <<'PY'
import json
import re
import sys

tasks_path = sys.argv[1]
repo = sys.argv[2]

def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()

def normalize(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()

text = read_text(tasks_path)
lines = text.splitlines()

task_re = re.compile(r"^- \[(?P<state>[ xX])\]\s+(?P<id>T\d{3})\b(?P<rest>.*)$")

tasks = []
current = None
for idx, raw in enumerate(lines, start=1):
    m = task_re.match(raw)
    if m:
        if current:
            tasks.append(current)
        current = {
            "id": m.group("id"),
            "done": m.group("state").lower() == "x",
            "line": idx,
            "title_line": normalize(m.group("rest")),
            "block": [raw],
        }
    elif current is not None:
        current["block"].append(raw)
if current:
    tasks.append(current)

open_tasks = [t for t in tasks if not t["done"]]

def task_body(t):
    # Keep task content as body, but remove leading "- [ ] T###"
    block = "\n".join(t["block"])
    block = re.sub(r"^- \[[ xX]\]\s+T\d{3}\s*", "", block, flags=re.MULTILINE)
    return block.strip() or f"(No details found for {t['id']})"

issues = []
for t in open_tasks:
    title = f"{t['id']}: {t['title_line']}".strip()
    issues.append({
        "task_id": t["id"],
        "task_line": t["line"],
        "title": title,
        "body": task_body(t),
    })

payload = {
    "repo": repo,
    "tasks_file": tasks_path,
    "open_tasks": len(open_tasks),
    "issues": issues,
}
print(json.dumps(payload, ensure_ascii=False))
PY
)"

if [[ "$DRY_RUN" == true ]]; then
  python3 - "$PLAN_JSON" <<'PY'
import json, sys
p = json.loads(sys.argv[1])
out = {"ok": True, "dry_run": True, **p}
print(json.dumps(out, ensure_ascii=False))
PY
  exit 0
fi

# Create issues
CREATED=()
while IFS= read -r row; do
  task_id="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["task_id"])' "$row")"
  title="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["title"])' "$row")"
  body="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["body"])' "$row")"

  # gh prints URL on success (usually). Capture it.
  url="$(gh issue create --repo "$REPO" --title "$title" --body "$body" "${LABEL_ARGS[@]}" 2>/dev/null || true)"
  CREATED+=("$(python3 -c 'import json,sys; import os; print(json.dumps({"task_id":sys.argv[1],"url":sys.argv[2]}, ensure_ascii=False))' "$task_id" "$url")")
done < <(python3 - "$PLAN_JSON" <<'PY'
import json, sys
p = json.loads(sys.argv[1])
for issue in p.get("issues", []):
    print(json.dumps(issue, ensure_ascii=False))
PY
)

python3 - "$PLAN_JSON" "${CREATED[@]}" <<'PY'
import json, sys
plan = json.loads(sys.argv[1])
created = []
for raw in sys.argv[2:]:
    created.append(json.loads(raw))
out = {"ok": True, "dry_run": False, **plan, "created": created}
print(json.dumps(out, ensure_ascii=False))
PY

