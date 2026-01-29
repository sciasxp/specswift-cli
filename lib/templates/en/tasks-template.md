# Tasks: [FEATURE NAME]

**Feature**: [SHORT_NAME]  
**Branch**: `feature/[SHORT_NAME]`  
**Status**: Draft | In Review | Approved  
**PRD**: `_docs/specs/[SHORT_NAME]/prd.md`  
**TechSpec**: `_docs/specs/[SHORT_NAME]/techspec.md`

<!--
  OUTPUT CONTRACT (do not remove; used by workflows and /specswift.analyze):
  - Each task line MUST match: - [ ] T<ID> [P?] [US<N>?] <description> in `path`
  - Sub-blocks: **Acceptance Criteria**: (at least one, with PRD ref FR-xxx/NFR-xxx when applicable); **Unit Tests**: (list of test method names; MANDATORY for implementation tasks).
  - When path or dependency cannot be determined: use path/to/... and "Depends on T0xx" in description; do not invent paths not in STRUCTURE.md.
-->

---

### 📍 Workflow

```
✅ PRD → ✅ TechSpec → ✅ Tasks (current) → ⭕ Implementation
```

**Next step**: After approval, run `/specswift.implement` or `/specswift.analyze` to validate

---

**TDD and Definition of Done**:
- Development must start with **writing tests before implementation** (TDD).
- A **task is complete** only when it is tested and implemented with **all tests passing** (code compiles, tests pass, acceptance criteria met).
- Implementation should focus on **one Phase at a time**; when concluding a phase (definition of done): verify tasks.md is updated and coherent with what was done and generate a commit message for the phase.

---

**Prerequisites**: techspec.md (mandatory), prd.md (mandatory for user stories)

**Organization**: Tasks are grouped by user story (US1, US2, US3...) to allow independent implementation and testing.

