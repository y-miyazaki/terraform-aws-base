---
name: agent-skills-review
description: >-
  Reviews SKILL.md files for structural requirements, quality standards, and design patterns.
  Checks specification completeness, implementation feasibility, and consistency with established patterns.
  Use when creating new skills, reviewing skill pull requests, or auditing skill quality.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- SKILL.md file (required) - Target file to review (`.github/skills/*/SKILL.md`)
- PR description and skill overview context (recommended)

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
- Focus on quality, specification completeness, and design pattern compliance requiring human/AI judgment
- **Do not run yamllint or scripts/validate.sh from this review skill**
- Do not modify SKILL.md files or approve/merge PRs

**Design Philosophy**: Deterministic checks (structure, metrics, file existence) are automated in `scripts/validate.sh`. This review focuses on judgment-based evaluation (semantic quality, design decisions).

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Complete review checklist (S-01 through BP-03)
- [common-output-format.md](references/common-output-format.md) - Report format specification

**Category Details** (read when reviewing related aspects):

- [category-patterns.md](references/category-patterns.md) - Read when checking design pattern compliance (P-01, P-02)
- [category-quality.md](references/category-quality.md) - Read when checking quality standards (Q-01 through Q-06, BP-03)
- [category-structure.md](references/category-structure.md) - Read when checking structural requirements (S-01, S-02, BP-01, BP-02)

## Workflow

1. **Understand Context** - Read PR description, understand skill purpose and target background
2. **Systematic Review** - Apply quality checks (Q-01–Q-06) and pattern checks (P-01–P-02) using reference files
3. **Report Issues** - Output in the format below

## Output Format

```markdown
# Agent Skills Review Result

## Checks Summary

- Total checks: 10
- Passed: 8
- Failed: 2
- Deferred: 0

## Checks (Failed/Deferred Only)

- S-01 Section Order and Completeness: ❌ Fail
- Q-02 Scope Boundaries: ❌ Fail

## Issues

1. S-01: Section Order and Completeness
   - File: `.github/skills/example-skill/SKILL.md`
   - Problem: Missing "Execution Scope" section
   - Impact: Skill cannot clearly communicate what it does and does not do
   - Recommendation: Add `## Execution Scope` section

2. Q-02: Scope Boundaries
   - File: `.github/skills/example-skill/SKILL.md` L45
   - Problem: Out of Scope boundary unclear between this skill and related validation skill
   - Impact: Agent may attempt to run validation tools during review
   - Recommendation: Add explicit exclusion line for related validation skill
```

## Best Practices

- **Constructive and specific**: Include concrete examples and reference to existing well-structured skills
- **Context-aware**: Understand skill purpose and target audience, consider tradeoffs
- **Clear priorities**: Distinguish between CRITICAL (structural) and ENHANCEMENT (quality improvements)
- **Prevent scope creep**: Pay special attention to Q-02 Scope Boundaries items
