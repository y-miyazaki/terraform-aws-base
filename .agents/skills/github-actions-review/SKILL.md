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

Return review output with `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues`.

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

## Workflow

1. Read PR context and workflow intent; extract events, `permissions`, secret usage, and external action references.
2. Confirm `github-actions-validation` results are attached; if missing, request rerun and defer all validator-dependent checks.
3. Review relevant checklist categories and collect failed/deferred items.
4. Order issues in output by severity: `SEC-*` first, then correctness, then maintainability.
5. Output report with the required sections per [references/common-output-format.md](references/common-output-format.md).

## Examples

- Prompt: `Review workflow PR and report failed/deferred checks.`
- Output: `## Checks Summary` + `## Checks (Failed/Deferred Only)` + `## Issues`, with each issue including file path, line, and remediation.

## Error Handling and Troubleshooting

- If evidence is partial, mark affected checks as deferred with explicit reason.
- If workflow YAML is malformed, report syntax-related review checks as deferred and keep policy/design findings separate.

## Best Practices

- Include file path, line reference, and remediation step for each issue.
- Keep scope decisions in Workflow step 2 and avoid duplicating them in other sections.
