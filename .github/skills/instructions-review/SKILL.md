---
name: instructions-review
description: >-
  Reviews .instructions.md files for structure, completeness, consistency, and practical usability.
  Checks 4-chapter structure, validation commands, and cross-file consistency requiring human judgment.
  Use when reviewing instructions file pull requests, standardizing instructions, or auditing documentation quality.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Instructions file(s) (required) - `.github/instructions/*.instructions.md`
- Reference files for comparison (optional) - `go.instructions.md`, `github-actions-workflow.instructions.md`
- `aqua.yaml` file (optional) - For tool coverage context
- PR description and context (optional)

## Output Specification

**Output format (MANDATORY)** - Use this exact structure:

- Checks Summary: Total/Passed/Failed/Deferred counts
- Checks (Failed/Deferred Only): Show only ❌ and ⊘ items in checklist order
- Issues: Numbered list with full details for each failed or deferred item
- Use fixed ItemIDs from [references/common-checklist.md](references/common-checklist.md)
- If all pass: "No failed or deferred checks" / "No issues found"

See [references/common-output-format.md](references/common-output-format.md) for detailed format specification.

## Execution Scope

- Systematically apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- Focus on quality, structure, consistency, and practical usability requiring human/AI judgment
- **Do not execute validation commands from this review skill**
- Do not modify instructions files or approve/merge PRs
- Required 4-chapter structure: Standards → Guidelines → Testing and Validation → Security Guidelines
- Minimum standards: 70+ lines, 3+ validation commands, 4 chapters

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Complete review checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when encountering frequent review issues

**Category Details** (read when reviewing related aspects):

- [category-global.md](references/category-global.md) - Read when reviewing front matter or chapter hierarchy
- [category-standards.md](references/category-standards.md) - Read when reviewing naming conventions or tool standards
- [category-guidelines.md](references/category-guidelines.md) - Read when reviewing documentation or modification procedures
- [category-testing.md](references/category-testing.md) - Read when reviewing validation commands or tool coverage
- [category-security.md](references/category-security.md) - Read when reviewing security guidelines or secrets management
- [category-quality.md](references/category-quality.md) - Read when reviewing content quality, cross-file consistency, or completeness

## Workflow

1. **Verify Structure** - Confirm 4 required chapters exist in correct order
2. **Systematic Review** - Review by priority: 🔴 Critical (STRUCT, COMP) → 🟡 Important (STD, GUIDE, TEST, SEC) → 🟢 Enhancement (QUAL, CONS)
3. **Report Issues** - Output in the format below

## Output Format

```markdown
# Instructions Review Result

## Checks Summary

- Total checks: 26
- Passed: 24
- Failed: 2
- Deferred: 0

## Checks (Failed/Deferred Only)

- STRUCT-01 Four Required Chapters: ❌ Fail
- TEST-02 Command Count: ❌ Fail

## Issues

1. STRUCT-01: Four Required Chapters
   - Problem: Security Guidelines chapter missing
   - Impact: Missing security guidelines, incomplete standardization
   - Recommendation: Add Security Guidelines chapter covering secrets management and best practices

2. TEST-02: Command Count
   - Problem: Only 2 validation commands documented
   - Impact: Reduced test coverage, insufficient quality assurance
   - Recommendation: Review aqua.yaml and expand to minimum 3 items
```

## Best Practices

- **Reference Files**: Review `go.instructions.md` (222 lines) and `github-actions-workflow.instructions.md` (180 lines) as examples
- **Consistency Priority**: Prioritize consistency with existing files over new additions
- **Practical Focus**: Emphasize executable and practical content
