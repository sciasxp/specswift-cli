#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

JSON=false
PATHS_ONLY=false
REQUIRE_TASKS=false
INCLUDE_TASKS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON=true; shift ;;
        --paths-only) PATHS_ONLY=true; shift ;;
        --require-tasks) REQUIRE_TASKS=true; shift ;;
        --include-tasks) INCLUDE_TASKS=true; shift ;;
        *) shift ;;
    esac
done

# Resolve paths
# This prints KEY='value' lines
EVAL_OUTPUT="$(get_feature_paths)"
# shellcheck disable=SC2086
eval "$EVAL_OUTPUT"

available=()
[[ -f "$PRD" ]] && available+=("prd")
[[ -f "$TECHSPEC" ]] && available+=("techspec")
[[ -f "$TASKS" ]] && available+=("tasks")

if [[ "$REQUIRE_TASKS" == true && ! -f "$TASKS" ]]; then
    if [[ "$JSON" == true ]]; then
        printf '{"ok":false,"error":"tasks_missing","TASKS":"%s","FEATURE_DIR":"%s"}\n' "$TASKS" "$FEATURE_DIR"
    else
        echo "ERROR: tasks.md not found: $TASKS" >&2
    fi
    exit 1
fi

if [[ "$JSON" == true ]]; then
    printf '{'
    printf '"REPO_ROOT":"%s",' "$REPO_ROOT"
    printf '"CURRENT_BRANCH":"%s",' "$CURRENT_BRANCH"
    printf '"HAS_GIT":%s,' "$HAS_GIT"
    printf '"FEATURE_DIR":"%s",' "$FEATURE_DIR"
    printf '"PRD":"%s",' "$PRD"
    printf '"FEATURE_SPEC":"%s",' "$PRD"
    printf '"TECHSPEC":"%s",' "$TECHSPEC"
    printf '"IMPL_PLAN":"%s",' "$TECHSPEC"
    printf '"TASKS":"%s",' "$TASKS"
    printf '"AVAILABLE_DOCS":['
    for i in "${!available[@]}"; do
        [[ $i -gt 0 ]] && printf ','
        printf '"%s"' "${available[$i]}"
    done
    printf ']'

    if [[ "$INCLUDE_TASKS" == true ]]; then
        present=false
        [[ -f "$TASKS" ]] && present=true
        printf ',"TASKS_PRESENT":%s' "$present"
        
        # Include reference documents paths
        printf ',"REFERENCE_DOCS":{'
        printf '"RESEARCH":"%s",' "$RESEARCH"
        printf '"UI_DESIGN":"%s",' "$UI_DESIGN"
        printf '"DATA_MODEL":"%s",' "$DATA_MODEL"
        printf '"QUICKSTART":"%s",' "$QUICKSTART"
        printf '"AGENT_MD":"%s",' "$AGENT_MD"
        printf '"CONTRACTS_DIR":"%s"' "$CONTRACTS_DIR"
        printf '}'
        
        # Include presence flags for reference documents
        printf ',"REFERENCE_DOCS_PRESENT":{'
        research_present=false
        [[ -f "$RESEARCH" ]] && research_present=true
        printf '"RESEARCH":%s,' "$research_present"
        
        ui_design_present=false
        [[ -f "$UI_DESIGN" ]] && ui_design_present=true
        printf '"UI_DESIGN":%s,' "$ui_design_present"
        
        data_model_present=false
        [[ -f "$DATA_MODEL" ]] && data_model_present=true
        printf '"DATA_MODEL":%s,' "$data_model_present"
        
        quickstart_present=false
        [[ -f "$QUICKSTART" ]] && quickstart_present=true
        printf '"QUICKSTART":%s,' "$quickstart_present"
        
        agent_md_present=false
        [[ -f "$AGENT_MD" ]] && agent_md_present=true
        printf '"AGENT_MD":%s,' "$agent_md_present"
        
        contracts_dir_present=false
        [[ -d "$CONTRACTS_DIR" && -n $(ls -A "$CONTRACTS_DIR" 2>/dev/null) ]] && contracts_dir_present=true
        printf '"CONTRACTS_DIR":%s' "$contracts_dir_present"
        printf '}'
    fi

    printf '}'
    printf '\n'
    exit 0
fi

if [[ "$PATHS_ONLY" == true ]]; then
    echo "FEATURE_DIR=$FEATURE_DIR"
    echo "PRD=$PRD"
    echo "TECHSPEC=$TECHSPEC"
    echo "TASKS=$TASKS"
    exit 0
fi

echo "Repo: $REPO_ROOT"
echo "Branch: $CURRENT_BRANCH"
echo "Feature dir: $FEATURE_DIR"
echo "PRD: $PRD"
echo "TechSpec: $TECHSPEC"
echo "Tasks: $TASKS"
echo "Available: ${available[*]}"
