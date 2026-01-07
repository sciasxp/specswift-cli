# SpecSwift CLI Tests

This directory contains BATS (Bash Automated Testing System) tests for the SpecSwift CLI.

## Test Structure

- `cli.bats` - Tests for CLI commands (init, install, doctor, help, etc.)
- `installation.bats` - Tests for installation/uninstallation process
- `test_helper/` - BATS helper libraries

## Running Tests

### Run all tests:
```bash
bats tests/
```

### Run specific test file:
```bash
bats tests/cli.bats
bats tests/installation.bats
```

### Run specific test:
```bash
bats tests/cli.bats::specswift\ --version\ returns\ version
```

### Run tests with verbose output:
```bash
bats --verbose tests/
```

### Run tests with timing information:
```bash
bats --timing tests/
```

## Installing BATS

### macOS:
```bash
brew install bats-core
```

### Linux:
```bash
npm install -g bats
```

## Adding New Tests

1. Create a new `.bats` file in the `tests/` directory
2. Follow the naming convention: `feature-name.bats`
3. Use the `setup()` and `teardown()` functions for test isolation
4. Use `assert_success`, `assert_failure`, `assert_output` from bats-assert

## Test Helpers

The `test_helper/` directory contains:
- `bats-support/` - Additional BATS support functions
- `bats-assert/` - Assertion library for BATS

To install helpers:
```bash
cd tests/test_helper
git clone https://github.com/bats-core/bats-support.git
git clone https://github.com/bats-core/bats-assert.git
```

Or download them manually from:
- https://github.com/bats-core/bats-support
- https://github.com/bats-core/bats-assert
