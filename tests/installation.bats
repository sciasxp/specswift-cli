#!/usr/bin/env bats
#
# BATS tests for SpecSwift installation
#

load 'test_helper/bats-support/load.bash'
load 'test_helper/bats-assert/load.bash'

setup() {
  TEST_DIR=$(mktemp -d)
  export TEST_DIR
  export INSTALL_SCRIPT="$PWD/install.sh"
  export SPECswift_BIN="$PWD/bin/specswift"
}

teardown() {
  # Clean up temporary directory
  rm -rf "$TEST_DIR"
}

@test "install.sh --help shows help" {
  run "$INSTALL_SCRIPT" --help
  assert_success
  assert_output --partial "Usage"
}

@test "install.sh installs to default prefix" {
  run "$INSTALL_SCRIPT" --prefix "$TEST_DIR/install"
  assert_success
  
  # Verify bin directory was created
  [ -d "$TEST_DIR/install/bin" ]
  
  # Verify specswift executable was copied
  [ -f "$TEST_DIR/install/bin/specswift" ]
  
  # Verify specswift is executable
  [ -x "$TEST_DIR/install/bin/specswift" ]
}

@test "install.sh copies lib directory" {
  run "$INSTALL_SCRIPT" --prefix "$TEST_DIR/install"
  assert_success
  
  # Verify lib directory was created (now under lib/specswift)
  [ -d "$TEST_DIR/install/lib/specswift" ]
  
  # Verify workflows were copied
  [ -d "$TEST_DIR/install/lib/specswift/lib/workflows" ]
  [ -d "$TEST_DIR/install/lib/specswift/lib/workflows/en" ]
  [ -d "$TEST_DIR/install/lib/specswift/lib/workflows/pt" ]
  
  # Verify templates were copied
  [ -d "$TEST_DIR/install/lib/specswift/lib/templates" ]
  
  # Verify scripts were copied
  [ -d "$TEST_DIR/install/lib/specswift/lib/scripts" ]
}

@test "install.sh copies docs directory" {
  run "$INSTALL_SCRIPT" --prefix "$TEST_DIR/install"
  assert_success
  
  # Verify docs directory was created (now under lib/specswift)
  [ -d "$TEST_DIR/install/lib/specswift/docs" ]
  
  # Verify SPECSWIFT-WORKFLOWS.md was copied
  [ -f "$TEST_DIR/install/lib/specswift/docs/SPECSWIFT-WORKFLOWS.md" ]
}

@test "install.sh creates symbolic link" {
  run "$INSTALL_SCRIPT" --prefix "$TEST_DIR/install"
  assert_success
  
  # Verify symbolic link was created
  [ -L "$TEST_DIR/install/bin/specswift" ]
}

@test "install.sh --uninstall removes files" {
  # First install
  run "$INSTALL_SCRIPT" --prefix "$TEST_DIR/install"
  assert_success
  
  # Then uninstall
  run "$INSTALL_SCRIPT" --uninstall --prefix "$TEST_DIR/install"
  assert_success
  
  # Verify symbolic link was removed
  [ ! -L "$TEST_DIR/install/bin/specswift" ]
}

@test "install.sh --uninstall removes lib directory" {
  # First install
  run "$INSTALL_SCRIPT" --prefix "$TEST_DIR/install"
  assert_success
  
  # Then uninstall
  run "$INSTALL_SCRIPT" --uninstall --prefix "$TEST_DIR/install"
  assert_success
  
  # Verify specswift lib directory was removed
  [ ! -d "$TEST_DIR/install/lib/specswift" ]
}

@test "installed specswift works" {
  run "$INSTALL_SCRIPT" --prefix "$TEST_DIR/install"
  assert_success
  
  # Test that installed specswift works
  run "$TEST_DIR/install/bin/specswift" --version
  assert_success
  assert_output --regexp "SpecSwift CLI v[0-9]+\.[0-9]+\.[0-9]+"
}

@test "installed specswift doctor works" {
  run "$INSTALL_SCRIPT" --prefix "$TEST_DIR/install"
  assert_success
  
  # Test that installed specswift doctor works
  run "$TEST_DIR/install/bin/specswift" doctor
  assert_success
  assert_output --partial "Checking Installation"
}

@test "install.sh handles existing installation" {
  # First install
  run "$INSTALL_SCRIPT" --prefix "$TEST_DIR/install"
  assert_success
  
  # Try to install again without --force
  run "$INSTALL_SCRIPT" --prefix "$TEST_DIR/install"
  assert_failure
  
  # Try to install again with --force
  run "$INSTALL_SCRIPT" --force --prefix "$TEST_DIR/install"
  assert_success
}

@test "install.sh validates VERSION file" {
  # Modify VERSION file to invalid format
  echo "invalid" > VERSION
  
  run "$INSTALL_SCRIPT" --prefix "$TEST_DIR/install"
  # Should still work with fallback version
  assert_success
  
  # Restore VERSION
  git checkout VERSION 2>/dev/null || echo "1.0.0" > VERSION
}
