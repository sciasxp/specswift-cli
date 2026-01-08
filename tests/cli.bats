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
  
  # Verify workflows were copied (Cursor uses "commands" directory)
  [ -d "$TEST_DIR/test-project-cursor/.cursor/commands" ]
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
  
  # Verify .cursor directory was created (Cursor uses "commands" directory)
  [ -d ".cursor/commands" ]
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

@test "specswift init enters interactive mode when no directory argument provided" {
  # When no directory is provided and no CLI options, it should enter interactive mode
  # Provide minimal input to trigger interactive mode and then cancel
  run bash -c "printf '%s\n' \"\" \"\" \"\" \"\" \"\" \"\" \"\" \"\" \"\" \"no\" | \"$SPECswift_BIN\" init 2>&1 || true"
  # The command should start interactive mode (not fail with "Target directory not specified")
  assert_output --partial "Interactive Mode"
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

# =============================================================================
# Interactive Mode Tests
# =============================================================================

@test "specswift init enters interactive mode when no arguments provided" {
  # Simulate interactive input:
  # - Directory: TEST_DIR/test-interactive
  # - Editor: 1 (cursor)
  # - Language: 1 (English)
  # - iOS mode: no (simpler, no template prompts)
  # - Git init: yes
  # - Check deps: no (to speed up test and avoid prompts)
  # - Verbose: no
  # - Force: no
  # - Confirm: yes
  run bash -c "printf '%s\n' \"$TEST_DIR/test-interactive\" \"1\" \"1\" \"no\" \"yes\" \"no\" \"no\" \"no\" \"yes\" | \"$SPECswift_BIN\" init"
  assert_success
  
  # Verify directory was created
  [ -d "$TEST_DIR/test-interactive" ]
  
  # Verify .cursor directory exists (editor 1 = cursor)
  [ -d "$TEST_DIR/test-interactive/.cursor" ]
  
  # Verify workflows were copied (Cursor uses "commands" directory)
  [ -d "$TEST_DIR/test-interactive/.cursor/commands" ]
  [ -d "$TEST_DIR/test-interactive/.cursor/rules" ]
  
  # Verify _docs directory exists
  [ -d "$TEST_DIR/test-interactive/_docs" ]
  
  # Verify Makefile was created
  [ -f "$TEST_DIR/test-interactive/Makefile" ]
}

@test "specswift install enters interactive mode when no arguments provided" {
  # Create a dummy project directory
  mkdir -p "$TEST_DIR/existing-project-interactive"
  cd "$TEST_DIR/existing-project-interactive"
  
  # Simulate interactive input:
  # - Editor: 2 (windsurf)
  # - Language: 1 (English)
  # - iOS mode: no
  # - Check deps: no (to speed up test)
  # - Verbose: no
  # - Force: no
  # - Confirm: yes
  run bash -c "printf '%s\n' \"2\" \"1\" \"no\" \"no\" \"no\" \"no\" \"yes\" | \"$SPECswift_BIN\" install"
  assert_success
  
  # Verify .windsurf directory was created (editor 2 = windsurf)
  [ -d ".windsurf/workflows" ]
  [ -d ".windsurf/rules" ]
  
  # Verify _docs directory was created
  [ -d "_docs/templates" ]
  
  # Verify .cursor directory was NOT created
  [ ! -d ".cursor" ]
}

@test "specswift init interactive mode can be cancelled" {
  # Simulate cancellation by answering "no" to confirmation
  # - Directory: TEST_DIR/test-cancel
  # - Editor: 1 (cursor)
  # - Language: 1 (English)
  # - iOS mode: no
  # - Git init: yes
  # - Check deps: no
  # - Verbose: no
  # - Force: no
  # - Confirm: no (cancel)
  run bash -c "printf '%s\n' \"$TEST_DIR/test-cancel\" \"1\" \"1\" \"no\" \"yes\" \"no\" \"no\" \"no\" \"no\" | \"$SPECswift_BIN\" init"
  assert_success
  
  # Verify directory was NOT created (operation cancelled)
  [ ! -d "$TEST_DIR/test-cancel" ]
}

@test "specswift init with CLI options does not enter interactive mode" {
  # When directory and options are provided, should use CLI mode
  run "$SPECswift_BIN" init "$TEST_DIR/test-cli-mode" --editor cursor --no-git
  assert_success
  
  # Verify directory was created
  [ -d "$TEST_DIR/test-cli-mode" ]
  
  # Verify .cursor directory exists
  [ -d "$TEST_DIR/test-cli-mode/.cursor" ]
  
  # Verify .git directory was NOT created (--no-git flag)
  [ ! -d "$TEST_DIR/test-cli-mode/.git" ]
}

@test "specswift install with CLI options does not enter interactive mode" {
  # Create a dummy project directory
  mkdir -p "$TEST_DIR/existing-project-cli"
  cd "$TEST_DIR/existing-project-cli"
  
  # When options are provided, should use CLI mode
  run "$SPECswift_BIN" install --editor windsurf --no-deps
  assert_success
  
  # Verify .windsurf directory was created
  [ -d ".windsurf/workflows" ]
  
  # Verify .cursor directory was NOT created
  [ ! -d ".cursor" ]
}
