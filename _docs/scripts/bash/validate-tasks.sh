#!/usr/bin/env bash
#
# validate-tasks.sh
# Validate tasks.md structure, dependencies, and (basic) traceability coverage.
#
# Usage:
#   _docs/scripts/bash/validate-tasks.sh --json [--include-report]
#
# Output (JSON):
#   {
#     ok: bool,
#     TASKS: <path>,
#     counts: {...},
#     findings: [{id,severity,category,location,message,fix}],
#     report_md?: "..."
#   }
#

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

JSON=false
INCLUDE_REPORT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=true; shift ;;
    --include-report) INCLUDE_REPORT=true; shift ;;
    -h|--help)
      cat <<'EOF'
Usage:
  validate-tasks.sh --json [--include-report]

Validates:
- tasks numbering and presence
- required subsections: Acceptance Criteria / Unit Tests (or PT equivalents)
- basic dependency extraction + cycle check
- basic traceability counts (tasks mentioning FR-/NFR-/US tags)

JSON output is intended to be consumed by workflows to reduce LLM token usage.
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
  echo "ERROR: python3 not found (required for validate-tasks)" >&2
  exit 1
fi

EVAL_OUTPUT="$(get_feature_paths)"
# shellcheck disable=SC2086
eval "$EVAL_OUTPUT"

python3 - "${REPO_ROOT:-}" "${FEATURE_DIR:-}" "${PRD:-}" "${TECHSPEC:-}" "${TASKS:-}" "$INCLUDE_REPORT" <<'PY'
import json
import os
import re
import sys
from collections import defaultdict, deque

repo_root, feature_dir, prd_path, techspec_path, tasks_path, include_report = sys.argv[1:7]
include_report = (include_report.lower() == "true")

def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()

