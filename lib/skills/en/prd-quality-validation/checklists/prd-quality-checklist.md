# Specification Quality Checklist: [FEATURE NAME]

**Purpose**: Validate completeness and quality of the specification before proceeding to technical planning  
**Created**: [DATE]  
**Feature**: `_docs/specs/[SHORT_NAME]/prd.md`

---

## Clarification Phase Completed

- [ ] All clarification questions have been asked and answered
- [ ] User flows and scenarios confirmed with user
- [ ] Scope boundaries explicitly defined
- [ ] Success criteria confirmed as measurable

## Content Quality

- [ ] No implementation details (languages, frameworks, APIs)
- [ ] Focused on user value and business needs
- [ ] Written for non-technical stakeholders
- [ ] All mandatory sections completed
- [ ] Document under 1,000 words (main content)

## Requirements Completeness

- [ ] No `[NEEDS CLARIFICATION]` markers remaining (or max 3 if critical)
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable
- [ ] Success criteria are technology-agnostic (no implementation details)
- [ ] All acceptance scenarios are defined
- [ ] Edge cases are identified
- [ ] Scope is clearly delimited
- [ ] Dependencies and assumptions identified

## Feature Readiness

- [ ] All functional requirements have clear acceptance criteria
- [ ] User scenarios cover main flows
- [ ] Feature meets measurable results defined in Success Criteria
- [ ] No implementation details leak into the specification

## Critical Flow

- [ ] Feature's critical flow is documented (text or Mermaid diagram)
- [ ] Critical flow covers the happy path
- [ ] Critical flow identifies important decision points
- [ ] Critical flow is understandable for non-technical stakeholders

## UI/UX (if applicable)

- [ ] Mockups or wireframes of main screens are included
- [ ] Navigation flow is documented
- [ ] Error and loading states are considered
- [ ] Accessibility requirements are identified

## Notes

- Incomplete items require PRD updates before `/specswift.clarify` or `/specswift.create-techspec`
- Maximum of 3 `[NEEDS CLARIFICATION]` markers allowed (only for critical decisions)
- High severity issues must be resolved before proceeding

---

**Validation Status**: ⭕ Pending | ⚠️ Requires Adjustments | ✅ Approved

**Last Validation**: [DATE]  
**Validator**: [Name/AI]
