---
name: swift-concurrency
description: Expert guidance on Swift Concurrency for SpecSwift projects. Use when working on async/await, actors, tasks, Sendable, Swift 6 migration, data races, or concurrency-related lint warnings. Integrates with lib/rules for service isolation and Approachable Concurrency (Swift 6.2).
---

# Swift Concurrency

## Overview

This skill provides expert guidance on Swift Concurrency for iOS/Swift projects: async/await, actors, tasks, Sendable, and Swift 6 migration. Use it when implementing or reviewing code that involves concurrency, or when resolving data-race or isolation diagnostics. It aligns with SpecSwift rules (`lib/rules/.../swift-concurrency.md`) and Apple’s Approachable Concurrency (Swift 6.2).

**Source**: Content adapted from [Swift-Concurrency-Agent-Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill) (Antoine van der Lee). Use for implementation, code review, and bug investigation workflows.

## Agent Behavior Contract (Follow These Rules)

1. **Discover project settings** – Check `Package.swift` or `.pbxproj` for Swift language mode (5.x vs 6), strict concurrency level, and default actor isolation before giving migration-sensitive advice.
2. **Identify isolation first** – Before proposing fixes, identify the boundary: `@MainActor`, custom actor, actor instance isolation, or nonisolated.
3. **No blanket @MainActor** – Do not recommend `@MainActor` as a generic fix; justify why main-actor isolation is correct.
4. **Prefer structured concurrency** – Prefer child tasks and task groups over unstructured `Task`; use `Task.detached` only with a documented reason.
5. **Unsafe escapes** – If recommending `@preconcurrency`, `@unchecked Sendable`, or `nonisolated(unsafe)`, require a documented safety invariant and a follow-up to remove or migrate.
6. **Migration** – Prefer minimal blast radius (small, reviewable changes) and add verification steps.
7. **SpecSwift alignment** – For services and ViewModels, follow project rules in `lib/rules/.../swift-concurrency.md` (e.g. `@MainActor` for UI/SwiftData, `nonisolated` + `@concurrent` for heavy work).

## Project Settings (Evaluate Before Advising)

Concurrency behavior depends on build settings. Determine:

- **Default actor isolation** – Module default `@MainActor` or `nonisolated`?
- **Strict concurrency** – minimal / targeted / complete?
- **Upcoming features** – e.g. `NonisolatedNonsendingByDefault`?
- **Swift / Xcode** – Swift 5.x vs 6; SwiftPM tools version.

**Manual checks:**

- **SwiftPM**: In `Package.swift` check `.defaultIsolation(MainActor.self)`, `.enableUpcomingFeature("...")`, strict concurrency flags, and `// swift-tools-version:`.
- **Xcode**: In `.pbxproj` search for `SWIFT_DEFAULT_ACTOR_ISOLATION`, `SWIFT_STRICT_CONCURRENCY`, `SWIFT_UPCOMING_FEATURE_`.

If any of these are unknown, ask the developer before giving migration-specific guidance.

## Quick Decision Tree

1. **Starting with async code?**  
   → async/await basics; for parallel work use `async let` or task groups.

2. **Protecting shared mutable state?**  
   → Class-based state: actors or `@MainActor`.  
   → Thread-safe value passing: `Sendable` conformance.

3. **Managing async operations?**  
   → Structured work: `Task`, child tasks, cancellation.  
   → Streaming: `AsyncSequence` / `AsyncStream`.

4. **Legacy frameworks?**  
   → Core Data: DAO pattern, `NSManagedObjectID`, isolation.  
   → General: migration steps, incremental strict concurrency.

5. **Performance or debugging?**  
   → Slow async code: profiling, suspension points.  
   → Tests: XCTest async, Swift Testing, deterministic async tests.

6. **Threading behavior?**  
   → Understand thread vs task, suspension points, isolation domains.

7. **Memory / tasks?**  
   → Retain cycles in tasks, cancellation, `[weak self]` where appropriate.

## Triage-First Playbook (Common Errors → Next Move)

