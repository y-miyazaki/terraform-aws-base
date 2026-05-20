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

Return structured review output with `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues` using fixed ItemIDs.

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
- [global](references/category-global.md), [errors](references/category-error-handling.md), [security](references/category-security.md)
- [standards](references/category-code-standards.md), [deps](references/category-dependencies.md), [docs](references/category-documentation.md)
- [func](references/category-function-design.md), [logging](references/category-logging.md), [perf](references/category-performance.md), [testing](references/category-testing.md)

## Workflow

1. Read PR context and script intent.
2. Confirm `shell-script-validation` results exist; if missing, request rerun and defer validator-dependent checks.
3. Review checklist categories based on changed script paths and PR intent, then collect failed/deferred ItemIDs.
4. Output required report sections per [references/common-output-format.md](references/common-output-format.md).

## Error Handling and Troubleshooting

- If no shell scripts are changed in PR, return `status: skipped` with reason.
- If validation output remains unavailable after one rerun request, continue reviewable checks and defer the rest.
- If reference files are missing, report missing reference path and stop to avoid unverifiable review.

## Best Practices

- Include file path, risk type, and concrete remediation for each issue.
- Prioritize `SEC-*` findings first.
