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

Output a structured Markdown review report for Agent Skills.

- Use fixed ItemIDs from [references/common-checklist.md](references/common-checklist.md)
- Follow the full output contract in [references/common-output-format.md](references/common-output-format.md)
- If all pass, report that no failed or deferred checks were found

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
- [common-output-format.md](references/common-output-format.md) - This review skill's own report format specification

**Category Details** (read when reviewing related aspects):

- [category-patterns.md](references/category-patterns.md) - Read when checking design pattern compliance (P-01, P-02)
- [category-quality.md](references/category-quality.md) - Read when checking quality standards (Q-01 through Q-06, BP-03)
- [category-structure.md](references/category-structure.md) - Read when checking structural requirements (S-01, S-02, BP-01, BP-02)

## Workflow

### Step 1: Understand Context

Read PR description and target skill purpose.

### Step 2: Automated Checks First

Confirm deterministic checks from `scripts/validate.sh` have been run. If execution is missing or failing, request rerun before semantic review.

### Step 3: Systematic Review

Apply quality checks (Q-01–Q-06) and pattern checks (P-01–P-02) using reference files. Confirm that `common-output-format.md` matches the target skill's actual output contract.

### Step 4: Report Issues

Output according to [references/common-output-format.md](references/common-output-format.md).

## Best Practices

- **Constructive and specific**: Include concrete examples and reference to existing well-structured skills
- **Context-aware**: Understand skill purpose and target audience, consider tradeoffs
- **Clear priorities**: Distinguish between CRITICAL (structural) and ENHANCEMENT (quality improvements)
- **Prevent scope creep**: Pay special attention to Q-02 Scope Boundaries items
