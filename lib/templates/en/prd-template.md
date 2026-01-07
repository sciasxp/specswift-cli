# PRD: [FEATURE NAME]

**Feature**: [SHORT_NAME]  
**Branch**: `feature/[SHORT_NAME]`  
**Created**: [DATE]  
**Status**: Draft | In Review | Approved

---

### 📍 Workflow

```
✅ PRD (current) → ⭕ TechSpec → ⭕ Tasks → ⭕ Implementation
```

**Next step**: After approval, run `/specswift.create-techspec`

## Reference Documentation

| Document | Content | Usage |
|-----------|----------|-----|
| `README.md` | Overview and commands | Project context |
| `_docs/PRODUCT.md` | Business rules | Validate functional requirements |
| `_docs/STRUCTURE.md` | Architecture and folders | Understand structure |
| `_docs/TECH.md` | Stack and patterns | Technical constraints |

## User Scenarios & Tests *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each story/user journey must be INDEPENDENTLY TESTABLE - meaning that if you implement only ONE of them,
  you should still have an MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) for each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### US1: [Brief Title] (Priority: P1)

[Describe this user journey in simple language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g., "Can be fully tested by [specific action] and delivers [specific value]"]

**Test Coverage**:
- Unit tests for core logic (Models/Repositories/ViewModels)
- UI tests for critical user journey (when applicable)

**Offline/Sync Considerations**:
- [Online-only / Offline supported / Semi-offline]
- What happens without connectivity?
- What happens during sync / with pending sync queue?

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected result]
2. **Given** [initial state], **When** [action], **Then** [expected result]

---

### US2: [Brief Title] (Priority: P2)

[Describe this user journey in simple language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Test Coverage**:
- Unit tests
- UI tests (if this story changes user-visible flow)

**Offline/Sync Considerations**:
- [Online-only / Offline supported / Semi-offline]
- Sync behavior/pending (if applicable)

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected result]

---

### US3: [Brief Title] (Priority: P3)

[Describe this user journey in simple language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Test Coverage**:
- Unit tests

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected result]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  REQUIRED ACTION: The content of this section represents placeholders.
  Fill them with the correct edge cases.
-->

- What happens when [edge condition]?
- How does the system handle [error scenario]?
- Persistence and Security: [Specify database, thread safety, migrations]
- Authentication: [Specify authentication method, token expiration, secure storage]
- Environment: [Behavior in different environments (Dev/QA/Prod)]

## Requirements *(mandatory)*

<!--
  REQUIRED ACTION: The content of this section represents placeholders.
  Fill them with the correct functional requirements.
-->

### Functional Requirements

- **FR-001**: System MUST [specific capability, e.g., "allow users to create accounts"]
- **FR-002**: System MUST [specific capability, e.g., "validate email addresses"]  
- **FR-003**: Users MUST be able to [key interaction, e.g., "reset their passwords"]
- **FR-004**: System MUST [data requirement, e.g., "persist user preferences"]
- **FR-005**: System MUST [behavior, e.g., "log all security events"]

*Project Considerations for requirements:*

- If data is stored locally, specify the technology and if it affects schema/migration.
- If navigation changes, specify the navigation pattern (e.g., Coordinators, Router, etc.).
- If there is an offline flow or sync, specify the expected behavior.

*Example of marking unclear requirements:*

- **FR-006**: System MUST authenticate users via [NEEDS CLARIFICATION: authentication method not specified - email/password, SSO, OAuth?]
- **FR-007**: System MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]

### Key Entities *(include if the feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships with other entities]

<!--
  If these entities are persisted, note the persistence technology and if schema changes/migrations are needed.
-->

### Non-Functional Requirements *(include if applicable)*

- **NFR-001**: Performance - [e.g., "Screen must load in less than 2 seconds"]
- **NFR-002**: Accessibility - [e.g., "Full support for VoiceOver and Dynamic Type"]
- **NFR-003**: Security - [e.g., "Sensitive data must be stored in Keychain"]

## Success Criteria *(mandatory)*

<!--
  REQUIRED ACTION: Define measurable success criteria.
  These should be technology agnostic and measurable.
-->

### Measurable Results

- **SC-001**: [Measurable metric, e.g., "Users can complete account creation in less than 2 minutes"]
- **SC-002**: [Measurable metric, e.g., "System handles 1000 concurrent users without degradation"]
- **SC-003**: [User satisfaction metric, e.g., "90% of users successfully complete main task on first attempt"]
- **SC-004**: [Business metric, e.g., "Reduce support tickets related to [X] by 50%"]

## Assumptions *(mandatory)*

<!--
  Document assumptions made during specification.
  These must be validated before implementation.
-->

- [Assumption 1 - e.g., "User is already authenticated when accessing this feature"]
- [Assumption 2 - e.g., "Sync data is available on the server"]

## Dependencies *(include if applicable)*

<!--
  List external or internal dependencies required for this feature.
-->

- [Dependency 1 - e.g., "Authentication API v2 must be available"]
- [Dependency 2 - e.g., "Feature X must be implemented first"]

## Open Questions *(remove when resolved)*

<!--
  List questions that need to be answered before implementation.
  Remove this section when all questions are resolved.
-->

- [ ] [Question 1]
- [ ] [Question 2]

---

## Project Specific Considerations *(mandatory)*

<!--
  CRITICAL: Check project specific items described in _docs/PRODUCT.md and _docs/TECH.md.
-->

### Data Flows and Sync

| Phase | Expected Behavior |
|------|------------------------|
| **Online** | [Default behavior] |
| **Offline** | [Does feature work without connectivity?] |
| **Sync** | [Behavior during synchronization?] |

### Security and Access

- [ ] Specific authentication/authorization requirements?
- [ ] Handling of sensitive data?
- [ ] Cross-cutting business rules (e.g., permissions, times)?
