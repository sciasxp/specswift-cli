---
description: Enforce explicit Swift concurrency isolation for services to ensure thread safety and compatibility with Swift 6.2 and @Observable ViewModels.
trigger: always_on
---

# Architectural Rule: Swift Concurrency and Service Isolation

## Status
**Proposed**

## Context
The project uses Swift 6.2 with strict concurrency checks enabled. Swift 6.2 introduces "Approachable Concurrency," which simplifies data-race safety by keeping code single-threaded by default until explicitly offloaded. We need a consistent strategy for service isolation and background work.

## Rule
All Service classes/structs must explicitly define their isolation level to ensure thread safety and optimal performance.

### 1. MainActor Isolated Services (Default)
Services that interact with UI, `ModelContext` (SwiftData), or other `@MainActor` components should be marked with `@MainActor`.
- **When to use:** Services performing database operations or triggering UI updates.
- **Note:** Swift 6.2 allows **isolated conformances** (e.g., `extension MyModel: @MainActor MyProtocol`), ensuring protocols are used safely on the main actor.

```swift
@MainActor
final class DatabaseService {
    let context: ModelContext
    
    func save(item: MyModel) {
        context.insert(item)
    }
}
```

### 2. Non-isolated Services & Background Work
Services that are stateless or contain only immutable state should be `nonisolated`. To offload CPU-intensive work without blocking the caller, use the `@concurrent` attribute.
- **When to use:** Pure logic, utility-like services (e.g., `FileManagerService`), and heavy processors.
- **Benefit:** `@concurrent` ensures the function runs on the concurrent thread pool.

```swift
nonisolated struct PhotoProcessor {
    @concurrent
    func process(data: Data) async -> ProcessedPhoto? {
        // Expensive image processing here
    }
}
```

### 3. Dedicated Actor Services
Use `actor` for services managing their own mutable state that must be protected from concurrent access.
- **When to use:** Caches, stateful processors (e.g., `ImageCache`).

```swift
actor ImageCache {
    private var cache: [URL: UIImage] = [:]
    
    func image(for url: URL) -> UIImage? {
        cache[url]
    }
}
```

## Enforcement
- New services must include an isolation attribute (`@MainActor`, `nonisolated`, or `actor`).
- Use `@concurrent` for heavy async work to keep the app responsive.
- ViewModels should use `@ObservationIgnored` for service instances to avoid unnecessary observation overhead.
- Prefer isolated conformances for protocols that require actor-specific state.
