---
name: go-review
description: >-
  Review Go code for security, correctness, performance, and maintainability.
  Use when reviewing Go PRs requiring judgment beyond automated checks.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Go files in PR (required)
- PR context with validation evidence reference (required)

## Output Specification

Return structured review output with `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues` using fixed ItemIDs.

## Execution Scope

- Systematically apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- Focus on checks requiring human/AI judgment (design, concurrency, security patterns)
- **Do not run go-validation or execute gofumpt/go vet/golangci-lint/go test/govulncheck**
- Do not modify code files or approve/merge PRs

### USE FOR:

- review Go PRs after validation output exists
- assess design, security, and concurrency risks not covered by static checks
- perform risk-focused review on multi-package changes

### DO NOT USE FOR:

- run formatting/lint/test/vulnerability command pipelines
- implement code fixes directly
- review non-Go-only changes without Go source impact

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [global](references/category-global.md), [concurrency](references/category-concurrency.md), [errors](references/category-error-handling.md), [security](references/category-security.md)
- [arch](references/category-architecture.md), [standards](references/category-code-standards.md), [context](references/category-context.md), [deps](references/category-dependencies.md)
- [docs](references/category-documentation.md), [func](references/category-function-design.md), [perf](references/category-performance.md), [testing](references/category-testing.md)

## Workflow

1. Read PR context and change intent.
2. Confirm `go-validation` results exist; if missing, request rerun and defer validator-dependent checks.
3. Review relevant checklist categories and collect failed/deferred ItemIDs.
4. Output required report sections per [references/common-output-format.md](references/common-output-format.md).
5. Exclude generated files and `vendor/` from primary findings unless they introduce security-critical risk.
6. For very large PRs (>50 changed Go files), prioritize security/correctness checks first and defer low-risk style checks if evidence is insufficient.

## Error Handling and Troubleshooting

- If validation output stays unavailable after one rerun request, continue with reviewable items and defer the rest.
- If PR context is incomplete, list missing evidence and mark impacted checks as deferred.

## Best Practices

- Include file path and line reference for each finding.
- Prioritize `SEC-*` findings first.
