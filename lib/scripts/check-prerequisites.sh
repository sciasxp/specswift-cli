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
