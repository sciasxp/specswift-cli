---
name: swiftui-expert
description: Expert SwiftUI guidance for SpecSwift projects. Use when building or reviewing SwiftUI features—state management, view composition, performance, modern APIs, and iOS 26+ Liquid Glass. Aligns with Apple HIG and SpecSwift UI/accessibility rules.
---

# SwiftUI Expert

## Overview

Use this skill to implement, review, or improve SwiftUI in iOS/Swift projects: correct state management, modern API usage, performance-conscious composition, and iOS 26+ Liquid Glass with safe fallbacks. It focuses on facts and best practices without enforcing a specific architecture. Integrates with SpecSwift rules for accessibility and UI.

**Source**: Content adapted from [SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) (Antoine van der Lee, Omar Elsayed). Use with create-techspec, implement, and clarify (visual) workflows.

## Workflow Decision Tree

### 1) Review existing SwiftUI code

- Property wrappers: check against selection guide (see State Management below).
- Modern APIs: avoid deprecated modifiers and types (see Modern APIs).
- View composition: extraction, small views, pure `body` (see View Composition).
- Performance: hot paths, list identity, no redundant updates (see Performance).
- List patterns: stable `ForEach` identity, no `.indices` for dynamic data.
- Liquid Glass (iOS 26+): correct usage and `#available` fallbacks.
- Accessibility: labels, Dynamic Type, VoiceOver (see project rules).

### 2) Improve existing SwiftUI code

- Prefer `@Observable` over `ObservableObject`.
- Replace deprecated APIs with modern equivalents.
- Extract complex views into subviews.
- Minimize redundant state updates in hot paths.
- Ensure `ForEach` uses stable identity.
- Suggest image downsampling when `UIImage(data:)` is used (optional).
- Adopt Liquid Glass only when explicitly requested.

### 3) Implement new SwiftUI feature

- Design data flow: owned vs injected state.
- Use modern APIs only (no deprecated patterns).
- Use `@Observable` for shared state; `@MainActor` when needed.
- Structure views for diffing: extract subviews, keep views small.
- Separate business logic for testability.
- Apply glass effects after layout/appearance; gate iOS 26+ with `#available`.

## Core Guidelines

### State Management

- **Prefer `@Observable` over `ObservableObject`** for new code.
- **Mark `@Observable` with `@MainActor`** unless using default actor isolation.
- **`@State` and `@StateObject` must be `private`** (dependencies clear).
- **Never use `@State` / `@StateObject` for passed-in values** (only initial/owned).
- Use `@State` with `@Observable` (not `@StateObject`).
- `@Binding` only when child **modifies** parent state.
- `@Bindable` for injected `@Observable` that need bindings.
- `let` for read-only; `var` + `.onChange()` for reactive reads.
- Nested `ObservableObject` does not work (pass nested directly); `@Observable` nests fine.

### Modern APIs

| Prefer | Avoid |
|--------|--------|
| `foregroundStyle()` | `foregroundColor()` |
| `clipShape(.rect(cornerRadius:))` | `cornerRadius()` |
| `Tab` API | `tabItem()` |
| `Button` | `onTapGesture()` (unless location/count needed) |
| `NavigationStack` | `NavigationView` |
| `navigationDestination(for:)` | type-unsafe navigation |
| Two-parameter or no-parameter `onChange(of:)` | single-value `onChange` |
| `.sheet(item:)` | `.sheet(isPresented:)` for model-based sheets |
| `.scrollIndicators(.hidden)` | `showsIndicators: false` |
| `Text(value, format: .number...)` | `String(format: ...)` |
| `localizedStandardContains()` | `contains()` for user input |
| `containerRelativeFrame()` / `visualEffect()` | `GeometryReader` when not needed |
| Avoid `UIScreen.main.bounds` for sizing | — |

### View Composition

- **Prefer modifiers over conditional views** for state changes (keeps view identity).
- Extract complex views into separate subviews.
- Keep views small; keep `body` simple and pure (no side effects).
- Use `@ViewBuilder` for small sections only.
- Prefer `@ViewBuilder let content: Content` over closure-based content.
- Separate business logic for testability; action handlers call methods, not inline logic.
- Use relative layout; views should work in any context (size/presentation agnostic).

