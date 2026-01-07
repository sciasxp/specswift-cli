# BATS Test Helper Libraries

This directory contains BATS helper libraries.

## Installation

Run the following commands to download the helper libraries:

```bash
cd tests/test_helper
git clone https://github.com/bats-core/bats-support.git
git clone https://github.com/bats-core/bats-assert.git
```

## Libraries

### bats-support
Additional BATS support functions for:
- `run` - Run command and capture output
- `setup` / `teardown` - Test lifecycle hooks
- `skip` - Skip tests

### bats-assert
Assertion library for BATS with:
- `assert_success` - Assert command succeeded
- `assert_failure` - Assert command failed
- `assert_output` - Assert output matches pattern
- `assert_line` - Assert output contains line
- `assert_regex` - Assert output matches regex
- And many more...
