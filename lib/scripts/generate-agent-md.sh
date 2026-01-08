#!/usr/bin/env bash
#
# generate-agent-md.sh
# Generate or refresh FEATURE_DIR/.agent.md from template + current artifacts.
#
# Usage:
#   _docs/scripts/bash/generate-agent-md.sh --json [--force]
#

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

JSON=false
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=true; shift ;;
    --force) FORCE=true; shift ;;
    -h|--help)
      cat <<'EOF'
Usage:
  generate-agent-md.sh --json [--force]

Generates `_docs/specs/[SHORT_NAME]/.agent.md` using `_docs/templates/agent-file-template.md`.
Preserves the region between:
  <!-- MANUAL ADDITIONS START -->
  <!-- MANUAL ADDITIONS END -->
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
  echo "ERROR: python3 not found (required for generate-agent-md)" >&2
  exit 1
fi

EVAL_OUTPUT="$(get_feature_paths)"
# shellcheck disable=SC2086
eval "$EVAL_OUTPUT"

REPO_ROOT="${REPO_ROOT:-$(get_repo_root)}"
TEMPLATE_PATH="$REPO_ROOT/_docs/templates/agent-file-template.md"
AGENT_PATH="${FEATURE_DIR:-}/.agent.md"

python3 - "$REPO_ROOT" "${FEATURE_DIR:-}" "${CURRENT_BRANCH:-}" "${PRD:-}" "${TECHSPEC:-}" "${TASKS:-}" "$TEMPLATE_PATH" "$AGENT_PATH" "$FORCE" <<'PY'
import json
import os
import re
import sys
from datetime import date

repo_root, feature_dir, branch, prd_path, techspec_path, tasks_path, template_path, agent_path, force = sys.argv[1:10]
force = (force.lower() == "true")

def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()

def write_text(path: str, content: str):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

def normalize(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()

result = {"ok": False, "agent_path": agent_path, "written": False}

if not feature_dir:
    result["error"] = "feature_dir_missing"
    print(json.dumps(result, ensure_ascii=False))
    sys.exit(0)

os.makedirs(feature_dir, exist_ok=True)

if not os.path.exists(template_path):
    result["error"] = "template_missing"
    result["template_path"] = template_path
    print(json.dumps(result, ensure_ascii=False))
    sys.exit(0)

template = read_text(template_path)

manual_start = "<!-- MANUAL ADDITIONS START -->"
manual_end = "<!-- MANUAL ADDITIONS END -->"
manual_block = ""

if os.path.exists(agent_path) and os.path.isfile(agent_path):
    existing = read_text(agent_path)
    m = re.search(re.escape(manual_start) + r"([\s\S]*?)" + re.escape(manual_end), existing)
    if m:
        manual_block = m.group(1).strip("\n")
    elif not force:
        # If file exists but doesn't match template markers, avoid overwriting unless --force
        result["error"] = "agent_exists_unmanaged"
        result["message"] = "Existing .agent.md does not contain manual markers. Use --force to overwrite."
        print(json.dumps(result, ensure_ascii=False))
        sys.exit(0)

short_name = os.path.basename(feature_dir.rstrip("/")) or "feature"
today = date.today().isoformat()

# Extract referenced file paths from tasks.md (best-effort)
main_files = []
if tasks_path and os.path.exists(tasks_path) and os.path.isfile(tasks_path):
    tasks = read_text(tasks_path)
    # capture backticked paths
    for m in re.finditer(r"`([^`]+\.(swift|kt|ts|tsx|py|go|java|md|yml|yaml|json|sh))`", tasks):
        p = m.group(1).strip()
        if "/" in p and p not in main_files:
            main_files.append(p)
        if len(main_files) >= 8:
            break

# Fill placeholders (template is already mostly concrete)
out = template
out = out.replace("[FEATURE_NAME]", short_name)
out = out.replace("[SHORT_NAME]", short_name)
out = out.replace("[DATE]", today)

# Insert/replace Feature Context placeholders if present
out = re.sub(r"^\*\*Objective\*\*:.*$", f"**Objective**: (from PRD) `{short_name}`", out, flags=re.MULTILINE)

# Replace "Main Files" block if we can find it
if main_files:
    # build markdown list
    mf_lines = "\n".join([f"- `{p}`" for p in main_files])
    out = re.sub(
        r"(?s)(\*\*Main Files\*\*:\n)(.*?)(\n\n## Useful Commands)",
        r"\1" + mf_lines + r"\3",
        out,
    )

# Ensure manual markers exist and preserve manual content
if manual_start in out and manual_end in out:
    out = re.sub(
        re.escape(manual_start) + r"[\s\S]*?" + re.escape(manual_end),
        manual_start + ("\n" + manual_block + "\n" if manual_block else "\n") + manual_end,
        out,
    )
else:
    # Append manual markers if missing
    out = out.rstrip() + "\n\n" + manual_start + "\n" + manual_block + ("\n" if manual_block else "") + manual_end + "\n"

write_text(agent_path, out.rstrip() + "\n")
result["ok"] = True
result["written"] = True
result["short_name"] = short_name
result["branch"] = branch
print(json.dumps(result, ensure_ascii=False))
PY

