# Development Guidelines: [FEATURE_NAME]

**Feature**: [SHORT_NAME]  
**Branch**: `feature/[SHORT_NAME]`  
**Generated**: [DATE]

---

### 📍 Workflow

```
✅ PRD → ✅ TechSpec → ✅ Tasks → ✅ Implementation (current)
```

**Artifacts**: `_docs/specs/[SHORT_NAME]/`

## Reference Documentation

| Document | Content | When to Consult |
|-----------|----------|------------------|
| `README.md` | Overview and commands | Build, test, run |
| `_docs/PRODUCT.md` | Business rules | Requirements validation |
| `_docs/STRUCTURE.md` | Architecture and folders | Where to create files |
| `_docs/TECH.md` | Stack and patterns | Technologies and pitfalls |
| `.windsurf/rules/` | Code style | Implementation conventions |

## Feature Context

**Objective**: [Extracted from PRD - main objective]

**Main Files**:
- `[Path]/Models/[Entity].swift` - Data models
- `[Path]/ViewModels/[Feature]ViewModel.swift` - Presentation logic
- `[Path]/Views/[Feature]View.swift` - User interface

## Useful Commands

```bash
# Build and test
make build          # Compile project
make test           # Run tests
make run            # Run in simulator

# Verifications
make lint           # Check code style
```

## Feature Technical Decisions

| Decision | Choice | Reasoning |
|---------|---------|---------------|
| [Decision 1] | [Choice] | [Why] |

## Implementation Notes

- [Important note 1]
- [Important note 2]

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
