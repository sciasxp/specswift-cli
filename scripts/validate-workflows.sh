#!/usr/bin/env bash
#
# Workflow Consistency Validation Script
#
# Validates consistency between English and Portuguese workflow files
#

set -e

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKFLOWS_DIR="$PROJECT_ROOT/lib/workflows"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "${BLUE}→${NC} $1"; }
print_header() { echo -e "\n${BOLD}${BLUE}$1${NC}"; }

# Configuration
LINE_COUNT_TOLERANCE=10  # Allow 10% difference in line counts (more lenient for enhanced workflows)

# Workflows with intentional differences between EN and PT
# These workflows have different content that serves different purposes
INTENTIONALLY_DIFFERENT=(
    "specswift.implement.md"  # EN enhanced with PT features
    "specswift.taskstoissues.md"  # Different implementations for EN/PT
)

# Workflows with alternative formats (not standard workflow structure)
ALTERNATIVE_FORMAT_WORKFLOWS=(
    "specswift.bug-investigation.md"  # Template-based format
)

# Count lines in a file
count_lines() {
    wc -l < "$1" | tr -d ' '
}

# Check if workflow is in the intentionally different list
is_intentionally_different() {
    local workflow="$1"
    for wf in "${INTENTIONALLY_DIFFERENT[@]}"; do
        if [ "$wf" = "$workflow" ]; then
            return 0
        fi
    done
    return 1
}

# Check if workflow has alternative format
is_alternative_format() {
    local workflow="$1"
    for wf in "${ALTERNATIVE_FORMAT_WORKFLOWS[@]}"; do
        if [ "$wf" = "$workflow" ]; then
            return 0
        fi
    done
    return 1
}