| Symptom / Warning | First step | Then |
|-------------------|------------|------|
| SwiftLint concurrency warnings | Use concurrency lint rules; avoid dummy `await` as “fix”. | Prefer real fix or narrow suppression. |
| `async_without_await` | Remove `async` if not needed; if required by protocol/override, prefer narrow suppression over fake awaits. | — |
| “Sending value of non-Sendable type ... risks data races” | Find where the value crosses an isolation boundary. | Apply Sendable/isolation guidance (value type, `@unchecked Sendable` with doc, or keep on same actor). |
| “Main actor-isolated ... cannot be used from a nonisolated context” | Decide if it really belongs on `@MainActor`. | Use actors/global actors, `nonisolated`, or isolated parameters. |
| “Class property 'current' is unavailable from asynchronous contexts” (Thread) | Move away from Thread APIs. | Use tasks and isolation; debug with Instruments. |
| XCTest async / “wait(...) is unavailable from async” | Use async test APIs. | `await fulfillment(of:)` or Swift Testing patterns. |
| Core Data concurrency warnings | Core Data + actors isolation. | DAO, `NSManagedObjectID`, avoid passing managed objects across boundaries. |

## Core Patterns Reference

### When to Use Each Concurrency Tool

| Tool | Use for |
|------|--------|
| **async/await** | Single async operations, making sync code async. |
| **async let** | Fixed number of independent async operations in parallel. |
| **Task** | Fire-and-forget, bridging sync to async. |
| **Task group** | Dynamic number of parallel operations. |
| **Actor** | Shared mutable state, access from multiple contexts. |
| **@MainActor** | ViewModels, UI, SwiftData `ModelContext`. |

### Example: Network + UI update

```swift
Task { @concurrent in
    let data = try await fetchData()  // background
    await MainActor.run {
        self.updateUI(with: data)     // main
    }
}
```

### Example: Parallel requests

```swift
async let users = fetchUsers()
async let posts = fetchPosts()
let (u, p) = try await (users, posts)
```

### Example: Actor for shared state

```swift
actor DataCache {
    private var cache: [String: Data] = [:]
    func get(_ key: String) -> Data? { cache[key] }
}
```

### Example: SpecSwift-style service (align with project rules)

```swift
@MainActor
final class DatabaseService { ... }

nonisolated struct PhotoProcessor {
    @concurrent
    func process(data: Data) async -> ProcessedPhoto? { ... }
}
```

## Swift 6 Migration Quick Guide

- **Strict concurrency** is on by default; **data-race safety** at compile time.
- **Sendable** is required across isolation boundaries.
- **Isolation** is checked at all async boundaries.

Migrate in small steps: enable targeted strict concurrency, fix diagnostics, then move to complete. Prefer value types and explicit isolation over `@preconcurrency` or `@unchecked Sendable` where possible.

## Verification Checklist (After Changing Concurrency Code)

- [ ] Build settings (default isolation, strict concurrency, upcoming features) are known and consistent with advice.
- [ ] Tests run, including concurrency-sensitive tests.
- [ ] If performance-related, verify with Instruments.
- [ ] If lifetime-related, verify deinit and cancellation behavior.
- [ ] New services have explicit isolation (`@MainActor`, `nonisolated`, or `actor`) per project rules.

## Best Practices Summary

1. Prefer **structured concurrency** (task groups, child tasks) over unstructured `Task` where possible.
2. **Minimize suspension points**; keep actor-isolated regions small.
3. Use **@MainActor** only for UI and main-actor-bound state.
4. Make types **Sendable** where they cross isolation boundaries.
5. **Handle cancellation** in long-running work (`Task.isCancelled`).
6. **Avoid blocking** (no semaphores/locks) in async contexts.
7. **Test** concurrent code with async test APIs and consider timing.

## References

- **SpecSwift rules**: `lib/rules/en/swift-concurrency.md` (and `pt/`) for service isolation and Approachable Concurrency.
- **Full reference set**: [Swift-Concurrency-Agent-Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill) (async-await-basics, tasks, sendable, actors, async-sequences, threading, memory-management, core-data, performance, testing, migration, glossary, linting).

---

*Content adapted from [Swift Concurrency Agent Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill) by Antoine van der Lee.*
