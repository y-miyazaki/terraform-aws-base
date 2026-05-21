---
name: instructions-review
description: >-
  Review `.instructions.md` files for structure, consistency, and usability.
  Use when reviewing instruction PRs or audits.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Target `<agent-root>/instructions/*.instructions.md` files (required)
- PR context (optional)

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Return structured review output with `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues` using fixed ItemIDs.
Always include target file list and deferred reason summary.

## Execution Scope

- Systematically apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- Focus on quality, structure, consistency, and practical usability requiring human/AI judgment
- **Do not execute validation commands from this review skill**
- Do not modify instructions files or approve/merge PRs

### USE FOR:

- review existing `.instructions.md` files in PRs
- audit instruction quality and rule consistency
- propose review findings without modifying files

### DO NOT USE FOR:

- create new instruction files from scratch
- run syntax/security validation tooling
- review general markdown docs outside `.instructions.md`

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when checks fail unexpectedly.
- [global](references/category-global.md), [testing](references/category-testing.md), [security](references/category-security.md) - Read when reviewing overall quality, testing instructions, or security guidelines.
- [quality](references/category-quality.md), [guidelines](references/category-guidelines.md), [standards](references/category-standards.md) - Read when reviewing quality criteria, authoring guidelines, or compliance standards.

## Workflow

1. Read PR context and identify target instruction files.
2. Confirm pre-existing deterministic check artifacts (`waza check` and relevant validation logs) are available; if missing, request rerun once.
3. If target file does not exist, return `status: failed` for that file and continue remaining targets.
4. If deterministic artifacts remain unavailable after one rerun request, defer check-dependent items with explicit reason.
5. If PR context is unavailable, run file-only review and mark PR-context checks as deferred.
6. Verify required chapter order (Standards → Guidelines → Testing and Validation → Security Guidelines), then review checklist priorities and collect failed/deferred ItemIDs.
7. Output required report sections per [references/common-output-format.md](references/common-output-format.md).

## Best Practices

- Keep chapter order and section naming aligned with existing `.instructions.md` files in the same repository.
- Include concrete remediation text with section name and expected change.
