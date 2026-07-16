---
name: instructions-review
description: >-
  Review instruction and rule files for structure, consistency, applyTo precision,
  and portable cross-references — package sources (`*.instructions.md`) and APM-distributed
  targets (`.cursor/rules/*.mdc`, `.claude/rules/*.md`, `.kiro/steering/*.md`).
  Use when reviewing instruction PRs, audits, or distributed rule changes after `apm install`.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.1.0"
---

## Input

- Target instruction/rule files (required): package sources (`**/instructions/*.instructions.md`) and/or distributed targets (`.cursor/rules/*.mdc`, `.claude/rules/*.md`, `.kiro/steering/*.md`)
- Prefer package sources under `.apm/packages/**/.apm/instructions/` when both source and generated copies exist
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
- Keep chapter order and section naming aligned with sibling instruction/rule files in the same repository (source or distributed form).

### USE FOR:

- review package `*.instructions.md` and distributed Cursor/Claude/Kiro rule files in PRs
- audit applyTo precision, stem-based cross-references, and companion coverage (G-03, G-04, G-05)
- audit instruction quality and rule consistency
- propose review findings without modifying files

### DO NOT USE FOR:

- create new instruction files from scratch
- run syntax/security validation tooling
- review general markdown docs outside instruction/rule paths (e.g., README.md, docs/\*.md, skills — use markdown-validation, docs-creator, or agent-skills-review instead)

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

| Status   | When to use                                                                                               |
| -------- | --------------------------------------------------------------------------------------------------------- |
| Failed   | Check evaluated and issue confirmed with concrete evidence (file + line or missing element)               |
| Deferred | Check cannot be evaluated — validation artifacts missing, category file unavailable, or PR context absent |
| Passed   | Check evaluated and no issue found (counted in summary only)                                              |

Key evaluation criteria (inline summary of common-checklist):

- **Structure**: 5 H2 chapters in correct order (Scope → Standards → Guidelines → Testing and Validation → Security Guidelines)
- **Guidelines format**: H3 headings with category IDs, rule bullets with `(LEVEL)`, `Check:` child bullets
- **Code Modification Guidelines**: must exist in every file
- **No empty sections**: every H3 must have content

### Error Handling

| Condition                                            | Severity    | Action                                                            |
| ---------------------------------------------------- | ----------- | ----------------------------------------------------------------- |
| `common-checklist.md` unavailable                    | Fatal       | Stop, report missing dependency                                   |
| `common-output-format.md` unavailable                | Recoverable | Use inline output contract                                        |
| Category reference file missing                      | Recoverable | Defer checks from that category, note missing file in report      |
| All category files missing                           | Fatal       | Stop, report "no evaluation criteria available"                   |
| Target instruction/rule file does not exist          | Recoverable | Report `status: failed` for that file, continue remaining targets |
| All target files missing                             | Fatal       | Stop, report "no reviewable instruction files found"              |
| Validation artifacts missing after one rerun request | Recoverable | Defer artifact-dependent checks with explicit reason              |

### Examples

- Prompt: `Review instructions files and report issues`
- Prompt: `Review .cursor/rules/*.mdc applyTo and cross-references`
- Result: Structured report with per-file Checks Summary, failed/deferred items with severity and fix suggestions.
