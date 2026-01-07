---
description: Follow these guidelines when writing Swift code to ensure clarity, consistency, and a "Swift-native" feel.
trigger: always_on
---

# Swift API Design Guidelines

## Fundamentals
- **Clarity at the point of use** is the most important goal.
- **Clarity is more important than brevity.**
- If you can't describe an API simply, it might be designed wrong.

## Naming
- **Promote Clear Usage:**
  - Include all words needed to avoid ambiguity.
  - Omit needless words (don't repeat type information).
  - Name variables, parameters, and associated types according to their **roles**, not type constraints.
  - Compensate for weak type information (precede weakly typed parameters with a noun describing their role).
- **Strive for Fluent Usage:**
  - Prefer method/function names that make use sites form grammatical English phrases.
  - Factory methods should begin with `make`.
  - Initializers and factory methods: the first argument should not form a phrase starting with the base name.
  - Name functions/methods according to side-effects:
    - No side-effects: read as noun phrases (e.g., `x.distance(to: y)`).
    - With side-effects: read as imperative verb phrases (e.g., `x.sort()`).
  - Mutating/nonmutating pairs:
    - Use "ed" or "ing" suffix for nonmutating variants of verb-based operations (e.g., `sort` -> `sorted`).
    - Use "form" prefix for mutating variants of noun-based operations (e.g., `union` -> `formUnion`).
- **Boolean types:** Should read as assertions (e.g., `isEmpty`, `intersects`).
- **Protocols:** 
  - Describe *what something is*: Nouns (e.g., `Collection`).
  - Describe a *capability*: Suffixes `able`, `ible`, or `ing` (e.g., `Equatable`).
- **Case Conventions:**
  - Types and Protocols: `UpperCamelCase`.
  - Everything else: `lowerCamelCase`.
  - Acronyms: Treat as ordinary words unless all-caps is standard (e.g., `utf8`, `ASCII`).

## Documentation
- Use Swift's dialect of Markdown.
- Begin with a summary (sentence fragment ending in a period).
- Describe what a function **does** and **returns**.
- Describe what a subscript **accesses**.
- Describe what an initializer **creates**.
- Document complexity if it's not O(1) for computed properties.

## Conventions
- **Parameters:**
  - Choose names to serve documentation.
  - Take advantage of defaulted parameters to simplify common uses.
  - Locate parameters with defaults toward the end.
- **Argument Labels:**
  - Omit labels when arguments can't be usefully distinguished (e.g., `min(a, b)`).
  - Omit first label in value-preserving type conversions.
  - If the first argument forms part of a prepositional phrase, give it a label (usually starting with the preposition).
  - Otherwise, if it forms part of a grammatical phrase, omit the label and append preceding words to the base name (e.g., `addSubview(y)`).
  - Label all other arguments.

## Special Instructions
- **Tuple members and closure parameters:** Label/name them for better documentation and expressivity.
- **Unconstrained polymorphism:** Take extra care with `Any`, `AnyObject`, etc., to avoid ambiguity in overloads.
