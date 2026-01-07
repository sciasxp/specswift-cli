#!/usr/bin/env bash

set -e

JSON=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON=true; shift ;;
        --verbose) VERBOSE=true; shift ;;
        *) shift ;;
    esac
done

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

REPO_ROOT="$(get_repo_root)"

REQUIRED_FILES=(
    "README.md"
    "_docs/PRODUCT.md"
    "_docs/STRUCTURE.md"
    "_docs/TECH.md"
)

missing=()
for rel in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$REPO_ROOT/$rel" ]]; then
        missing+=("$rel")
    fi
done

all_present=false
if [[ ${#missing[@]} -eq 0 ]]; then
    all_present=true
fi

if [[ "$JSON" == true ]]; then
    printf '{"repo_root":"%s","all_present":%s,"missing":[' "$REPO_ROOT" "$all_present"
    for i in "${!missing[@]}"; do
        [[ $i -gt 0 ]] && printf ','
        printf '"%s"' "${missing[$i]}"
    done
    printf ']}'
    printf '\n'
    exit 0
fi

if [[ "$all_present" == true ]]; then
    echo "OK: project documentation is complete"
    exit 0
fi

echo "Missing required project documentation:"
for rel in "${missing[@]}"; do
    echo "- $rel"
done

if [[ "$VERBOSE" == true ]]; then
    echo ""
    echo "Repo root: $REPO_ROOT"
fi

exit 1
