---
description: Guidelines for building, running, and testing the project using the provided Makefile.
trigger: model_decision
---

# Makefile Usage Guidelines
The project uses a `Makefile` in the root directory to standardize common development tasks. Always prefer these commands over manual `xcodebuild` or `simctl` invocations.

## Prerequisites

Before using the Makefile, ensure:
- **Xcode 16+** is installed with iOS 18+ SDK
- **Git LFS** is configured for binary model files:
  ```bash
  git lfs pull
  ```
- **xcbeautify** is installed (for formatted build output):
  ```bash
  brew install xcbeautify
  ```

## Standard Commands

### 1. Build and Run (Default)
Build the app and launch it on the simulator:
```bash
make
```
Equivalent to `make run`. This command:
- Builds the project for the simulator
- Boots the simulator if needed
- Installs the app
- Launches the app with the configured bundle ID

**When to use**: Primary development workflow—build, test, and verify changes immediately.

### 2. Build for Simulator
Build the project for the simulator without running it:
```bash
make build
```

**When to use**: 
- Verify compilation before running
- Check for build errors without launching the app
- Prepare for integration with other tools

### 3. Run Unit Tests
Execute all unit tests in the configured scheme on the simulator:
```bash
make test
```

**When to use**: 
- Validate code changes with automated tests
- Ensure no regressions before committing
- Part of the standard development cycle (build → test → run)

### 4. Build for Physical Device
Build the app for a connected physical device:
```bash
make device
```

**When to use**: 
- Test on actual hardware before release
- Verify performance and device-specific behavior
- Note: Running on physical device usually requires manual interaction in Xcode or additional tools like `ios-deploy`

### 5. Clean Project
Remove build artifacts and DerivedData associated with the project:
```bash
make clean
```

**When to use**: 
- Resolve persistent build issues
- Free up disk space
- Reset build state before major changes

### 6. Build with Raw Output (Debugging)
Build without `xcbeautify` formatting to see raw Xcode errors:
```bash
make build-raw
```

**When to use**: 
- Troubleshoot build failures with full error details
- Debug compiler warnings and errors
- When `xcbeautify` output is unclear

### 7. Display Help
Show all available commands and their descriptions:
```bash
make help
```

## Configuration

The Makefile uses the configuration defined at the top of the file. To modify the Scheme, Project, or Destination, edit the configuration section in the `Makefile`.

## Common Workflows

### Development Cycle
```bash
make build          # Compile changes
make test           # Run unit tests
make                # Build and run on simulator
```

### Testing Before Commit
```bash
make clean          # Reset build state
make test           # Run all tests
make                # Verify app launches
```

### Debugging Build Issues
```bash
make build-raw      # See full compiler output
make clean          # Clear cached artifacts
make build          # Rebuild from scratch
```
