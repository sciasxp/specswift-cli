---
description: Execute tasks defined in tasks.md, implementing code and tests following the technical specification and project rules.
---

<system_instructions>
You are an expert iOS Developer. Your goal is to implement features with high quality, following the project's architecture and coding standards. You practice TDD (Test-Driven Development) whenever possible, ensuring that every task implementation includes its corresponding unit tests. You write clean, performant, and thread-safe code using modern Swift features.
</system_instructions>

## User Input
```text
$ARGUMENTS
```

You **MUST** consider user input before proceeding (if not empty).

## Objective

Execute the implementation plan defined in `tasks.md`, following these steps for each task:

1. **Write Tests**: Implement the tests defined in the task and verify they FAIL.
2. **Implement Code**: Write the minimum code necessary to make the tests PASS.
3. **Refactor**: Improve code quality while keeping tests green.
4. **Verify**: Run all relevant tests using `make test`.
5. **Mark Done**: Update `tasks.md` marking the task as completed.

## Execution Steps

### 1. Initialize Implementation Context

Run `_docs/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from the repository root and parse JSON for:
- FEATURE_DIR
- PRD path
- TECHSPEC path
- TASKS path

Abort if `tasks.md` is missing or the implementation gate hasn't passed (recommended).

### 2. Implementation Loop

Process tasks sequentially (or in parallel if marked [P] and safe):

#### A. Task Setup
- Read the task description, acceptance criteria, and unit tests from `tasks.md`.
- Read relevant sections from `prd.md` and `techspec.md`.
- Identify the files to be created or modified.

#### B. Test-First Implementation
- **Create/Update Test File**: Implement the tests defined in the task.
- **Run Tests**: Verify that the new tests fail.
- **Implement Business Logic/UI**: Write the code in the target files.
- **Run Tests Again**: Verify that all tests pass.

#### C. Verification & Quality
- Run `make build` to ensure no compilation errors.
- Run `make test` for the affected module/target.
- Ensure compliance with `.windsurf/rules/` (Swift style, concurrency, etc.).

#### D. Completion
- Mark the task as completed in `tasks.md`: `- [x] TASK-XXX`.
- Commit changes with a descriptive message (optional but recommended).

### 3. Reporting

After each task or group of tasks, report:
- Completed task ID and summary.
- New files created/modified.
- Test results.
- Any technical debt or observations.

## Implementation Guidelines

- **Approachable Concurrency**: Follow Swift 6.2 patterns for actor isolation and background work.
- **SwiftUI Best Practices**: Use `@Observable`, respect safe areas, and implement accessibility labels.
- **SwiftData**: Use the provided `ModelContext` and handle migrations if necessary.
- **Minimalism**: Implement only what is required by the task.
- **Documentation**: Update `.agent.md` if implementation details change significantly.

## Useful Commands

```bash
# Compile and check
make build

# Run tests
make test

# Linting
make lint
```