**INVEST principle** ([ref.](https://pm3.com.br/blog/como-usar-o-principio-invest-para-escrever-e-quebrar-user-stories/)): Each task must be — **I**ndependent (as much as possible from others), **N**egotiable (clear essence, details can evolve), **V**aluable (delivers value tied to PRD), **E**stimable (reasonably predictable effort), **S**mall (completable in one cycle; if too large, split into more tasks), **T**estable (acceptance criteria and unit tests defined).

## Task Format

Each task must follow the structure below to ensure compliance with the analysis gate (`/specswift.analyze`):

```markdown
- [ ] [ID] [P?] [Story] Task description with file path
  - **Acceptance Criteria**:
    - [ ] [Criterion 1 from PRD/Techspec]
  - **Unit Tests**:
    - [ ] `test_<functionality>_<scenario>_<expected_result>`
```

- **[P]**: Can run in parallel
- **[Story]**: User Story ID (e.g., US1)
- **Unit Tests**: MANDATORY for all logic/UI tasks.

## Reference Documentation

Before creating tasks, consult the project documentation:

| Document | Content | Usage |
|-----------|----------|-----|
| `README.md` | Overview and commands | Build/test commands |
| `_docs/PRODUCT.md` | Business rules | Validate functional requirements |
| `_docs/STRUCTURE.md` | Architecture and folders | File paths |
| `_docs/TECH.md` | Stack and patterns | Technologies and pitfalls |
| `.cursor/rules/` or `.windsurf/rules/` | Code style | Implementation conventions |

<!-- 
  ============================================================================
  IMPORTANT: The tasks below are EXAMPLE TASKS for illustration only.
  
  The /specswift.tasks command MUST replace these with real tasks based on:
  - User stories from prd.md (with their priorities P1, P2, P3...)
  - Feature requirements from techspec.md
  - Entities from data-model.md
  - Endpoints from contracts/
  
  Tasks MUST be organized by user story so that each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment
  
  DO NOT keep these example tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

<!-- 
  NOTE: If no .xcodeproj exists, XcodeGen tasks should be added FIRST:
  - [ ] T001 Create project.yml from template (if needed)
  - [ ] T002 Run `xcodegen generate` to create .xcodeproj
  Then continue with T003, T004, etc.
-->

- [ ] T001 Create project structure as per implementation plan in techspec.md
- [ ] T002 Ensure project compiles and dependencies resolve
- [ ] T003 [P] Configure linting and formatting tools

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story is implemented

**⚠️ CRITICAL**: No user story work can start until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T004 Configure persistence + migration entry points
- [ ] T005 [P] Implement auth/token foundations (secure storage, expiration checks)
- [ ] T006 [P] Confirm networking conventions (endpoints, shared service usage)
- [ ] T007 Create/confirm base models/entities used across stories
- [ ] T008 Configure error reporting/logging conventions
- [ ] T009 Configure environment/config toggles (debug, feature flags)

**Checkpoint**: Foundation ready - user story implementation can start in parallel

---

## Phase 3: US1 - [Title] (Priority: P1) 🎯 MVP

**Objective**: [Brief description of what this story delivers]

**Independent Test**: [How to verify if this story works on its own]

### Tests for US1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T010 [P] [US1] Unit tests for [ViewModel/Model]
  - **Acceptance Criteria**:
    - [ ] Tests fail initially
    - [ ] Coverage of success and error scenarios
  - **Unit Tests**:
    - [ ] `test_init_state()`
    - [ ] `test_load_success()`

### Implementation for User Story 1

- [ ] T012 [P] [US1] Create/update model(s)
  - **Acceptance Criteria**:
    - [ ] Entity mapped correctly
    - [ ] Mandatory fields defined
  - **Unit Tests**:
    - [ ] `test_entity_mapping()`
    - [ ] `test_primary_key()`

- [ ] T013 [P] [US1] Create/update repository/manager
  - **Acceptance Criteria**:
    - [ ] Basic CRUD implemented
    - [ ] DB error handling
  - **Unit Tests**:
    - [ ] `test_save_success()`
    - [ ] `test_fetch_returns_data()`

- [ ] T014 [US1] Implement business logic (depends on T012, T013)
  - **Acceptance Criteria**:
    - [ ] Business rules X and Y validated
  - **Unit Tests**:
    - [ ] `test_business_logic_rule_x()`

- [ ] T015 [US1] Implement UI flow and navigation wiring
  - **Acceptance Criteria**:
    - [ ] Screen follows design system
    - [ ] Navigation works correctly
  - **Unit Tests**:
    - [ ] `test_view_loading()`
    - [ ] `test_button_action()`

- [ ] T016 [US1] Add validation and error handling
  - **Acceptance Criteria**:
    - [ ] User-friendly errors
  - **Unit Tests**:
    - [ ] `test_error_presentation()`

- [ ] T017 [US1] Add diagnostics (breadcrumbs, monitoring events if applicable)
  - **Acceptance Criteria**:
    - [ ] Analytics events fired
  - **Unit Tests**:
    - [ ] `test_analytics_event_trigger()`

**Checkpoint**: At this point, US1 should be fully functional and independently testable

---

## Phase 4: US2 - [Title] (Priority: P2)

**Objective**: [Brief description of what this story delivers]

**Independent Test**: [How to verify if this story works on its own]

### Tests for US2

- [ ] T018 [P] [US2] Unit tests for [component]
  - **Acceptance Criteria**:
    - [ ] Coverage of new use cases
  - **Unit Tests**:
    - [ ] `test_new_feature_behavior()`

### Implementation for US2

- [ ] T020 [P] [US2] Create/update model
  - **Acceptance Criteria**:
    - [ ] New fields/entities added
  - **Unit Tests**:
    - [ ] `test_model_update()`

- [ ] T021 [US2] Implement changes in repository/manager and business logic
  - **Acceptance Criteria**:
    - [ ] Persistence logic updated
  - **Unit Tests**:
    - [ ] `test_repo_update()`

- [ ] T022 [US2] Implement UI changes + navigation
  - **Acceptance Criteria**:
    - [ ] New screen/component integrated
  - **Unit Tests**:
    - [ ] `test_ui_update()`

- [ ] T023 [US2] Integrate with US1 components (if necessary)
  - **Acceptance Criteria**:
    - [ ] No regression in US1
  - **Unit Tests**:
    - [ ] `test_integration_us1_us2()`

**Checkpoint**: At this point, US1 and US2 should work independently

---

## Phase 5: US3 - [Title] (Priority: P3)

**Objective**: [Brief description of what this story delivers]

**Independent Test**: [How to verify if this story works on its own]

### Tests for US3

- [ ] T024 [P] [US3] Unit tests for [component]
  - **Acceptance Criteria**:
    - [ ] Complex logic validated
  - **Unit Tests**:
    - [ ] `test_complex_logic()`

### Implementation for US3

- [ ] T026 [P] [US3] Create/update model
  - **Acceptance Criteria**:
    - [ ] Model finalized
  - **Unit Tests**:
    - [ ] `test_final_model_state()`

- [ ] T027 [US3] Implement changes in repository/manager and business logic
  - **Acceptance Criteria**:
    - [ ] Full persistence
  - **Unit Tests**:
    - [ ] `test_full_persistence()`

- [ ] T028 [US3] Implement UI changes + navigation
  - **Acceptance Criteria**:
    - [ ] Polished and functional UI
  - **Unit Tests**:
    - [ ] `test_final_ui_state()`

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-cutting Concerns

**Purpose**: Improvements affecting multiple user stories

- [ ] TXXX [P] Documentation updates in `_docs/`
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Additional unit tests
- [ ] TXXX Hardened security
- [ ] TXXX Run `make test` for relevant targets

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Dependent on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 -> P2 -> P3)
- **Polish (Final Phase)**: Dependent on completion of all desired user stories

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but must be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but must be independently testable

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Models/Repositories before ViewModels/ViewControllers
- Repositories before networking changes (endpoints)
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational -> Foundation ready
2. Add User Story 1 -> Test independently -> Deploy/Demo (MVP!)
3. Add User Story 2 -> Test independently -> Deploy/Demo
4. Add User Story 3 -> Test independently -> Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story must be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same-file conflicts, dependencies between stories that break independence

---

## Integration and Verification Tasks *(mandatory)*

<!--
  CRITICAL: These tasks should be adapted to the patterns described in _docs/TECH.md.
  Add in Phase N (Polish) or where appropriate.
-->

### Mandatory Checks

- [ ] TXXX Verify impact on persistence and migrations
- [ ] TXXX Add diagnostics/logging for debugging
- [ ] TXXX Verify behavior in different network states (online/offline)
- [ ] TXXX Test in all configured environments

### Pattern Checks

- [ ] TXXX Follow project navigation patterns
- [ ] TXXX Data access via persistence layer (not direct in Views)
- [ ] TXXX Business logic in Models/Services (not in UI)
- [ ] TXXX Sensitive data in secure storage (e.g., Keychain)

### Documentation

- [ ] TXXX Update technical documentation if new modules created
- [ ] TXXX Update CHANGELOG if significant feature
