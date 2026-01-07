#!/usr/bin/env bash

set -e

JSON_MODE=false
BRANCH_TYPE="feature"
SHORT_NAME=""
ARGS=()
i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json) 
            JSON_MODE=true 
            ;;
        --type)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --type requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --type requires a value' >&2
                exit 1
            fi
            BRANCH_TYPE="$next_arg"
            ;;
        --name|--short-name)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --name requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --name requires a value' >&2
                exit 1
            fi
            SHORT_NAME="$next_arg"
            ;;
        --help|-h) 
            echo "Usage: $0 [--json] [--type <feature|fix|hotfix>] --name <short-name> <feature_description>"
            echo ""
            echo "Options:"
            echo "  --json              Output in JSON format"
            echo "  --type <type>       Branch type: feature (default), fix, hotfix"
            echo "  --name <short-name> Short name for the feature (kebab-case, 2-4 words)"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --name add-user-auth 'Add user authentication system'"
            echo "  $0 --type fix --name fix-login-crash 'Fix crash on login'"
            echo "  $0 --json --name panel-detection 'Improve panel detection accuracy'"
            exit 0
            ;;
        *) 
            ARGS+=("$arg") 
            ;;
    esac
    i=$((i + 1))
done

FEATURE_DESCRIPTION="${ARGS[*]}"
if [ -z "$FEATURE_DESCRIPTION" ]; then
    echo "Usage: $0 [--json] [--type <feature|fix|hotfix>] --name <short-name> <feature_description>" >&2
    exit 1
fi

