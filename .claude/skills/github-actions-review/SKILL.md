---
name: github-actions-review
description: >-
  Review GitHub Actions workflows for correctness, security, and maintainability.
  Use when assessing trigger design, permissions, secret usage, and action integrations requiring judgment.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Workflow YAML + PR context (required)

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Minimal inline contract (used if reference file is unavailable):

```markdown
## Checks Summary
- Total: <n>, Passed: <n>, Failed: <n>, Deferred: <n>

## Checks (Failed/Deferred Only)
| ItemID | Status | Evidence | Fix |

## Issues
1. <ItemID>: <title>
   - File: <path>#L<line>
   - Problem: <specific>
   - Recommendation: <fix>
```

## Execution Scope

- Systematically apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- **Do not run github-actions-validation or execute actionlint/ghalint/zizmor**
- Do not modify workflow files or approve/merge PRs

### USE FOR:

- review workflow security and correctness after validation output is available
- assess trigger design, permissions, and secrets handling with human judgment
- review multi-workflow PRs for policy and maintainability risks

### DO NOT USE FOR:

- execute syntax/security validators (`actionlint`, `ghalint`, `zizmor`)
- auto-fix workflow YAML files
- replace `github-actions-validation` for deterministic checks

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-global.md](references/category-global.md) - Read when reviewing triggers and permissions.
- [category-security.md](references/category-security.md) - Read when reviewing secrets and permission scoping.
- [category-best-practices.md](references/category-best-practices.md) - Read when reviewing maintainability.
- [category-error-handling.md](references/category-error-handling.md) - Read when reviewing failure handling behavior.
- [category-performance.md](references/category-performance.md) - Read when reviewing execution efficiency.
- [category-tool-integration.md](references/category-tool-integration.md) - Read when reviewing third-party action usage.
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read on failure or when evidence is partial

## Workflow

1. Read PR context and workflow intent; extract events, `permissions`, secret usage, and external action references.
2. Confirm `github-actions-validation` results are attached. If missing, inform user that validation should run first, then proceed with partial review: evaluate security and permissions checks directly from YAML, defer syntax/lint-dependent checks (mark as `Deferred` with reason "validation evidence unavailable").
3. Review relevant checklist categories and collect failed/deferred items.
4. Order issues in output by severity: `SEC-*` first, then correctness, then maintainability.
5. Output report with the required sections per [references/common-output-format.md](references/common-output-format.md). Include file path, line reference, and remediation step for each issue.

### Examples

- Prompt: `Review workflow PR and report failed/deferred checks.`
- Output: `## Checks Summary` + `## Checks (Failed/Deferred Only)` + `## Issues`, with each issue including file path, line, and remediation.

### Error Handling

| Condition | Severity | Action |
|---|---|---|
| `github-actions-validation` output missing | Recoverable | Defer lint-dependent checks, review security/permissions directly |
| `common-checklist.md` unavailable | Fatal | Stop, report missing dependency |
| `common-output-format.md` unavailable | Recoverable | Use inline output contract |
| PR contains no workflow YAML files | Recoverable | Report "no reviewable workflows" and stop |

