# TechSpec: [FEATURE]

**Feature**: [SHORT_NAME]  
**Branch**: `feature/[SHORT_NAME]`  
**Date**: [DATE]  
**Status**: Draft | In Review | Approved  
**PRD**: `_docs/specs/[SHORT_NAME]/prd.md`

<!--
  OUTPUT CONTRACT (do not remove; used by workflows):
  - Section order MUST be preserved. Required: Technical Context, Constitution Check, HIG Compliance, Project Structure, Feature Artifacts.
  - Status MUST be exactly one of: Draft | In Review | Approved.
  - Constitution Check / HIG Compliance table cells: exactly one of ✅ | ⚠️ | ❌ plus reasoning.
  - When a value cannot be determined: use [NEEDS CLARIFICATION] in Technical Context until answered; then use concrete value or [TBD] in Assumptions; do not invent.
-->

---

### 📍 Workflow

```
✅ PRD → ✅ TechSpec (current) → ⭕ Tasks → ⭕ Implementation
```

**Next step**: After approval, run `/specswift.tasks`

## Summary

[Extract from PRD: main requirement + technical approach]

## Reference Documentation

| Document | Content | Usage |
|-----------|----------|-----|
| `README.md` | Overview and commands | Build/test commands |
| `_docs/PRODUCT.md" | Business rules | Validate requirements |
| `_docs/STRUCTURE.md` | Architecture and folders | Paths and modules |
| `_docs/TECH.md` | Stack and patterns | Technologies and pitfalls |

## Technical Context

<!--
  REQUIRED ACTION: Replace the content of this section with the technical details
  for the project. Reference _docs/TECH.md for guidance on technology and architecture choices.
-->

**Language/Version**: Swift 6.2+
**Build System**: Xcode / Swift Package Manager (SPM)
**Architecture**: [Consult _docs/STRUCTURE.md]
**Main Dependencies**: [List external/internal dependencies]
**Storage**: [Specify persistence technology]
**Networking**: [Specify networking layer]
**Tests**: XCTest (unit/UI)
**Target Platform**: [iOS/macOS + Version]
**Project Type**: [mobile/desktop/etc]  

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-verify after Phase 1 design.*

| Principle | Status | Reasoning |
|-----------|--------|---------------|
| [Principle 1] | ✅/⚠️/❌ | [How this design adheres or deviates] |
| [Principle 2] | ✅/⚠️/❌ | [Reasoning] |

## HIG Compliance (Human Interface Guidelines)

*MANDATORY: Verify compliance with Apple Human Interface Guidelines*

| Aspect | Compliance | Notes |
|---------|--------------|-------|
| Navigation | ✅/⚠️/❌ | [Navigation patterns followed] |
| Accessibility | ✅/⚠️/❌ | [VoiceOver, Dynamic Type, etc] |
| Dark Mode | ✅/⚠️/❌ | [Support for adaptive colors] |
| Safe Areas | ✅/⚠️/❌ | [Respect for layout guides] |

## Project Structure

<!--
  Where the new code will live in the project.
  Follow existing patterns in _docs/STRUCTURE.md
-->

```
[PROJECT_NAME]/
└── [Path]/
    └── [FeatureName]/
        ├── Models/
        ├── Views/
        └── ViewModels/
```

## Complexity Tracking

| Component | Estimated Effort | Risk Level |
|------------|------------------|----------------|
| [Component 1] | [Low/Medium/High] | [Low/Medium/High] |

**Estimated Total Effort**: [X days/story points]
**Main Risks**: [List main technical risks]

---

## Navigation and Flow

<!--
  Map how navigation will be managed (e.g., Coordinators, Router).
  Reference: _docs/STRUCTURE.md
-->

| Component | Impact | Responsibility |
|------------|---------|------------------|
| [Component] | [New/Modified] | [Responsibility] |

## Modules and Integrations

<!--
  Identify existing modules that will be affected or integrated.
  Reference: _docs/STRUCTURE.md
-->

| Module/Service | Relation | Impact |
|----------------|---------|---------|
| [Module] | [Dependency/Integration] | [Description] |

## Impact on Global Configurations

<!--
  Check if there is an impact on global configurations or app constants.
  Reference: _docs/TECH.md
-->

| Item | Impact | Required Action |
|------|---------|-----------------|
| Persistence/Migration | [ ] Yes / [ ] No | [Details] |
| Feature Flags | [ ] Yes / [ ] No | [Details] |
| Environment Settings | [ ] Yes / [ ] No | [Details] |

## Pitfalls to Avoid

<!--
  Common errors to avoid in this project.
  Consult _docs/TECH.md for complete list of project pitfalls.
-->

| ❌ Avoid | ✅ Do Correctly |
|-----------|----------------------|
| Business logic in Views | Keep in ViewModels/Services |
| Direct persistence access in UI | Use Repository layer |
| Sensitive data in UserDefaults | Use Keychain |
| [Add project specific pitfalls] | [Recommended practice] |

---

## Feature Artifacts

```text
_docs/specs/[SHORT_NAME]/
├── prd.md               # ✅ Product Requirements
├── techspec.md          # ✅ This file
├── research.md          # Technical research
├── ui-design.md         # UI design (if applicable)
├── data-model.md        # Data model
├── quickstart.md        # Quick start guide
├── tasks.md             # ⭕ Task decomposition (next)
└── .agent.md            # Implementation context
```
