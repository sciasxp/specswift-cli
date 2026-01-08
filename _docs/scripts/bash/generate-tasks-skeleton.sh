#!/usr/bin/env bash
#
# generate-tasks-skeleton.sh
# Create/overwrite a minimal tasks.md skeleton based on PRD user stories.
#
# Usage:
#   _docs/scripts/bash/generate-tasks-skeleton.sh --json [--force]
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
  generate-tasks-skeleton.sh --json [--force]

Creates FEATURE_DIR/tasks.md skeleton with:
- Phase 1 (Setup) + optional XcodeGen tasks
- Phase 2 (Foundational)
- One phase per user story (US#) discovered in PRD

This is scaffolding: an LLM/human must replace placeholders with real tasks.
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
  echo "ERROR: python3 not found (required for generate-tasks-skeleton)" >&2
  exit 1
fi

EVAL_OUTPUT="$(get_feature_paths)"
# shellcheck disable=SC2086
eval "$EVAL_OUTPUT"

python3 - "${REPO_ROOT:-}" "${FEATURE_DIR:-}" "${PRD:-}" "${TECHSPEC:-}" "${TASKS:-}" "$FORCE" <<'PY'
import json
import os
import re
import sys
from datetime import date

repo_root, feature_dir, prd_path, techspec_path, tasks_path, force = sys.argv[1:7]
force = (force.lower() == "true")

def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()

def norm(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()

def extract_user_stories(prd: str):
    stories = []
    for raw in prd.splitlines():
        line = raw.strip()
        m = re.match(r"^#{2,6}\s+US(\d+)\s*:\s*(.+)$", line)
        if m:
            stories.append((int(m.group(1)), f"US{m.group(1)}", norm(m.group(2))))
            continue
        m = re.match(r"^#{2,6}\s+.*\bUS(\d+)\b\s*[-:]\s*(.+)$", line)
        if m:
            stories.append((int(m.group(1)), f"US{m.group(1)}", norm(m.group(2))))
    # dedup by id
    seen = set()
    out = []
    for n, sid, title in sorted(stories, key=lambda x: x[0]):
        if sid in seen:
            continue
        seen.add(sid)
        out.append((sid, title))
    return out

def has_xcodeproj(repo_root: str) -> bool:
    try:
        for entry in os.listdir(repo_root):
            if entry.endswith(".xcodeproj"):
                return True
    except FileNotFoundError:
        return False
    return False

def has_project_yml(repo_root: str) -> bool:
    return os.path.exists(os.path.join(repo_root, "project.yml"))

result = {
    "ok": False,
    "repo_root": repo_root,
    "feature_dir": feature_dir,
    "PRD": prd_path,
    "TECHSPEC": techspec_path,
    "TASKS": tasks_path,
    "written": False,
    "user_stories": [],
}

if not feature_dir:
    result["error"] = "feature_dir_missing"
    print(json.dumps(result, ensure_ascii=False))
    sys.exit(0)

os.makedirs(feature_dir, exist_ok=True)

if tasks_path and os.path.exists(tasks_path) and not force:
    result["error"] = "tasks_exists"
    result["message"] = "tasks.md already exists. Re-run with --force to overwrite."
    print(json.dumps(result, ensure_ascii=False))
    sys.exit(0)

prd_text = ""
if prd_path and os.path.exists(prd_path) and os.path.isfile(prd_path):
    prd_text = read_text(prd_path)

stories = extract_user_stories(prd_text) if prd_text else []
result["user_stories"] = [{"id": sid, "title": title} for sid, title in stories]

short_name = os.path.basename(feature_dir.rstrip("/")) if feature_dir else "feature"
today = date.today().isoformat()

lines: list[str] = []
lines.append(f"# Tasks: {short_name}")
lines.append("")
lines.append(f"**Feature**: `{short_name}`")
lines.append(f"**PRD**: `{prd_path}`")
lines.append(f"**TechSpec**: `{techspec_path}`")
lines.append(f"**Generated**: {today}")
lines.append("")
lines.append("---")
lines.append("")
lines.append("## Phase 1: Setup")
lines.append("")

tid = 1

def task_line(tid_num: int, markers: str, desc: str) -> list[str]:
    t = f"T{tid_num:03d}"
    head = f"- [ ] {t} {markers} {desc}".replace("  ", " ").strip()
    return [
        head,
        "  - **Acceptance Criteria**:",
        "    - [ ] TODO",
        "  - **Unit Tests**:",
        "    - [ ] `test_todo()`",
        "",
    ]

if not has_xcodeproj(repo_root):
    if has_project_yml(repo_root):
        lines += task_line(tid, "[P]", "Run `xcodegen generate` to create the .xcodeproj (if iOS/macOS project)")
        tid += 1
    else:
        lines += task_line(tid, "", "Create `project.yml` from XcodeGen template (if iOS/macOS project)")
        tid += 1
        lines += task_line(tid, "", "Run `xcodegen generate` to create the .xcodeproj (if iOS/macOS project)")
        tid += 1

lines += task_line(tid, "", "Create/confirm project structure per techspec.md")
tid += 1
lines += task_line(tid, "", "Ensure project compiles and dependencies resolve")
tid += 1
lines += task_line(tid, "[P]", "Configure linting/formatting tools (if applicable)")
tid += 1

lines.append("---")
lines.append("")
lines.append("## Phase 2: Foundational (Blocking)")
lines.append("")
lines += task_line(tid, "", "Implement foundational infrastructure required by all user stories")
tid += 1

phase_num = 3
for sid, title in stories:
    lines.append("---")
    lines.append("")
    lines.append(f"## Phase {phase_num}: {sid} - {title}")
    lines.append("")
    lines += task_line(tid, "[P] [" + sid + "]", "Write unit tests for core logic (TDD)")
    tid += 1
    lines += task_line(tid, "[" + sid + "]", "Implement functionality for this user story")
    tid += 1
    phase_num += 1

lines.append("---")
lines.append("")
lines.append("## Phase N: Polish")
lines.append("")
lines += task_line(tid, "[P]", "Documentation updates and cleanup")

tasks_path = tasks_path or os.path.join(feature_dir, "tasks.md")
with open(tasks_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines).rstrip() + "\n")

result["ok"] = True
result["written"] = True
print(json.dumps(result, ensure_ascii=False))
PY

