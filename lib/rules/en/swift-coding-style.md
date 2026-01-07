---
description: Swift coding standards—formatting, naming, documentation. K&R style, 120-char limit, Apple guidelines. Supports Swift 6.2+ Approachable Concurrency.
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
**Switch:** `case` at same level as `switch`. Statements inside indented **+4**.

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

</concurrency_swift_6_2_plus>

<naming>

## 📛 Naming

**Follow Apple's API Design Guidelines:** Clarity > brevity. Name by role, not type.
**Static/Class Properties:** Not suffixed with type name. Use `shared` or `default` for singletons.
**Global Constants:** `lowerCamelCase`, no Hungarian notation.

</naming>

<documentation>

## 📝 Documentation

**Format:** Use `///` (not `/** */`). Summary first, then paragraphs.
**Tags:** `Parameter(s)`, `Returns`, `Throws` (in order). Never empty descriptions.
**Markup:** Backticks for code, `*italic*`, `**bold**`. Code blocks with triple backticks.

</documentation>
