#!/usr/bin/env bats
#
# BATS tests for SpecSwift CLI
#

load 'test_helper/bats-support/load.bash'
load 'test_helper/bats-assert/load.bash'

setup() {
  # Create temporary directory for tests
  TEST_DIR=$(mktemp -d)
  export TEST_DIR
  export SPECswift_BIN="$PWD/bin/specswift"
}

teardown() {
  # Clean up temporary directory
  rm -rf "$TEST_DIR"
}

@test "specswift --version returns version" {
  run "$SPECswift_BIN" --version
  assert_success
  assert_output --regexp "SpecSwift CLI v[0-9]+\.[0-9]+\.[0-9]+"
}

@test "specswift --help shows help" {
  run "$SPECswift_BIN" --help
  assert_success
  assert_output --partial "USAGE"
  assert_output --partial "COMMANDS"
}

@test "specswift help shows help" {
  run "$SPECswift_BIN" help
  assert_success
  assert_output --partial "USAGE"
  assert_output --partial "COMMANDS"
}

@test "specswift init with --editor cursor creates .cursor directory" {
  run "$SPECswift_BIN" init "$TEST_DIR/test-project-cursor" --editor cursor
  assert_success
  
  # Verify directory was created
  [ -d "$TEST_DIR/test-project-cursor" ]
  
  # Verify .cursor directory exists
  [ -d "$TEST_DIR/test-project-cursor/.cursor" ]
  
  # Verify workflows were copied
  [ -d "$TEST_DIR/test-project-cursor/.cursor/workflows" ]
  [ -d "$TEST_DIR/test-project-cursor/.cursor/rules" ]
  
  # Verify _docs directory exists
  [ -d "$TEST_DIR/test-project-cursor/_docs" ]
  
  # Verify templates were copied
  [ -d "$TEST_DIR/test-project-cursor/_docs/templates" ]
  
  # Verify Makefile was created
  [ -f "$TEST_DIR/test-project-cursor/Makefile" ]
  
  # Verify .windsurf directory was NOT created
  [ ! -d "$TEST_DIR/test-project-cursor/.windsurf" ]
}

@test "specswift init with --editor windsurf creates .windsurf directory" {
  run "$SPECswift_BIN" init "$TEST_DIR/test-project-windsurf" --editor windsurf
  assert_success
  
  # Verify directory was created
  [ -d "$TEST_DIR/test-project-windsurf" ]
  
  # Verify .windsurf directory exists
  [ -d "$TEST_DIR/test-project-windsurf/.windsurf" ]
  
  # Verify workflows were copied
  [ -d "$TEST_DIR/test-project-windsurf/.windsurf/workflows" ]
  [ -d "$TEST_DIR/test-project-windsurf/.windsurf/rules" ]
  
  # Verify _docs directory exists
  [ -d "$TEST_DIR/test-project-windsurf/_docs" ]
  
  # Verify templates were copied
  [ -d "$TEST_DIR/test-project-windsurf/_docs/templates" ]
  
  # Verify Makefile was created
  [ -f "$TEST_DIR/test-project-windsurf/Makefile" ]
  
  # Verify .cursor directory was NOT created
  [ ! -d "$TEST_DIR/test-project-windsurf/.cursor" ]
}

@test "specswift init with --ios flag creates iOS Makefile" {
  run "$SPECswift_BIN" init "$TEST_DIR/test-ios-project" --ios --editor cursor
  assert_success
  
  # Verify Makefile contains iOS-specific targets
  grep -q "xcodebuild" "$TEST_DIR/test-ios-project/Makefile"
  grep -q "SCHEME" "$TEST_DIR/test-ios-project/Makefile"
}

@test "specswift init with --no-git skips git initialization" {
  run "$SPECswift_BIN" init "$TEST_DIR/test-no-git" --no-git --editor cursor
  assert_success
  
  # Verify .git directory was NOT created
  [ ! -d "$TEST_DIR/test-no-git/.git" ]
}

