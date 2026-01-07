#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

JSON=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON=true; shift ;;
        *) shift ;;
    esac
done

EVAL_OUTPUT="$(get_feature_paths)"
# shellcheck disable=SC2086
eval "$EVAL_OUTPUT"

SPECS_DIR="$REPO_ROOT/_docs/specs"
mkdir -p "$SPECS_DIR"
mkdir -p "$FEATURE_DIR"

# Ensure TECHSPEC exists
if [[ ! -f "$TECHSPEC" ]]; then
    template="$REPO_ROOT/_docs/templates/techspec-template.md"
    if [[ -f "$template" ]]; then
        cp "$template" "$TECHSPEC"
    else
        touch "$TECHSPEC"
    fi
fi

if [[ "$JSON" == true ]]; then
    printf '{"PRD":"%s","FEATURE_SPEC":"%s","TECHSPEC":"%s","IMPL_PLAN":"%s","SPECS_DIR":"%s","BRANCH":"%s","FEATURE_DIR":"%s"}\n' "$PRD" "$PRD" "$TECHSPEC" "$TECHSPEC" "$SPECS_DIR" "$CURRENT_BRANCH" "$FEATURE_DIR"
else
    echo "PRD: $PRD"
    echo "TECHSPEC: $TECHSPEC"
    echo "SPECS_DIR: $SPECS_DIR"
    echo "BRANCH: $CURRENT_BRANCH"
    echo "FEATURE_DIR: $FEATURE_DIR"
fi
