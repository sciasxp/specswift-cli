---
trigger: always_on
---

# SwiftUI Accessibility Guidelines

## Fundamentals
- **Accessibility is not an afterthought.** Design and implement with VoiceOver, Switch Control, and other assistive technologies in mind from the start.
- **Clarity and Context:** Provide clear, concise descriptions for UI elements that don't have intrinsic text (like icons).

## Requirements for Views
### 1. Mandatory Accessibility Labels
All interactive elements (Buttons, Toggles, Steppers) and informative images MUST have an explicit accessibility label if they do not contain text.
- **Good:** `Button { ... } label: { Image(systemName: "plus") }.accessibilityLabel("Add New Publication")`
- **Avoid:** `Button { ... } label: { Image(systemName: "plus") }` (VoiceOver will just say "plus, button").

### 2. Decorative Elements
Elements that are purely visual and provide no information should be hidden from accessibility.
- **Usage:** `.accessibilityHidden(true)` or `Image(decorative: "background")`.

### 3. Accessibility Hints
Use hints sparingly for complex interactions where the result of an action isn't obvious from the label.
- **Usage:** `.accessibilityHint("Double-tap to open the chapter reader.")`

### 4. Grouping Related Elements
Use `accessibilityElement(children: .combine)` to group related information that should be read together.
- **Example:** A cell with a title and a subtitle should often be read as a single element.

### 5. Dynamic Type Support
- Ensure text uses standard font styles (`.body`, `.headline`, `.title`) or is configured to scale with system settings.
- Avoid fixed heights/widths for containers that hold text.

### 6. Traits and States
Ensure interactive elements have the correct traits.
- **Usage:** `.accessibilityAddTraits(.isButton)`, `.accessibilityRemoveTraits(.isImage)`.
- **Value/State:** Use `.accessibilityValue()` to describe current state for custom controls (e.g., "75% complete").

## Naming Conventions
- **Labels:** Use sentence fragments, start with a capital letter, and do not end with a period.
- **Action Verbs:** Labels for buttons should describe the action, not the icon name.
  - **Preferred:** "Close", "Search", "Next Page".
  - **Avoid:** "xmark", "magnifyingglass", "chevron.right".

## Testing
- Use the **Accessibility Inspector** in Xcode to verify the accessibility tree and labels.
- Test with **VoiceOver** on a physical device whenever possible.
