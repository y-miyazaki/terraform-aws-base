---
name: shell-script-review
description: >-
  Review shell scripts for security, correctness, and maintainability with emphasis on operational safety.
  Use when reviewing shell script PRs requiring judgment beyond static checks.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Shell script files in PR (required)
- PR context with validation evidence reference (required)
- Validation evidence: latest `shell-script-validation` summary with pass/fail/deferred counts and failed ItemIDs

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
- Focus on checks requiring human/AI judgment (design, security, error handling patterns)
- **Do not run shell-script-validation or execute bash -n/shellcheck**
- Do not modify script files or approve/merge PRs

### USE FOR:

- review shell-script PRs after validation output is available
- assess operational safety and script maintainability risks
- review security-sensitive script changes requiring judgment

### DO NOT USE FOR:

- execute `bash -n`, `shellcheck`, or validation scripts
- perform auto-remediation in source files
- review non-shell-only changes with no script impact

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-global.md](references/category-global.md), [category-error-handling.md](references/category-error-handling.md), [category-security.md](references/category-security.md) - Read when reviewing overall quality, error handling, or security.
- [category-code-standards.md](references/category-code-standards.md), [category-dependencies.md](references/category-dependencies.md), [category-documentation.md](references/category-documentation.md) - Read when reviewing code standards, dependencies, or documentation.
- [category-function-design.md](references/category-function-design.md), [category-logging.md](references/category-logging.md), [category-performance.md](references/category-performance.md), [category-testing.md](references/category-testing.md) - Read when reviewing function design, logging, performance, or tests.
- When uncertain which categories apply, default to: category-security, category-error-handling, category-global.
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read on failure or when validation output is unavailable

## Workflow

1. Read PR context and script intent.
2. Confirm `shell-script-validation` results exist. If missing, inform user that validation should run first, then proceed with partial review: evaluate security and error-handling checks directly from source, defer lint-dependent checks (mark as `Deferred` with reason "validation evidence unavailable").
3. Review checklist categories based on changed script paths and PR intent, then collect failed/deferred ItemIDs.
4. Output required report sections per [references/common-output-format.md](references/common-output-format.md). Prioritize `SEC-*` findings first. Include file path, risk type, and concrete remediation for each issue.

### Error Handling

| Condition                                | Severity    | Action                                                       |
| ---------------------------------------- | ----------- | ------------------------------------------------------------ |
| `shell-script-validation` output missing | Recoverable | Defer lint-dependent checks, review security/design directly |
| `common-checklist.md` unavailable        | Fatal       | Stop, report missing dependency                              |
| `common-output-format.md` unavailable    | Recoverable | Use inline output contract                                   |
| PR contains only non-shell files         | Recoverable | Report "no reviewable shell scripts" and stop                |

### Examples

- Prompt: `Review shell script changes for security and style`
- Result: Structured report with per-file checks, failed items with severity/fix suggestions.