# Function to find the repository root by searching for existing project markers
find_repo_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] || [ -d "$dir/.specify" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Function to get highest number from specs directory
get_highest_from_specs() {
    local specs_dir="$1"
    local highest=0
    
    if [ -d "$specs_dir" ]; then
        for dir in "$specs_dir"/*; do
            [ -d "$dir" ] || continue
            dirname=$(basename "$dir")
            number=$(echo "$dirname" | grep -o '^[0-9]\+' || echo "0")
            number=$((10#$number))
            if [ "$number" -gt "$highest" ]; then
                highest=$number
            fi
        done
    fi
    
    echo "$highest"
}

# Function to get highest number from git branches
get_highest_from_branches() {
    local highest=0
    
    # Get all branches (local and remote)
    branches=$(git branch -a 2>/dev/null || echo "")
    
    if [ -n "$branches" ]; then
        while IFS= read -r branch; do
            # Clean branch name: remove leading markers and remote prefixes
            clean_branch=$(echo "$branch" | sed 's/^[* ]*//; s|^remotes/[^/]*/||')
            
            # Extract feature number if branch matches pattern ###-*
            if echo "$clean_branch" | grep -q '^[0-9]\{3\}-'; then
                number=$(echo "$clean_branch" | grep -o '^[0-9]\{3\}' || echo "0")
                number=$((10#$number))
                if [ "$number" -gt "$highest" ]; then
                    highest=$number
                fi
            fi
        done <<< "$branches"
    fi
    
    echo "$highest"
}

# Function to check existing branches (local and remote) and return next available number
check_existing_branches() {
    local specs_dir="$1"

    # Fetch all remotes to get latest branch info (suppress errors if no remotes)
    git fetch --all --prune 2>/dev/null || true

    # Get highest number from ALL branches (not just matching short name)
    local highest_branch=$(get_highest_from_branches)

    # Get highest number from ALL specs (not just matching short name)
    local highest_spec=$(get_highest_from_specs "$specs_dir")

    # Take the maximum of both
    local max_num=$highest_branch
    if [ "$highest_spec" -gt "$max_num" ]; then
        max_num=$highest_spec
    fi

    # Return next number
    echo $((max_num + 1))
}

# Function to clean and format a branch name
clean_branch_name() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

# Function to generate branch name with stop word filtering
generate_branch_name() {
    local description="$1"
    local stop_words="^(i|a|an|the|to|for|of|in|on|at|by|with|from|is|are|was|were|be|been|being|have|has|had|do|does|did|will|would|should|could|can|may|might|must|shall|this|that|these|those|my|your|our|their|want|need|add|get|set)$"
    local clean_name=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g')
    local meaningful_words=()
    for word in $clean_name; do
        [ -z "$word" ] && continue
        if ! echo "$word" | grep -qiE "$stop_words"; then
            if [ ${#word} -ge 3 ]; then
                meaningful_words+=("$word")
            fi
        fi
    done
    if [ ${#meaningful_words[@]} -gt 0 ]; then
        local max_words=3
        local result=""
        local count=0
        for word in "${meaningful_words[@]}"; do
            if [ $count -ge $max_words ]; then break; fi
            if [ -n "$result" ]; then result="$result-"; fi
            result="$result$word"
            count=$((count + 1))
        done
        echo "$result"
    else
        local cleaned=$(clean_branch_name "$description")
        echo "$cleaned" | tr '-' '\n' | grep -v '^$' | head -3 | tr '\n' '-' | sed 's/-$//'
    fi
}

# Resolve repository root. Prefer git information when available, but fall back
# to searching for repository markers so the workflow still functions in repositories that
# were initialised with --no-git.
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
    REPO_ROOT=$(git rev-parse --show-toplevel)
    HAS_GIT=true
else
    REPO_ROOT="$(find_repo_root "$SCRIPT_DIR")"
    if [ -z "$REPO_ROOT" ]; then
        echo "Error: Could not determine repository root. Please run this script from within the repository." >&2
        exit 1
    fi
    HAS_GIT=false
fi

cd "$REPO_ROOT"

SPECS_DIR="$REPO_ROOT/_docs/specs"
mkdir -p "$SPECS_DIR"

# If SHORT_NAME not provided, generate from description
if [ -z "$SHORT_NAME" ]; then
    SHORT_NAME=$(generate_branch_name "$FEATURE_DESCRIPTION")
fi

# Clean SHORT_NAME to ensure it's valid
SHORT_NAME=$(clean_branch_name "$SHORT_NAME")

if [ -z "$SHORT_NAME" ]; then
    echo "Error: Could not determine feature name. Provide --name <short-name> or a valid description." >&2
    exit 1
fi

if [[ ! "$BRANCH_TYPE" =~ ^(feature|fix|hotfix)$ ]]; then
    echo "Error: Invalid --type '$BRANCH_TYPE'. Expected: feature, fix, or hotfix." >&2
    exit 1
fi

BRANCH_NAME="${BRANCH_TYPE}/${SHORT_NAME}"

if [ "$HAS_GIT" = true ]; then
    git checkout -b "$BRANCH_NAME"
else
    >&2 echo "[specify] Warning: Git repository not detected; skipped branch creation for $BRANCH_NAME"
fi

FEATURE_DIR="$SPECS_DIR/$SHORT_NAME"
mkdir -p "$FEATURE_DIR"

TEMPLATE="$REPO_ROOT/_docs/templates/prd-template.md"
PRD_FILE="$FEATURE_DIR/prd.md"
if [ -f "$TEMPLATE" ]; then cp "$TEMPLATE" "$PRD_FILE"; else touch "$PRD_FILE"; fi

# Set the SPECIFY_FEATURE environment variable for the current session
export SPECIFY_FEATURE="$BRANCH_NAME"

if $JSON_MODE; then
    printf '{"BRANCH_NAME":"%s","PRD_FILE":"%s","FEATURE_DIR":"%s","SHORT_NAME":"%s","TYPE":"%s"}\n' "$BRANCH_NAME" "$PRD_FILE" "$FEATURE_DIR" "$SHORT_NAME" "$BRANCH_TYPE"
else
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "PRD_FILE: $PRD_FILE"
    echo "FEATURE_DIR: $FEATURE_DIR"
    echo "SHORT_NAME: $SHORT_NAME"
    echo "TYPE: $BRANCH_TYPE"
    echo "SPECIFY_FEATURE environment variable set to: $BRANCH_NAME"
fi
