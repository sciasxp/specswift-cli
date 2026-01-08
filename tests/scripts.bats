#!/usr/bin/env bats
#
# BATS tests for helper scripts (token reduction automation)
#

load 'test_helper/bats-support/load.bash'
load 'test_helper/bats-assert/load.bash'

setup() {
  TEST_DIR=$(mktemp -d)
  export TEST_DIR
  export SPECswift_BIN="$PWD/bin/specswift"
}

teardown() {
  rm -rf "$TEST_DIR"
}

_make_project_with_feature() {
  local project_dir="$1"
  local short_name="$2"

  run "$SPECswift_BIN" init "$project_dir" --editor cursor --no-git --no-deps
  assert_success

  cd "$project_dir"

  mkdir -p _docs
  cat > README.md <<'EOF'
# Test Project
EOF
  cat > _docs/PRODUCT.md <<'EOF'
# Product
EOF
  cat > _docs/STRUCTURE.md <<'EOF'
# Structure
EOF
  cat > _docs/TECH.md <<'EOF'
# Tech
EOF

  mkdir -p "_docs/specs/$short_name"

  cat > "_docs/specs/$short_name/prd.md" <<'EOF'
# PRD: Test Feature

### US1: Login (Priority: P1)

### Edge Cases
- Offline: show error

### Functional Requirements
- **FR-001**: System MUST allow login
EOF

  cat > "_docs/specs/$short_name/techspec.md" <<'EOF'
# TechSpec: Test Feature

## Technical Context
**Architecture**: MVVM
EOF

  cat > "_docs/specs/$short_name/tasks.md" <<'EOF'
# Tasks: test-feature

## Phase 1: Setup

- [ ] T001 [US1] Implement login (FR-001) in `Sources/Auth/Login.swift`
  - **Acceptance Criteria**:
    - [ ] FR-001 satisfied
  - **Unit Tests**:
    - [ ] `test_login_success()`
EOF

  export SPECSWIFT_FEATURE="feature/$short_name"
}

@test "context-pack.sh outputs JSON" {
  _make_project_with_feature "$TEST_DIR/proj-context" "test-feature"

  run bash -c "./_docs/scripts/bash/context-pack.sh --json --include-artifacts | python3 -c 'import json,sys; j=json.load(sys.stdin); assert j[\"ok\"] is True; assert \"docs\" in j; print(\"ok\")'"
  assert_success
  assert_output --partial "ok"
}

@test "extract-artifacts.sh extracts FR and US from PRD" {
  _make_project_with_feature "$TEST_DIR/proj-extract" "test-feature"

  run bash -c "./_docs/scripts/bash/extract-artifacts.sh --json | python3 -c 'import json,sys; j=json.load(sys.stdin); assert j[\"ok\"] is True; assert j[\"prd\"][\"exists\"] is True; assert any(x[\"id\"]==\"FR-001\" for x in j[\"prd\"][\"fr\"]); assert any(x[\"id\"]==\"US1\" for x in j[\"prd\"][\"user_stories\"]); print(\"ok\")'"
  assert_success
  assert_output --partial "ok"
}

@test "validate-tasks.sh passes when sections and FR tags exist" {
  _make_project_with_feature "$TEST_DIR/proj-validate-ok" "test-feature"

  run bash -c "./_docs/scripts/bash/validate-tasks.sh --json --include-report | python3 -c 'import json,sys; j=json.load(sys.stdin); assert j[\"ok\"] is True; assert \"report_md\" in j; print(\"ok\")'"
  assert_success
  assert_output --partial "ok"
}

@test "tasks-to-issues.sh dry-run outputs plan JSON" {
  _make_project_with_feature "$TEST_DIR/proj-issues" "test-feature"

  run bash -c "./_docs/scripts/bash/tasks-to-issues.sh --json --dry-run --repo octo/test --label specswift | python3 -c 'import json,sys; j=json.load(sys.stdin); assert j[\"ok\"] is True; assert j[\"dry_run\"] is True; assert j[\"repo\"]==\"octo/test\"; assert j[\"open_tasks\"]==1; print(\"ok\")'"
  assert_success
  assert_output --partial "ok"
}

@test "generate-agent-md.sh creates .agent.md preserving manual markers" {
  _make_project_with_feature "$TEST_DIR/proj-agent" "test-feature"

  run bash -c "./_docs/scripts/bash/generate-agent-md.sh --json | python3 -c 'import json,sys; j=json.load(sys.stdin); assert j[\"ok\"] is True; print(\"ok\")'"
  assert_success

  [ -f "_docs/specs/test-feature/.agent.md" ]
  run bash -c "grep -q \"MANUAL ADDITIONS START\" \"_docs/specs/test-feature/.agent.md\" && echo ok"
  assert_success
  assert_output --partial "ok"
}

@test "specswift validate tasks delegates to project script" {
  _make_project_with_feature "$TEST_DIR/proj-cli-validate" "test-feature"

  run bash -c "\"$SPECswift_BIN\" validate tasks --include-report | python3 -c 'import json,sys; j=json.load(sys.stdin); assert j[\"ok\"] is True; print(\"ok\")'"
  assert_success
  assert_output --partial "ok"
}

