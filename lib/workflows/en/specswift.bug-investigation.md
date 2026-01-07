---
description: Structured workflow for investigating and fixing bugs. Use as a prompt guide for bug investigations.
---

# Bug Investigation Workflow

## Overview

This workflow guides you through investigating and fixing bugs in the project.

**Reference Documentation**:
- `README.md` - Overview and commands
- `_docs/PRODUCT.md` - Business rules
- `_docs/STRUCTURE.md` - Architecture and folders
- `_docs/TECH.md` - Stack and patterns

---

## Step 1: Gather Evidence

Fill in the bug report template:

```markdown
**Bug:**
**Expected:**
**Actual:**
**Steps to reproduce:**
**Frequency:** always / intermittent / rare
**Environment:** iOS version, device/simulator
**Feature area:** Library / Reader / Editor / Import / TTS / ML Detection
```

---

## Step 2: Review Project Invariants

Before making changes, understand the project constraints:

### Architecture
Consult `_docs/STRUCTURE.md` for:
- Architectural pattern (MVVM, Coordinator, etc.)
- Module and package structure
- Navigation patterns

### Concurrency and Threading
Consult `_docs/TECH.md` and `.windsurf/rules/` for:
- Actor isolation rules
- async/await patterns
- Background work handling

### Persistence
Consult `_docs/TECH.md` for:
- Persistence technology used
- Data access rules
- Migrations and schema

### Accessibility
Consult `.windsurf/rules/accessibility-guidelines.md` for:
- VoiceOver requirements
- Dynamic Type
- Mandatory labels and hints

---

## Step 3: Locate Implementation

Use `code_search` or `grep_search` to find relevant code.

### Project Structure
Consult `_docs/STRUCTURE.md` for the complete directory structure.

**Typical Components**:
| Component | Description |
|------------|----------|
| Models | Data entities and business logic |
| ViewModels | Presentation logic and state |
| Views | User interface |
| Services | Business operations and infrastructure |
| Utilities | Extensions and helpers |

---

## Step 4: Trace the Data Flow

Document your findings:

```markdown
**Entry point:**
**Data flow:** View → ViewModel → Service → SwiftData/Package
**Key functions/classes:**
**Actor boundaries:** Where isolation changes occur
**Divergence:** Where behavior differs from expected
```

---

## Step 5: Identify Root Cause

### Common Swift 6.2 Concurrency Patterns

**Pattern 1: MainActor by Default (Approachable Concurrency)**
```swift
// In Swift 6.2, this class runs on MainActor by default
final class StickerModel {
    let photoProcessor = PhotoProcessor()
    
    // Async calls stay on MainActor—no data race
    func process(_ item: PhotosPickerItem) async throws -> Sticker? {
        let data = try await item.loadTransferable(type: Data.self)
        return await photoProcessor.extractSticker(data: data)
    }
}
```

**Pattern 2: Isolated Conformances**
```swift
// Safe conformance for MainActor types
extension StickerModel: @MainActor Exportable {
    func export() {
        photoProcessor.exportAsPNG()
    }
}
```

**Pattern 3: Offloading Heavy Work with @concurrent**
```swift
class PhotoProcessor {
    var cache: [String: Sticker]
    
    func extractSticker(data: Data, id: String) async -> Sticker {
        if let cached = cache[id] { return cached }
        
        // Offload CPU-intensive work
        let sticker = await Self.extractSubject(from: data)
        cache[id] = sticker
        return sticker
    }
    
    @concurrent
    static func extractSubject(from data: Data) async -> Sticker {
        // Runs on concurrent thread pool
    }
}
```

**Pattern 4: Nonisolated + @concurrent for Background Services**
```swift
nonisolated struct ImageProcessor {
    @concurrent
    func process(data: Data) async -> ProcessedImage? {
        // Heavy processing on background thread
    }
}
```

### Concurrency Issue Quick Reference

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| "Sending X risks data races" | Non-Sendable crossing actor boundary | Keep on same actor or make `Sendable` |
| UI not updating | Mutation off MainActor | Ensure ViewModel stays on MainActor |
| App hangs | Blocking MainActor | Use `@concurrent` for heavy work |
| SwiftData crash | ModelContext off MainActor | Use `@MainActor` service |

---

## Step 6: Implement Fix

1. **Prefer root cause fix** over workaround
2. **Minimal changes**—don't refactor unrelated code
3. **Respect actor boundaries**—use Swift 6.2 patterns above
4. **Preserve accessibility**—keep/add labels

---

## Step 7: Add Regression Test

Run existing tests first:
```bash
make test
```

Add new test mirroring the main app structure (consult `_docs/STRUCTURE.md` for test location).

---

## Step 8: Document the Fix

```markdown
## [Issue Title]

**Problem:** Brief description

**Root Cause:** What caused it

**Solution:** How it was fixed

**Prevention:** How to avoid in future (if applicable)
```

---

## Bug Description

Paste the detailed bug description here, including screenshots, logs, or additional context.
