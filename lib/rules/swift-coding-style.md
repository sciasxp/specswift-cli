---
description: Swift coding standards—formatting, naming, documentation. K&R style, 120-char limit, Apple guidelines. Supports Swift 6.2+ Approachable Concurrency and earlier versions.
trigger: glob
globs: .swift
---

# Swift Style Guide

<critical_rules>

## 🚨 Critical Rules
1. **120 character line limit**
2. **4-space indentation, never tabs**
3. **No semicolons**
4. **K&R braces** (no break before `{`)
5. **Trailing closures** for single closure args
6. **No parentheses** around control flow conditions
7. **One statement per line**
8. **Trailing commas** in multiline collections
9. **Use `guard`** for early exits
10. **Use `Optional`** instead of sentinel values
11. **Document all public APIs** with `///`

</critical_rules>

<source_files>

## 📁 Source Files

**File Naming:** `MyType.swift`, `MyType+Protocol.swift`, `MyType+Additions.swift`
**Encoding:** UTF-8, 4-space indentation, no trailing whitespace
**Imports:** Order by (1) Modules, (2) Declarations, (3) `@testable`. Blank lines between groups.
**Organization:** One primary type per file. Use `// MARK: - Section` for grouping.

</source_files>

<formatting>

## 🎨 Formatting

**Braces (K&R):**
```swift
if condition {
  doSomething()
} else {
  somethingElse()
}
```
**Line-Wrapping:** All horizontal or all vertical for lists. Indent continuation **+4**. Opening `{` on same line as final continuation.
**Whitespace:** Space after `if`/`guard`/`while`/`switch`, both sides of operators, after colons (not before). No space around `.` or ranges.
**Parentheses:** Never around control flow conditions unless needed for clarity.

</formatting>

<programming_practices>

## 🛠️ Programming Practices

**Optionals & Errors:**
- Never use `try!`
- Avoid force unwrapping (`!`); add comment if necessary
- Use `guard let` or `if let`
- Prefer `throws` for multiple error states
**Access Control:** Omit `internal` (default). Specify on extension members, not extension itself.
**Initializers:** Use synthesized memberwise `init`. Omit `.init` in direct calls. Never call `ExpressibleBy*Literal` directly.
**Properties:** One per statement. Omit `get` for read-only computed properties.
**Enums:** One case per line. Comma-delimited only if no associated values and self-documenting.
**Trailing Closures:** Always use for single closure argument. No empty `()`.
**Trailing Commas:** Required in multiline collections.
**Switch:** `case` at same level as `switch`. Statements inside indented **+4**.
**For-Where:** Use `where` if loop body is single `if` test.
**Pattern Matching:** Place `let`/`var` before each element. Never distributed across pattern.

</programming_practices>

<concurrency_swift_6_2_plus>

## ⚡ Swift 6.2+ Concurrency (Approachable Concurrency)

Swift 6.2 introduces "Approachable Concurrency," which keeps code single-threaded by default until you explicitly choose to introduce concurrency.

**Actor Isolation:**
- Mark UI-related classes and main-thread-only code with `@MainActor`
- Use `nonisolated` for stateless or immutable services
- Use `actor` for types managing mutable state that must be protected from concurrent access
- Prefer isolated conformances: `extension MyType: @MainActor MyProtocol { ... }`
**Offloading Background Work:**
- Use `@concurrent` attribute on async functions that perform CPU-intensive work
- Ensure the containing type is `nonisolated` when using `@concurrent`
- Add `await` at call sites of `@concurrent` functions
- Example:
```swift
nonisolated struct ImageProcessor {
  @concurrent
  func process(data: Data) async -> ProcessedImage? { ... }
}
```
**Global & Static State:**
- Protect mutable global/static variables with `@MainActor`
- Prefer `@MainActor static let shared` for singletons
- Avoid unprotected mutable global state
**Default Behavior:**
- Async functions continue on the caller's actor by default (no implicit offloading)
- This eliminates data races in most single-threaded code
- Explicitly offload only when performance requires background work

</concurrency_swift_6_2_plus>

<concurrency_pre_6_2>

## ⚡ Swift < 6.2 Concurrency

For projects targeting Swift versions before 6.2, follow these practices:

**Actor Isolation:**
- Mark UI-related classes with `@MainActor`
- Use `nonisolated` for background workers and stateless services
- Use `actor` for types managing shared mutable state
**Async/Await:**
- Prefer `async`/`await` over completion handlers
- Use `Task` to bridge from synchronous to asynchronous code
- Avoid `Task.detached` unless necessary; prefer `Task { ... }`
**Sendable Conformance:**
- Mark types that cross actor boundaries as `Sendable`
- Ensure all properties are `Sendable` or immutable
- Use value types (structs, enums) when possible
**Explicit Offloading:**
- Use `DispatchQueue.global().async` or `Task.detached` for background work
- Always return to `@MainActor` for UI updates
- Document which actor a function expects to run on

</concurrency_pre_6_2>

<naming>

## 📛 Naming

**Follow Apple's API Design Guidelines:** Clarity > brevity. Name by role, not type.
**Static/Class Properties:** Not suffixed with type name. Use `shared` or `default` for singletons.
**Global Constants:** `lowerCamelCase`, no Hungarian notation.
**Delegate Methods:** First arg unlabeled (source object). Returns `Void`: verb phrase. Returns `Bool`: conditional verb. Returns other: noun phrase.

</naming>

<avoid>

## 🚫 Avoid

**Force Unwrapping:** Strongly discouraged. Comment explaining invariant if used.
**Implicitly Unwrapped Optionals:** Avoid. Only for `@IBOutlet` or test fixtures.
**Custom Operators:** Avoid unless clear domain meaning and significantly improves readability.

</avoid>

<advanced_patterns>

## 🔧 Advanced Patterns

**Access Levels:** Never specify on `extension`; specify per member.
**Nesting:** Nest types for scoped relationships. Use caseless `enum` for namespacing constants.
**Guards:** Use for early exits. Keeps main logic flush left.
**Literals:** Specify type explicitly when not default. Use `:` or `as` coercion, not initializer.


</advanced_patterns>

<documentation>

## 📝 Documentation

**Format:** Use `///` (not `/** */`). Summary first, then paragraphs.
**Tags:** `Parameter(s)`, `Returns`, `Throws` (in order). Never empty descriptions.
**Markup:** Backticks for code, `*italic*`, `**bold**`. Code blocks with triple backticks.
**Coverage:** Document all `open`/`public` declarations. Exceptions: self-explanatory enum cases, overrides (unless new behavior), tests, extensions (unless clarifying).

</documentation>