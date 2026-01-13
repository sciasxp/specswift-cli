---
name: prd-quality-validation
description: Validates quality and completeness of PRDs (Product Requirements Documents) before proceeding to technical specification. Verifies that the PRD is complete, testable, and free of critical ambiguities.
---

# PRD Quality Validation

This skill validates the quality and completeness of PRDs following SpecSwift standards.

## When to use this skill

This skill is automatically invoked after PRD creation, but can also be used manually via `@prd-quality-validation` to validate existing PRDs.

## Validation Process

### 1. Load PRD and Checklist

1. Execute the prerequisites check script:
   ```bash
   _docs/scripts/bash/check-prerequisites.sh --json --require-prd
   ```

2. Parse the JSON to get:
   - `FEATURE_DIR`: Feature directory
   - `PRD`: PRD file path
   - `FEATURE_SPEC`: Spec path (may be PRD or legacy spec)

3. Load the PRD and quality checklist (if exists):
   - PRD: `$FEATURE_DIR/prd.md`
   - Checklist: `$FEATURE_DIR/checklists/requirements.md`

### 2. Execute Validations

Use the checklist in `checklists/prd-quality-checklist.md` as reference to validate:

#### Required Validations

1. **Section Completeness**:
   - [ ] Feature objective defined
   - [ ] Measurable success criteria
   - [ ] Numbered functional requirements
   - [ ] User scenarios described
   - [ ] Critical flow documented (text or diagram)

2. **Content Quality**:
   - [ ] No implementation details (languages, frameworks, APIs)
   - [ ] Focused on user value and business needs
   - [ ] Written for non-technical stakeholders
   - [ ] Document under 1,000 words (main content)

3. **Requirements Completeness**:
   - [ ] No `[NEEDS CLARIFICATION]` markers remaining (or max 3 if critical)
   - [ ] Requirements are testable and unambiguous
   - [ ] Success criteria are measurable
   - [ ] Success criteria are technology-agnostic
   - [ ] All acceptance scenarios are defined
   - [ ] Edge cases are identified
   - [ ] Scope is clearly delimited

4. **Readiness for TechSpec**:
   - [ ] All functional requirements have clear acceptance criteria
   - [ ] User scenarios cover main flows
   - [ ] Feature meets measurable results defined in Success Criteria

### 3. Generate Validation Report

Create a structured report:

```markdown
## PRD Validation Report

**Feature**: [SHORT_NAME]
**PRD**: `_docs/specs/[SHORT_NAME]/prd.md`
**Date**: [DATE]

### Overall Status
- ✅ Approved | ⚠️ Requires Adjustments | ❌ Blocked

### Summary
- Total validations: X
- Passed: Y
- Failed: Z

### Issues Found

| Item | Severity | Description | Recommended Action |
|------|----------|------------|-------------------|
| [Item 1] | High/Medium/Low | [Description] | [Action] |

### Recommendations

1. [Recommendation 1]
2. [Recommendation 2]

### Next Steps

- If approved: Proceed to `/specswift.create-techspec`
- If requires adjustments: Update PRD and revalidate
- If blocked: Resolve critical issues before continuing
```

### 4. Update Checklist

If the checklist doesn't exist, create it in `$FEATURE_DIR/checklists/requirements.md` using the template in `checklists/prd-quality-checklist.md`.

Update the checklist with validation results, marking items as complete (`[x]`) or incomplete (`[ ]`).

## Approval Criteria

The PRD is considered **approved** if:

1. All required validations pass
2. Maximum of 3 `[NEEDS CLARIFICATION]` markers (only for critical decisions)
3. No high severity issues found
4. Success criteria are measurable and technology-agnostic

## Integration with Workflows

This skill is automatically invoked by:

- `/specswift.create-prd` - After PRD creation
- `/specswift.clarify` - After clarifications
- `/specswift.analyze` - During coverage analysis

## Supporting Resources

- **Checklist**: `checklists/prd-quality-checklist.md` - Complete validation checklist
- **Template**: Use the checklist template as reference for creating new checklists

## Important Notes

- Validations are based on SpecSwift standards defined in `docs/SPECSWIFT-WORKFLOWS.md`
- High severity issues must be resolved before proceeding
- Medium/low severity issues can be documented as future improvements
