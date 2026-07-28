---
name: shell-script-review
description: >-
  Review shell scripts for security, correctness, maintainability, and Bats suite
  pairing (TEST-00) with emphasis on operational safety.
  Use when reviewing shell script PRs requiring judgment beyond static checks,
  including whether paired Bats suites were added or updated per TEST-00.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.2.0"
---

## Input

- Shell script files in PR (required)
- Related Bats suites paired with changed scripts when present (recommended for TEST-00)
- PR context with validation evidence reference (required)
- Validation evidence: latest `shell-script-validation` summary with pass/fail/deferred counts and failed ItemIDs

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md). That file is the source of truth for the output contract.

## Execution Scope

- Systematically apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- Focus on checks requiring human/AI judgment (design, security, error handling patterns)
- **Do not run shell-script-validation or execute bash -n/shellcheck**
- Do not modify script files or approve/merge PRs

### USE FOR:

- review shell-script PRs after validation output is available
- assess operational safety and script maintainability risks
- review security-sensitive script changes requiring judgment
- verify Bats suite pairing (TEST-00) against companion Bats rules (stem `bats`)

### DO NOT USE FOR:

- execute `bash -n`, `shellcheck`, or validation scripts
- perform auto-remediation in source files
- review non-shell-only changes with no script impact

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [category-global.md](references/category-global.md) (always read)
- [category-security.md](references/category-security.md) (always read)
- [category-error-handling.md](references/category-error-handling.md) (always read)
- [category-anti-patterns.md](references/category-anti-patterns.md) (always read)
- [category-code-standards.md](references/category-code-standards.md) (always read)
- [category-dependencies.md](references/category-dependencies.md) (always read)
- [category-documentation.md](references/category-documentation.md) (always read)
- [category-function-design.md](references/category-function-design.md) (always read)
- [category-logging.md](references/category-logging.md) (always read)
- [category-testing.md](references/category-testing.md) (always read)

## Workflow

1. Read PR context and script intent.
2. Confirm `shell-script-validation` results exist. If missing, inform user that validation should run first, then proceed with partial review: evaluate security and error-handling checks directly from source, defer lint-dependent checks (mark as `Deferred` with reason "validation evidence unavailable").
3. Apply the full review checklist and collect failed/deferred ItemIDs.
4. Output required report sections per [references/common-output-format.md](references/common-output-format.md). Prioritize `SEC-*` findings first. Include file path, risk type, and concrete remediation for each issue.

### Error Handling

| Condition                                | Severity    | Action                                                                                                |
| ---------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| `shell-script-validation` output missing | Recoverable | Defer lint-dependent checks, review security/design directly                                          |
| `common-checklist.md` unavailable        | Fatal       | Stop, report missing dependency                                                                       |
| `common-output-format.md` unavailable    | Recoverable | Note missing file; emit `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues` only |
| PR contains only non-shell files         | Recoverable | Report "no reviewable shell scripts" and stop                                                         |

### Examples

- Prompt: `Review shell script changes for security and style`
- Result: Structured report per [references/common-output-format.md](references/common-output-format.md); include TEST-00 pairing judgment when scripts change.
