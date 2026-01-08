# CI/CD with GitHub Actions

This document describes the automated testing and CI/CD pipeline for SpecSwift CLI using GitHub Actions.

## Overview

The CI/CD pipeline automatically runs on every push and pull request to the `main` and `develop` branches, ensuring code quality and preventing regressions.

## Workflow File

**Status:** ✅ Implemented

Location: `.github/workflows/test.yml`

The CI/CD pipeline is fully implemented and runs automatically on every push and pull request to `main` and `develop` branches.

## Jobs

### 1. Lint Scripts

**Purpose:** Run shellcheck on all bash scripts to catch syntax errors and common issues.

**Steps:**
- Checkout code
- Install shellcheck
- Run shellcheck on:
  - `bin/specswift`
  - `lib/scripts/*.sh`
  - `install.sh`
  - `scripts/validate-workflows.sh`

**Failure Conditions:**
- Shellcheck finds any issues in the scripts

### 2. Validate Workflow Consistency

**Purpose:** Ensure English and Portuguese workflow files remain consistent.

**Steps:**
- Checkout code
- Run `./scripts/validate-workflows.sh`

**What it checks:**
- Line count consistency (within 10% tolerance)
- Required sections (YAML frontmatter, system_instructions)
- Handles intentionally different workflows (implement, taskstoissues)
- Handles alternative format workflows (bug-investigation)

**Failure Conditions:**
- Critical sections missing
- Line count difference exceeds 10%
- Files missing in either language

### 3. Test CLI Commands

**Purpose:** Run BATS tests for CLI functionality.

**Steps:**
- Checkout code
- Install BATS (Bash Automated Testing System)
- Run all tests in `tests/` directory

**Test Coverage:**
- Version command
- Help command
- Init command with various flags (`--ios`, `--no-git`)
- Doctor command
- Install command
- Language support (`--lang pt`, `--lang en`)
- Error handling for invalid commands
- VERSION file consistency

**Failure Conditions:**
- Any BATS test fails

### 4. Test Installation

**Purpose:** Verify installation and uninstallation work correctly.

**Steps:**
- Checkout code
- Test local installation to `/tmp/specswift-test`
- Verify installed CLI works
- Test uninstallation
- Verify files are removed

**Failure Conditions:**
- Installation fails
- Installed CLI doesn't work
- Uninstallation doesn't remove files

### 5. Verify Version Consistency

**Purpose:** Ensure VERSION file is the single source of truth.

**Steps:**
- Checkout code
- Extract version from VERSION file
- Verify `bin/specswift` uses same version
- Verify `install.sh` uses same version

**Failure Conditions:**
- Version mismatch between files

## Running Tests Locally

### Install Dependencies

```bash
# Install BATS
brew install bats-core

# Install shellcheck
brew install shellcheck
```

### Run All Tests

```bash
# Run linting
make lint

# Run workflow validation
make validate-workflows

# Run BATS tests
bats tests/
```

### Run Specific Tests

```bash
# Run only CLI tests
bats tests/cli.bats

# Run only installation tests
bats tests/installation.bats

# Run specific test
bats tests/cli.bats::specswift\ --version\ returns\ version

# Verbose output
bats --verbose tests/

# With timing
bats --timing tests/
```

## Test Helper Libraries

The tests use BATS helper libraries located in `tests/test_helper/`:

### bats-support
Provides additional BATS support functions for running commands and managing test lifecycle.

### bats-assert
Provides assertion functions like:
- `assert_success` - Command succeeded
- `assert_failure` - Command failed
- `assert_output` - Output matches pattern
- `assert_line` - Output contains line
- `assert_regex` - Output matches regex

## Adding New Tests

1. Create a new `.bats` file in `tests/`
2. Load helper libraries:
   ```bash
   load 'test_helper/bats-support/load.bash'
   load 'test_helper/bats-assert/load.bash'
   ```
3. Use `setup()` and `teardown()` for test isolation
4. Write tests using BATS syntax:
   ```bash
   @test "test description" {
       run command args
       assert_success
       assert_output --partial "expected text"
   }
   ```

## GitHub Actions Status

To check CI/CD status:
1. Go to the repository on GitHub
2. Click on "Actions" tab
3. Select the "Tests" workflow
4. View recent runs and their status

## Troubleshooting

### Tests Failing Locally

If tests fail locally but pass in CI:
- Check BATS version: `bats --version`
- Ensure helper libraries are installed in `tests/test_helper/`
- Verify you're running from the project root

### Shellcheck Errors

Common shellcheck issues:
- Unquoted variables
- Missing `set -e` in scripts
- Unused variables
- POSIX compatibility issues

Fix by following shellcheck suggestions or add exceptions with `# shellcheck disable=...`

### Workflow Validation Fails

If workflow validation fails:
1. Run `./scripts/validate-workflows.sh` locally
2. Check which workflows are inconsistent
3. Update the inconsistent workflow to match
4. Ensure both EN and PT versions have required sections

## Badge

Add CI status badge to README.md:

```markdown
[![Tests](https://github.com/sciasxp/specswift-cli/actions/workflows/test.yml/badge.svg)](https://github.com/sciasxp/specswift-cli/actions/workflows/test.yml)
```

## Future Enhancements

Potential additions to the CI/CD pipeline:

1. **Release Workflow** - Automated releases when version is bumped
2. **Code Coverage** - Track test coverage over time
3. **Performance Tests** - Benchmark CLI command performance
4. **Multi-OS Testing** - Test on Linux and Windows
5. **Security Scanning** - Scan for vulnerabilities in dependencies
6. **Documentation Build** - Verify documentation builds correctly