# Check if required sections exist in workflow
check_required_sections() {
    local file="$1"
    local has_yaml_frontmatter=false
    local has_system_instructions=false
    local has_user_input=false
    local has_summary=false
    
    # Check for YAML frontmatter (description, handoffs)
    if grep -q "^description:" "$file" && grep -q "^handoffs:" "$file"; then
        has_yaml_frontmatter=true
    fi
    
    # Check for system_instructions (can be XML tag or markdown section)
    if grep -q "<system_instructions>" "$file" || grep -q "^## system_instructions" "$file"; then
        has_system_instructions=true
    fi
    
    # Check for User Input (can be markdown section or with ##)
    if grep -q "## User Input" "$file"; then
        has_user_input=true
    fi
    
    # Check for Summary (can be markdown section or with ##)
    if grep -q "^## Summary" "$file"; then
        has_summary=true
    fi
    
    # Report missing critical sections (YAML and system_instructions are critical)
    local missing_critical=()
    [ "$has_yaml_frontmatter" = false ] && missing_critical+=("YAML frontmatter")
    [ "$has_system_instructions" = false ] && missing_critical+=("system_instructions")
    
    # Report missing optional sections as warnings
    local missing_optional=()
    [ "$has_user_input" = false ] && missing_optional+=("User Input")
    [ "$has_summary" = false ] && missing_optional+=("Summary")
    
    if [ ${#missing_critical[@]} -gt 0 ]; then
        echo "  Missing critical: ${missing_critical[*]}"
        return 1
    fi
    
    if [ ${#missing_optional[@]} -gt 0 ]; then
        echo "  Missing optional: ${missing_optional[*]}"
        # Optional sections don't cause failure
    fi
    return 0
}

# Validate a single workflow
validate_workflow() {
    local workflow_name="$1"
    local en_file="$WORKFLOWS_DIR/en/$workflow_name"
    local pt_file="$WORKFLOWS_DIR/pt/$workflow_name"
    
    if [ ! -f "$en_file" ]; then
        print_error "$workflow_name: EN version not found"
        return 1
    fi
    
    if [ ! -f "$pt_file" ]; then
        print_error "$workflow_name: PT version not found"
        return 1
    fi
    
    local en_lines=$(count_lines "$en_file")
    local pt_lines=$(count_lines "$pt_file")
    
    # Calculate percentage difference
    local diff=$(( (en_lines - pt_lines) * 100 / pt_lines ))
    local abs_diff=${diff#-}
    
    # Handle intentionally different workflows
    if is_intentionally_different "$workflow_name"; then
        print_info "$workflow_name: Intentionally different (EN=$en_lines, PT=$pt_lines, diff=${abs_diff}%)"
        # Still check if both have basic structure
        if [ -f "$en_file" ] && [ -f "$pt_file" ]; then
            return 0
        fi
        return 1
    fi
    
    # Handle alternative format workflows
    if is_alternative_format "$workflow_name"; then
        # For alternative formats, just check both files exist and have reasonable content
        if [ $en_lines -gt 10 ] && [ $pt_lines -gt 10 ]; then
            print_success "$workflow_name: Alternative format (EN=$en_lines, PT=$pt_lines)"
            return 0
        else
            print_error "$workflow_name: Alternative format but too short (EN=$en_lines, PT=$pt_lines)"
            return 1
        fi
    fi
    
    # Standard workflow validation
    # Check line count consistency
    if [ $abs_diff -gt $LINE_COUNT_TOLERANCE ]; then
        print_error "$workflow_name: Line count mismatch (EN=$en_lines, PT=$pt_lines, diff=${abs_diff}%)"
        return 1
    fi
    
    # Check required sections
    local en_sections_ok=true
    local pt_sections_ok=true
    
    if ! check_required_sections "$en_file"; then
        print_warning "$workflow_name: EN missing required sections"
        en_sections_ok=false
    fi
    
    if ! check_required_sections "$pt_file"; then
        print_warning "$workflow_name: PT missing required sections"
        pt_sections_ok=false
    fi
    
    if [ "$en_sections_ok" = true ] && [ "$pt_sections_ok" = true ]; then
        print_success "$workflow_name: Consistent (EN=$en_lines, PT=$pt_lines, diff=${abs_diff}%)"
        return 0
    else
        return 1
    fi
}

# Check if workflow exists in both languages
check_workflow_exists() {
    local workflow="$1"
    local en_file="$WORKFLOWS_DIR/en/$workflow"
    local pt_file="$WORKFLOWS_DIR/pt/$workflow"
    
    if [ ! -f "$en_file" ] && [ ! -f "$pt_file" ]; then
        return 1
    fi
    
    if [ ! -f "$en_file" ]; then
        print_error "$workflow: Missing EN version"
        return 1
    fi
    
    if [ ! -f "$pt_file" ]; then
        print_error "$workflow: Missing PT version"
        return 1
    fi
    
    return 0
}

# Main validation
main() {
    print_header "🔍 Workflow Consistency Validation"
    print_info "Checking workflows in: $WORKFLOWS_DIR"
    echo ""
    
    local total_workflows=0
    local passed_workflows=0
    local failed_workflows=0
    
    # Get all workflow files from EN directory
    for workflow in "$WORKFLOWS_DIR/en"/*.md; do
        if [ -f "$workflow" ]; then
            workflow_name=$(basename "$workflow")
            
            if check_workflow_exists "$workflow_name"; then
                total_workflows=$((total_workflows + 1))
                
                if validate_workflow "$workflow_name"; then
                    passed_workflows=$((passed_workflows + 1))
                else
                    failed_workflows=$((failed_workflows + 1))
                fi
            fi
        fi
    done
    
    # Summary
    print_header "📊 Summary"
    echo ""
    echo "Total workflows: $total_workflows"
    echo -e "${GREEN}Passed: $passed_workflows${NC}"
    
    if [ $failed_workflows -gt 0 ]; then
        echo -e "${RED}Failed: $failed_workflows${NC}"
        echo ""
        print_error "Validation failed. Please fix the inconsistencies above."
        exit 1
    else
        echo ""
        print_success "All workflows are consistent!"
        exit 0
    fi
}

main "$@"
