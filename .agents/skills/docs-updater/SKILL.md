---
name: docs-updater
description: >-
  Detect documentation drift and patch affected docs — via git diff (hooks, manual)
  or structured detect JSON from an external caller. Keeps references, links, tables,
  and nav entries accurate. Use when syncing docs after code changes, before PRs, on doc
  sync requests, or when automation reports documentation drift. Default is survey
  only; edit documentation files only when the user explicitly requests a fix or
  caller constraints allow edits. Not for new document
  creation (use docs-creator) or markdown linting (use markdown-validation).
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "3.4.0"
---

**UTILITY SKILL** — automated diff-sync and drift repair, not content authoring.

## Input

- **Interactive / hook:** `scope` (`staged`, `all`, `range` with `--since`) — run this skill's detect script — triage per [common-impact-map.md](references/common-impact-map.md); validate patches per [common-checklist.md](references/common-checklist.md)
- **Automation:** caller-assembled prompt with detect JSON and optional `## Constraints` — load [category-input-schema.md](references/category-input-schema.md) and [category-automation-envelope.md](references/category-automation-envelope.md) on that path only

## Output Specification

Report per [common-output-format.md](references/common-output-format.md). On the automation path, also follow [common-output-format-automation.md](references/common-output-format-automation.md) and [category-automation-envelope.md](references/category-automation-envelope.md). Stay within [category-scope.md](references/category-scope.md).

## Execution Scope

Target: root `*.md`, `docs/**/*.md`, nested `**/README.md` (excluding generated directories), and `mkdocs.yml` (nav section) when present.

### USE FOR:

- Update cross-references, tables, lists, and nav entries for changed paths
- Remove dead links; update paths for renames
- Apply minimal documentation patches per [common-checklist.md](references/common-checklist.md) and [category-documentation-maintenance.md](references/category-documentation-maintenance.md)

### DO NOT USE FOR:

- New document creation or content improvement (use docs-creator)
- Non-documentation file edits
- Markdown linting (use markdown-validation)
- Run detection scripts for other skills or manage caller state

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-impact-map.md](references/common-impact-map.md) (read on interactive path)
- [category-documentation-maintenance.md](references/category-documentation-maintenance.md) (read when deduplication or same-change sync applies)
- [category-scope.md](references/category-scope.md) (always read)
- [category-input-schema.md](references/category-input-schema.md) (read on automation path)
- [category-automation-envelope.md](references/category-automation-envelope.md) (read on automation path)
- [common-output-format-automation.md](references/common-output-format-automation.md) (read on automation path)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)

## Workflow

Resolve whether to edit documentation files before patching:

| Source                                                             | Edit docs                                                                                       |
| ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| Interactive / hook — default                                       | No — survey only                                                                                |
| Interactive / hook — fix language in the same request              | Yes — examples: fix, sync, update docs, 修正して                                                |
| Interactive / hook — follow-up after a prior survey in the session | Yes when the user asks to fix, apply, or patch documentation                                    |
| Automation — `## Constraints`                                      | Per `may_edit` in [category-automation-envelope.md](references/category-automation-envelope.md) |

### Interactive / hook path

1. Run this skill's detect script with `--scope <scope>`. On non-zero exit, read stdout and stop. On exit 0, parse success JSON.
2. IF `skip` is `true` → report skip and exit.
3. Triage `affected_docs` per [common-impact-map.md](references/common-impact-map.md); grep before full read.
4. IF edits are not requested → emit survey shape per [common-output-format.md](references/common-output-format.md); stop — do not edit documentation files or run `git add`.
5. ELSE → apply minimal patches per [common-checklist.md](references/common-checklist.md); regenerate `docs/index.md` when `docs/` files created/deleted/renamed; stage with `git add`; emit apply shape per [common-output-format.md](references/common-output-format.md).

### Automation path

When detect JSON and `## Constraints` are present: follow [category-automation-envelope.md](references/category-automation-envelope.md) for edit gate, report shape, and synthesis. Triage and patch per [common-checklist.md](references/common-checklist.md) and [category-documentation-maintenance.md](references/category-documentation-maintenance.md). Do not manage caller state.

### Error Handling

| Condition                                           | Severity    | Action                                                                                        |
| --------------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------- |
| Detect script non-zero exit or `status: "error"`    | Fatal       | Read stdout; stop — do not treat as success-path detect JSON                                  |
| No git repository                                   | Fatal       | Stop                                                                                          |
| Empty diff / no documentation impact                | Info        | Report skip, exit                                                                             |
| Affected doc file missing                           | Recoverable | Skip file; note in report                                                                     |
| Exceeds scope (>3 H2, new top-level document, etc.) | Recoverable | Stop for file; recommend docs-creator                                                         |
| `mkdocs.yml` missing                                | Recoverable | Skip nav update                                                                               |
| Fix requested but edits not allowed                 | Info        | Survey only; note that edits require an explicit fix request or caller permission             |
| Automation `write_target` mismatch                  | Recoverable | Survey only per [category-automation-envelope.md](references/category-automation-envelope.md) |

### Examples

- Prompt: `Sync docs after the latest commit diff`
- Result: Survey or apply report per [references/common-output-format.md](references/common-output-format.md); stay within UV scope gates.
