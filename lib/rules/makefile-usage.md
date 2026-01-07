---
description: Guidelines for building, running, and testing the Panel Flow project using the provided Makefile.
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
Build the app and launch it on the iPhone 17 simulator:
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
Build the project for the iPhone 17 simulator without running it:
```bash
make build
```

**When to use**: 
- Verify compilation before running
- Check for build errors without launching the app
- Prepare for integration with other tools (e.g., axe automation)

### 3. Run Unit Tests
Execute all unit tests in the `Panel Flow` scheme on the iPhone 17 simulator:
```bash
make test
```

**When to use**: 
- Validate code changes with automated tests
- Ensure no regressions before committing
- Part of the standard development cycle (build → test → run)

### 4. Build for Physical Device
Build the app for a connected physical device (defaulting to iPhone 16 Pro settings):
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

### 8. Documentation Commands
Manage and verify project documentation:
```bash
make docs-help
```
**When to use:**
- View documentation structure and file organization
- Understand where to find specific guidelines

### 9. Update WARP.md
Check WARP.md synchronization with `.windsurf/rules/`:
```bash
make update-warp-md
```
**When to use:**
- After updating any files in `.windsurf/rules/`
- To verify all rule files are referenced in WARP.md
- Creates a backup before checking (remove after verification)

## Configuration

The Makefile uses the following fixed configuration:
- **Project**: `Panel Flow.xcodeproj`
- **Scheme**: `Panel Flow`
- **Bundle ID**: `com.bardonunes.Panel-Flow`
- **Simulator**: iPhone 17 (latest available)
- **Physical Device**: iPhone 16 Pro (preference)
- **Documentation Script**: `scripts/update-warp-md.sh`

To modify these, edit the configuration section at the top of the `Makefile`.

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

### Physical Device Testing
```bash
make device         # Build for physical device
# Then use Xcode or ios-deploy to run
```

### Documentation Maintenance
```bash
make docs-help      # View documentation structure
make update-warp-md # Check WARP.md sync with rules
```

## Troubleshooting

### CoreML Models Fail to Compile
Ensure Git LFS has pulled the actual binary files:
```bash
git lfs pull
```
Then rebuild:
```bash
make clean
make build
```

### Simulator Won't Boot
The Makefile automatically boots the simulator, but if it fails:
```bash
xcrun simctl boot "iPhone 17"
open -a Simulator
make run
```

### Build Cache Issues
Clear derived data and rebuild:
```bash
make clean
make build
```

### xcbeautify Not Found
Install via Homebrew:
```bash
brew install xcbeautify
```
Or use raw output to bypass:
```bash
make build-raw
```

### App Won't Launch on Simulator
Verify the simulator is running and the bundle ID is correct:
```bash
xcrun simctl list devices
make help  # Check configured bundle ID
make run
```

## Integration with Other Tools

### Axe Automation
Use the Makefile to build before running axe automation tests:
```bash
make build
# Then run axe automation scripts
```

### Continuous Integration
The Makefile is CI-friendly. Use in scripts:
```bash
make clean
make test
make build
```

## Performance Tips

- **Incremental Builds**: Use `make build` after small changes; full rebuilds are slower
- **Parallel Compilation**: Xcode uses all available cores by default
- **Simulator Reuse**: Keep the simulator running between builds to avoid boot overhead
- **Clean Sparingly**: Only run `make clean` when necessary; it removes all cached artifacts

## File Structure Reference

The Makefile is located at the project root:
```
panel_flow-v2/
├── Makefile                    # Build automation
├── scripts/
│   └── update-warp-md.sh       # Documentation sync script
├── WARP.md                     # Main project rules
├── .windsurf/rules/            # Detailed coding standards
├── Panel Flow.xcodeproj/       # Xcode project
├── Panel Flow/                 # Main app target
├── Panel FlowTests/            # Unit tests
├── MLService/                  # ML package
├── SpeechService/              # Speech package
└── MangaScrapers/              # Scraping package
```