def normalize(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()

def extract_prd_requirements(text: str):
    fr = set(re.findall(r"\bFR-\d{3}\b", text))
    nfr = set(re.findall(r"\bNFR-\d{3}\b", text))
    return sorted(fr), sorted(nfr)

def extract_tasks_blocks(text: str):
    lines = text.splitlines()
    tasks = []
    current = None

    task_re = re.compile(r"^- \[(?P<state>[ xX])\]\s+(?P<id>T\d{3})\b(?P<rest>.*)$")
    for idx, raw in enumerate(lines, start=1):
        m = task_re.match(raw)
        if m:
            if current:
                tasks.append(current)
            current = {
                "id": m.group("id"),
                "state": "done" if m.group("state").lower() == "x" else "todo",
                "line": idx,
                "title": normalize(m.group("rest")),
                "block_lines": [raw],
            }
        elif current is not None:
            current["block_lines"].append(raw)
    if current:
        tasks.append(current)
    return tasks

def has_section(block: str, section_names: list[str]) -> bool:
    # Accept either exact markdown bold form or header-ish
    for name in section_names:
        if re.search(rf"\*\*\s*{re.escape(name)}\s*\*\*", block, re.IGNORECASE):
            return True
        if re.search(rf"^#{2,6}\s+{re.escape(name)}\b", block, re.IGNORECASE | re.MULTILINE):
            return True
    return False

def extract_dependencies(block: str):
    deps = set()
    # Structured: depends_on: [T001, T002]
    m = re.search(r"depends_on\s*:\s*\[([^\]]+)\]", block, re.IGNORECASE)
    if m:
        for token in re.split(r"[,\s]+", m.group(1).strip()):
            if re.match(r"^T\d{3}$", token):
                deps.add(token)
    # Free text: "depends on T001" / "depende de T001"
    for m in re.finditer(r"\b(depends on|depende de)\s+(T\d{3})\b", block, re.IGNORECASE):
        deps.add(m.group(2))
    return sorted(deps)

def extract_tags(block: str):
    fr = sorted(set(re.findall(r"\bFR-\d{3}\b", block)))
    nfr = sorted(set(re.findall(r"\bNFR-\d{3}\b", block)))
    us = sorted(set(re.findall(r"\bUS\d+\b", block)))
    return fr, nfr, us

def cycle_check(graph: dict[str, list[str]]):
    # Kahn topo; if not all visited => cycle
    indeg = defaultdict(int)
    nodes = set(graph.keys())
    for a, bs in graph.items():
        nodes.add(a)
        for b in bs:
            nodes.add(b)
            indeg[b] += 1
            indeg.setdefault(a, indeg[a])
    q = deque([n for n in nodes if indeg[n] == 0])
    visited = []
    while q:
        n = q.popleft()
        visited.append(n)
        for m in graph.get(n, []):
            indeg[m] -= 1
            if indeg[m] == 0:
                q.append(m)
    has_cycle = len(visited) != len(nodes)
    return has_cycle

payload = {
    "ok": False,
    "repo_root": repo_root,
    "feature_dir": feature_dir,
    "PRD": prd_path,
    "TECHSPEC": techspec_path,
    "TASKS": tasks_path,
    "counts": {},
    "findings": [],
}

def add_finding(fid, severity, category, location, message, fix=None):
    payload["findings"].append({
        "id": fid,
        "severity": severity,
        "category": category,
        "location": location,
        "message": message,
        "fix": fix or "",
    })

if not tasks_path or not os.path.exists(tasks_path):
    add_finding(
        "T0",
        "CRITICAL",
        "tasks",
        tasks_path or "(missing)",
        "tasks.md not found. Run /specswift.tasks first (or create tasks.md).",
    )
    print(json.dumps(payload, ensure_ascii=False))
    sys.exit(0)

tasks_text = read_text(tasks_path)
tasks = extract_tasks_blocks(tasks_text)

payload["counts"]["tasks_total"] = len(tasks)
payload["counts"]["tasks_done"] = sum(1 for t in tasks if t["state"] == "done")
payload["counts"]["tasks_todo"] = sum(1 for t in tasks if t["state"] == "todo")

if len(tasks) == 0:
    add_finding("T1", "CRITICAL", "format", tasks_path, "No tasks found (expected '- [ ] T001 ...').")
    print(json.dumps(payload, ensure_ascii=False))
    sys.exit(0)

# numbering validation
ids = [t["id"] for t in tasks]
id_nums = [int(t["id"][1:]) for t in tasks]
expected = list(range(min(id_nums), min(id_nums) + len(id_nums)))
if id_nums != expected:
    add_finding(
        "N1",
        "HIGH",
        "numbering",
        tasks_path,
        "Task IDs are not sequential (expected continuous numbering).",
        "Renumber tasks to be sequential across the file (T001, T002, ...).",
    )

# section validation
acceptance_names = ["Acceptance Criteria", "Critérios de Aceitação", "Criterios de Aceitacao"]
tests_names = ["Unit Tests", "Testes Unitários", "Testes Unitarios"]

tasks_missing_acceptance = 0
tasks_missing_tests = 0
tasks_with_tests_count = 0
tasks_tests_items = {}

dep_graph = {}
missing_dep_refs = []

coverage_fr = defaultdict(list)
coverage_nfr = defaultdict(list)
coverage_us = defaultdict(list)

for t in tasks:
    block = "\n".join(t["block_lines"])

    if not has_section(block, acceptance_names):
        tasks_missing_acceptance += 1
        add_finding(
            f"AC-{t['id']}",
            "CRITICAL",
            "acceptance",
            f"{tasks_path}:{t['line']}",
            f"{t['id']} is missing an Acceptance Criteria section.",
            "Add an **Acceptance Criteria** section with checkboxes mapping to PRD requirements.",
        )

    if not has_section(block, tests_names):
        tasks_missing_tests += 1
        add_finding(
            f"UT-{t['id']}",
            "CRITICAL",
            "tests",
            f"{tasks_path}:{t['line']}",
            f"{t['id']} is missing a Unit Tests section.",
            "Add a **Unit Tests** section listing planned test methods (backticked).",
        )
    else:
        # count test-like lines
        test_lines = re.findall(r"`test_[^`]+`", block)
        tasks_tests_items[t["id"]] = len(test_lines)
        if len(test_lines) > 0:
            tasks_with_tests_count += 1

    deps = extract_dependencies(block)
    dep_graph[t["id"]] = deps

    for d in deps:
        if d not in ids:
            missing_dep_refs.append((t["id"], d, t["line"]))

    fr, nfr, us = extract_tags(block)
    for rid in fr:
        coverage_fr[rid].append(t["id"])
    for rid in nfr:
        coverage_nfr[rid].append(t["id"])
    for sid in us:
        coverage_us[sid].append(t["id"])

payload["counts"]["tasks_missing_acceptance"] = tasks_missing_acceptance
payload["counts"]["tasks_missing_tests"] = tasks_missing_tests
payload["counts"]["tasks_with_any_test_names"] = tasks_with_tests_count

for (src, missing, line) in missing_dep_refs[:50]:
    add_finding(
        f"DEP-{src}-{missing}",
        "CRITICAL",
        "dependency",
        f"{tasks_path}:{line}",
        f"{src} depends on missing task {missing}.",
        "Fix the dependency reference or create the missing task.",
    )

if cycle_check(dep_graph):
    add_finding(
        "DEP-CYCLE",
        "CRITICAL",
        "dependency",
        tasks_path,
        "Dependency graph contains a cycle.",
        "Remove cycles by rethinking ordering/splitting tasks or making dependencies one-directional.",
    )

# PRD requirement coverage (only if PRD exists)
prd_fr = []
prd_nfr = []
if prd_path and os.path.exists(prd_path) and os.path.isfile(prd_path):
    prd_text = read_text(prd_path)
    prd_fr, prd_nfr = extract_prd_requirements(prd_text)
    uncovered_fr = [r for r in prd_fr if r not in coverage_fr]
    uncovered_nfr = [r for r in prd_nfr if r not in coverage_nfr]
    for rid in uncovered_fr[:50]:
        add_finding(
            f"COV-{rid}",
            "CRITICAL",
            "coverage",
            rid,
            f"{rid} has no task referencing it. Add {rid} tag to the implementing task(s).",
            "Include FR/NFR tags in task descriptions or acceptance criteria to enable deterministic coverage checks.",
        )
    for rid in uncovered_nfr[:50]:
        add_finding(
            f"COV-{rid}",
            "CRITICAL",
            "coverage",
            rid,
            f"{rid} has no task referencing it. Add {rid} tag to the implementing task(s).",
            "Include FR/NFR tags in task descriptions or acceptance criteria to enable deterministic coverage checks.",
        )

# Gate status heuristic
critical = [f for f in payload["findings"] if f["severity"] == "CRITICAL"]
payload["counts"]["critical_findings"] = len(critical)
payload["counts"]["high_findings"] = sum(1 for f in payload["findings"] if f["severity"] == "HIGH")
payload["counts"]["medium_findings"] = sum(1 for f in payload["findings"] if f["severity"] == "MEDIUM")
payload["counts"]["low_findings"] = sum(1 for f in payload["findings"] if f["severity"] == "LOW")
payload["ok"] = (len(critical) == 0)

payload["traceability"] = {
    "prd_fr_total": len(prd_fr),
    "prd_nfr_total": len(prd_nfr),
    "tasks_with_fr_tags": sum(1 for tid in ids if any(tid in v for v in coverage_fr.values())),
    "tasks_with_nfr_tags": sum(1 for tid in ids if any(tid in v for v in coverage_nfr.values())),
    "coverage_fr": {k: v for k, v in sorted(coverage_fr.items())},
    "coverage_nfr": {k: v for k, v in sorted(coverage_nfr.items())},
    "coverage_us": {k: v for k, v in sorted(coverage_us.items())},
}

def render_report_md():
    status = "🟢 APPROVED" if payload["ok"] else "🔴 BLOCKED"
    lines = []
    lines.append("## 🚦 Implementation Gate Report")
    lines.append("")
    lines.append(f"**RESULT**: {status}")
    lines.append("")
    lines.append("### Metrics")
    lines.append(f"- Tasks: {payload['counts']['tasks_total']} total ({payload['counts']['tasks_done']} done / {payload['counts']['tasks_todo']} open)")
    lines.append(f"- Missing Acceptance Criteria: {payload['counts']['tasks_missing_acceptance']}")
    lines.append(f"- Missing Unit Tests: {payload['counts']['tasks_missing_tests']}")
    lines.append(f"- Critical findings: {payload['counts']['critical_findings']}")
    if prd_fr or prd_nfr:
        lines.append(f"- PRD FR total: {len(prd_fr)} | NFR total: {len(prd_nfr)}")
    lines.append("")
    lines.append("### Findings (Top)")
    lines.append("")
    lines.append("| ID | Severity | Category | Location | Summary |")
    lines.append("|----|----------|----------|----------|---------|")
    for f in payload["findings"][:50]:
        lines.append(f"| {f['id']} | {f['severity']} | {f['category']} | {f['location']} | {normalize(f['message'])} |")
    lines.append("")
    lines.append("### Notes")
    lines.append("- For deterministic coverage checks, reference PRD requirement IDs (FR-### / NFR-###) inside tasks.")
    return "\n".join(lines)

if include_report:
    payload["report_md"] = render_report_md()

print(json.dumps(payload, ensure_ascii=False))
PY