### Performance

- Pass only needed values (no large “config” objects).
- Check for value change before assigning state in hot paths.
- Avoid redundant updates in `onReceive`, `onChange`, scroll handlers.
- Use `LazyVStack`/`LazyHStack` for large lists.
- **Stable identity for `ForEach`** (never `.indices` for dynamic content).
- Constant number of views per `ForEach` element; no inline filtering in `ForEach`.
- Avoid `AnyView` in list rows.
- No object creation in `body`; move heavy work out of `body`.
- Suggest image downsampling when `UIImage(data:)` is used (optional).

### Liquid Glass (iOS 26+)

Use only when explicitly requested. When used:

- Gate with `#available(iOS 26, *)` and provide fallback (e.g. `.ultraThinMaterial`).
- Wrap multiple glass views in `GlassEffectContainer`.
- Apply `.glassEffect()` after layout and appearance modifiers.
- Use `.interactive()` only on user-interactable elements.
- Use `glassEffectID` with `@Namespace` for morphing transitions.

## Quick Reference Tables

### Property Wrapper Selection (Modern)

| Wrapper | Use when |
|---------|----------|
| `@State` | Internal view state (private), or owned `@Observable` class |
| `@Binding` | Child modifies parent state |
| `@Bindable` | Injected `@Observable` needing bindings |
| `let` | Read-only from parent |
| `var` | Read-only watched via `.onChange()` |

**Legacy (pre–iOS 17):** `@StateObject` for owned `ObservableObject`; `@ObservedObject` for injected. Prefer `@Observable` + `@State` for new code.

### Liquid Glass pattern (with fallback)

```swift
if #available(iOS 26, *) {
    content
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
} else {
    content
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
}
```

## Review Checklist

### State Management

- [ ] `@Observable` instead of `ObservableObject` for new code
- [ ] `@Observable` marked `@MainActor` when needed
- [ ] `@State` with `@Observable` (not `@StateObject`)
- [ ] `@State` / `@StateObject` are `private`
- [ ] Passed values not declared as `@State` / `@StateObject`
- [ ] `@Binding` only where child modifies parent
- [ ] `@Bindable` for injected `@Observable` needing bindings

### Modern APIs

- [ ] `foregroundStyle()` instead of `foregroundColor()`
- [ ] `NavigationStack` instead of `NavigationView`
- [ ] No `UIScreen.main.bounds` for sizing
- [ ] Alternatives to `GeometryReader` where possible
- [ ] Button images have text labels for accessibility

### Sheets & Navigation

- [ ] `.sheet(item:)` for model-based sheets
- [ ] Sheets own actions and dismiss internally
- [ ] `navigationDestination(for:)` for type-safe navigation

### View Structure & Performance

- [ ] Modifiers instead of conditionals for state-driven UI
- [ ] Complex views extracted; views kept small
- [ ] `body` simple and pure; no side effects
- [ ] Only needed values passed; no large config objects
- [ ] State updates check for change before assigning
- [ ] No object creation in `body`

### List Patterns

- [ ] `ForEach` uses stable identity (not `.indices`)
- [ ] Constant number of views per `ForEach` element
- [ ] No inline filtering in `ForEach`; no `AnyView` in rows

### Liquid Glass (if used)

- [ ] `#available(iOS 26, *)` with fallback
- [ ] `.glassEffect()` after layout/appearance
- [ ] `.interactive()` only on tappable/focusable elements

## References

- **SpecSwift**: `lib/rules/.../accessibility-guidelines.md`, `lib/rules/.../swift-coding-style.md`, and project TECH.md for UI/accessibility.
- **Full reference set**: [SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) (state-management, view-structure, performance-patterns, list-patterns, layout-best-practices, modern-apis, sheet-navigation-patterns, scroll-patterns, text-formatting, image-optimization, liquid-glass).

---

*Content adapted from [SwiftUI Agent Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) by Antoine van der Lee and Omar Elsayed.*
