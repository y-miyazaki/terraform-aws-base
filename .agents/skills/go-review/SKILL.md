---
name: go-review
description: >-
  Review Go code for security, correctness, performance, and maintainability.
  Use when reviewing Go PRs requiring judgment beyond automated checks.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.1.0"
---

## Input

- Go files in PR or changeset (required)
- PR context: diff, commit messages, and `go-validation` output (required for PR review; for ad-hoc file review without PR, skip step 2 and evaluate all applicable checks directly)

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
- Focus on checks requiring human/AI judgment (design, concurrency, security patterns)
- **Do not run go-validation or execute gofumpt/go vet/golangci-lint/go test/govulncheck**
- Do not modify code files or approve/merge PRs

### USE FOR:

- review Go PRs where `.go` files are in the changeset (validation output may or may not exist)
- assess design, security, and concurrency risks not covered by static checks
- perform risk-focused review on multi-package changes
- ad-hoc review of Go source files outside a PR context

### DO NOT USE FOR:

- run formatting/lint/test/vulnerability command pipelines (use go-validation)
- implement code fixes directly
- changesets containing only non-Go files (e.g., docs-only, CI config-only)

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-global.md](references/category-global.md), [category-concurrency.md](references/category-concurrency.md), [category-error-handling.md](references/category-error-handling.md), [category-security.md](references/category-security.md) - Read when reviewing overall quality, concurrency, error handling, or security.
- [category-architecture.md](references/category-architecture.md), [category-code-standards.md](references/category-code-standards.md), [category-context.md](references/category-context.md), [category-dependencies.md](references/category-dependencies.md) - Read when reviewing architecture, code standards, context usage, or dependencies.
- [category-documentation.md](references/category-documentation.md), [category-function-design.md](references/category-function-design.md), [category-performance.md](references/category-performance.md), [category-testing.md](references/category-testing.md) - Read when reviewing documentation, function design, performance, or tests.
- When uncertain which categories apply, default to reading: category-security, category-concurrency, category-error-handling, and category-global (the highest-risk categories). Read others only if the changeset touches relevant areas.
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read on failure or when evidence is unavailable

## Workflow

1. Read PR context and change intent.
2. Confirm `go-validation` results exist. If missing, inform the user that validation should run first, then proceed with a partial review: evaluate design, security, and concurrency checks (which do not require tool output) and defer lint/test/vuln-dependent checks (mark as `Deferred` with reason "validation evidence unavailable").
3. Review relevant checklist categories and collect failed/deferred ItemIDs.
4. Output required report sections per [references/common-output-format.md](references/common-output-format.md). Prioritize `SEC-*` findings first. Include file path and line reference for each finding.
5. Exclude generated files and `vendor/` from primary findings unless they introduce security-critical risk.
6. For very large PRs (>50 changed Go files), prioritize security/correctness checks first and defer low-risk style checks if evidence is insufficient.

### Severity and Status Rules

| Status | When to use |
|---|---|
| Failed | Finding is confirmed from source code with concrete evidence (file + line) |
| Deferred | Check cannot be evaluated — validation output missing, file too large to fully analyze, or ambiguous without runtime context |
| Passed | Check evaluated and no issue found (counted in summary only) |

Severity priority for Issues section ordering: `SEC-*` > `CON-*` > `ERR-*` > all others.

### Error Handling

| Condition | Severity | Action |
|---|---|---|
| `go-validation` output missing | Recoverable | Defer validator-dependent checks, review design/security checks that don't require tool output |
| `common-checklist.md` unavailable | Fatal | Stop, report missing dependency |
| `common-output-format.md` unavailable | Recoverable | Use inline output contract above |
| PR contains only generated/vendor files | Recoverable | Report "no reviewable Go source" and stop |