@test "specswift doctor checks installation" {
  run "$SPECswift_BIN" doctor
  assert_success
  assert_output --partial "Checking Installation"
}

@test "specswift doctor reports workflows count" {
  run "$SPECswift_BIN" doctor
  assert_success
  assert_output --partial "Workflows:"
  assert_output --regexp "[Ww]orkflows: [0-9]+ files"
}

@test "specswift doctor reports templates count" {
  run "$SPECswift_BIN" doctor
  assert_success
  assert_output --partial "Templates:"
  assert_output --regexp "[Tt]emplates: [0-9]+ files"
}

@test "specswift doctor reports rules count" {
  run "$SPECswift_BIN" doctor
  assert_success
  assert_output --partial "Rules:"
  assert_output --regexp "[Rr]ules: [0-9]+ files"
}

@test "specswift --lang pt shows Portuguese help" {
  run "$SPECswift_BIN" --lang pt help
  assert_success
  assert_output --partial "USO"
  assert_output --partial "COMANDOS"
}

@test "specswift --lang en shows English help" {
  run "$SPECswift_BIN" --lang en help
  assert_success
  assert_output --partial "USAGE"
  assert_output --partial "COMMANDS"
}

@test "specswift install with --editor cursor works in existing directory" {
  # Create a dummy project directory
  mkdir -p "$TEST_DIR/existing-project-cursor"
  cd "$TEST_DIR/existing-project-cursor"
  
  run "$SPECswift_BIN" install --editor cursor
  assert_success
  
  # Verify .cursor directory was created
  [ -d ".cursor/workflows" ]
  [ -d ".cursor/rules" ]
  
  # Verify _docs directory was created
  [ -d "_docs/templates" ]
  
  # Verify .windsurf directory was NOT created
  [ ! -d ".windsurf" ]
}

@test "specswift install with --editor windsurf works in existing directory" {
  # Create a dummy project directory
  mkdir -p "$TEST_DIR/existing-project-windsurf"
  cd "$TEST_DIR/existing-project-windsurf"
  
  run "$SPECswift_BIN" install --editor windsurf
  assert_success
  
  # Verify .windsurf directory was created
  [ -d ".windsurf/workflows" ]
  [ -d ".windsurf/rules" ]
  
  # Verify _docs directory was created
  [ -d "_docs/templates" ]
  
  # Verify .cursor directory was NOT created
  [ ! -d ".cursor" ]
}

@test "specswift init requires directory argument" {
  run "$SPECswift_BIN" init
  assert_failure
  assert_output --partial "Target directory not specified"
}

@test "specswift unknown command shows error" {
  run "$SPECswift_BIN" nonexistent-command
  assert_failure
  assert_output --partial "Unknown command"
}

# Note: --verbose and --quiet are documented but not yet implemented as global options
# These tests are skipped until the functionality is implemented

@test "VERSION file exists" {
  [ -f "$PWD/VERSION" ]
}

@test "VERSION file contains valid version" {
  run cat VERSION
  assert_success
  assert_output --regexp "^[0-9]+\.[0-9]+\.[0-9]+$"
}

@test "bin/specswift reads from VERSION file" {
  # Verify that specswift uses VERSION file dynamically
  run grep "VERSION_FILE=" bin/specswift
  assert_success
  run grep 'cat "$VERSION_FILE"' bin/specswift
  assert_success
}

@test "install.sh reads from VERSION file" {
  # Verify that install.sh uses VERSION file dynamically
  run grep "VERSION_FILE=" install.sh
  assert_success
  run grep 'cat "$VERSION_FILE"' install.sh
  assert_success
}

@test "specswift init with invalid --editor shows error" {
  run "$SPECswift_BIN" init "$TEST_DIR/test-invalid-editor" --editor invalid
  assert_failure
  assert_output --partial "Invalid editor"
}
