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

Minimal inline contract (fallback only — use `common-output-format.md` when available):

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

Always include target file list and deferred reason summary.

## Execution Scope

- Systematically apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- Focus on quality, structure, consistency, and practical usability requiring human/AI judgment
- **Do not execute validation commands from this review skill**
- Do not modify instructions files or approve/merge PRs
- Keep chapter order and section naming aligned with existing `.instructions.md` files in the same repository.

### USE FOR:

- review existing `.instructions.md` files in PRs
- audit instruction quality and rule consistency
- propose review findings without modifying files

### DO NOT USE FOR:

- create new instruction files from scratch
- run syntax/security validation tooling
- review general markdown docs outside `**/instructions/*.instructions.md` (e.g., README.md, docs/*.md — use markdown-validation or docs-creation instead)

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when checks fail unexpectedly.
- [category-global.md](references/category-global.md), [category-testing.md](references/category-testing.md), [category-security.md](references/category-security.md) - Read when reviewing overall quality, testing instructions, or security guidelines.
- [category-quality.md](references/category-quality.md), [category-guidelines.md](references/category-guidelines.md), [category-standards.md](references/category-standards.md) - Read when reviewing quality criteria, authoring guidelines, or compliance standards.
- When uncertain which categories apply, default to: category-global, category-quality, category-standards.

## Workflow

1. Read PR context and identify target instruction files.
2. Confirm pre-existing deterministic check artifacts (`waza check` and relevant validation logs) are available; if missing, request rerun once.
3. If target file does not exist, return `status: failed` for that file and continue remaining targets. Process all target files independently — one failure does not stop the review of others.
4. If deterministic artifacts remain unavailable after one rerun request, defer check-dependent items with explicit reason.
5. If PR context is unavailable, run file-only review and mark PR-context checks as deferred.
6. Verify required chapter order (Scope → Standards → Guidelines → Testing and Validation → Security Guidelines), then review checklist priorities and collect failed/deferred ItemIDs.
7. Output required report sections per [references/common-output-format.md](references/common-output-format.md).

### Severity and Status Rules

| Status | When to use |
|---|---|
| Failed | Check evaluated and issue confirmed with concrete evidence (file + line or missing element) |
| Deferred | Check cannot be evaluated — validation artifacts missing, category file unavailable, or PR context absent |
| Passed | Check evaluated and no issue found (counted in summary only) |

Key evaluation criteria (inline summary of common-checklist):
- **Structure**: 5 H2 chapters in correct order (Scope → Standards → Guidelines → Testing and Validation → Security Guidelines)
- **Guidelines format**: H3 headings with category IDs, rule bullets with `(LEVEL)`, `Check:` child bullets
- **Code Modification Guidelines**: must exist in every file
- **No empty sections**: every H3 must have content

### Error Handling

| Condition | Severity | Action |
|---|---|---|
| `common-checklist.md` unavailable | Fatal | Stop, report missing dependency |
| `common-output-format.md` unavailable | Recoverable | Use inline output contract |
| Category reference file missing | Recoverable | Defer checks from that category, note missing file in report |
| All category files missing | Fatal | Stop, report "no evaluation criteria available" |
| Target `.instructions.md` does not exist | Recoverable | Report `status: failed` for that file, continue remaining targets |
| All target files missing | Fatal | Stop, report "no reviewable instruction files found" |
| Validation artifacts missing after one rerun request | Recoverable | Defer artifact-dependent checks with explicit reason |

