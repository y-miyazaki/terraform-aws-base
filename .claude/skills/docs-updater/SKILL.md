---
name: docs-updater
description: >-
  Detect documentation drift and patch affected docs — via git diff (hooks, manual)
  or loop-injected findings (integration branch scan). Keeps references, links, tables,
  and nav entries accurate. Use when syncing docs after code changes, before PRs, on doc
  sync requests, or when loop automation reports documentation drift. Default is survey
  only; edit documentation files only when the user explicitly requests a fix or
  automation sets may_edit in Constraints. Not for new document
  creation (use docs-creator) or markdown linting (use markdown-validation).
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "3.3.0"
---

**UTILITY SKILL** — automated diff-sync and drift repair, not content authoring.

## Input

- **Interactive / hook:** trigger source + `scope` (`staged`, `all`, `range` with `--since`) — run `scripts/detect_changes.sh` — parse per [common-checklist.md](references/common-checklist.md) and [common-impact-map.md](references/common-impact-map.md)
- **Automation:** `findings[]` JSON in prompt; read `may_edit`, `write_target`, and `report_file` (when `write_target: report`) from `## Constraints` per [category-automation-envelope.md](references/category-automation-envelope.md)

Path allowlist, when present, arrives in `## Constraints` (automation path).

## Output Specification

Interactive / hook: report per [common-output-format.md](references/common-output-format.md).
Automation: report per [common-output-format-loop.md](references/common-output-format-loop.md). Survey shape when documentation files are not edited; apply shape when edited — within [category-scope.md](references/category-scope.md).

## Execution Scope

Target: root `*.md`, `docs/**/*.md`, nested `**/README.md` (excluding generated directories), and `mkdocs.yml` (nav section).

### USE FOR:

- Update cross-references, tables, lists, and nav entries for changed paths
- Remove dead links; update paths for renames
- Automation: classify `findings[]`, fix High-Priority items when `may_edit` is `true` within allowlist

### DO NOT USE FOR:

- New document creation or content improvement (use docs-creator)
- Non-documentation file edits
- Markdown linting (use markdown-validation)
- Run detection or manage loop state

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read — interactive / hook path)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-impact-map.md](references/common-impact-map.md) (always read — interactive / hook path)
- [common-checklist-loop.md](references/common-checklist-loop.md) (always read — automation path)
- [common-output-format-loop.md](references/common-output-format-loop.md) (always read — automation path)
- [category-loop-input-schema.md](references/category-loop-input-schema.md) (always read — automation path)
- [category-automation-envelope.md](references/category-automation-envelope.md) (always read — automation path)
- [category-scope.md](references/category-scope.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)

## Workflow

Resolve **may_edit** before classifying findings or patching documentation:

| Source                                                             | `may_edit`                                                                                                               |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| Interactive / hook — default                                       | `false` — survey only; do not edit documentation files                                                                   |
| Interactive / hook — fix language in the same request              | `true` — examples: fix, sync, update docs, 修正して                                                                      |
| Interactive / hook — follow-up after a prior survey in the session | `true` when the user asks to fix, apply, or patch documentation                                                          |
| Automation — `## Constraints`                                      | `may_edit: true` or `may_edit: false` from [category-automation-envelope.md](references/category-automation-envelope.md) |

When `may_edit` is `true`, resolve `write_target`: on the **interactive** path use `fix` (this skill); on the **automation** path read `write_target` from `## Constraints`. Do not branch on `level` or `delivery`.

### Automation path (`findings[]` in detect JSON)

Read `may_edit` from `## Constraints` per [category-automation-envelope.md](references/category-automation-envelope.md) (`false` — survey only; `true` — apply edits).

1. Parse [category-loop-input-schema.md](references/category-loop-input-schema.md). Read `## Constraints` when present.
2. On the automation path, read [category-automation-envelope.md](references/category-automation-envelope.md) for Constraints, PR templates, and Session Metrics.
3. If input `skip` is true or no actionable `findings[]` → emit survey no-op; on automation path append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop.
4. Classify per [common-checklist-loop.md](references/common-checklist-loop.md).
5. When `may_edit` is `false`, emit survey shape with `### Candidates`; load `assets/pr-body-template-survey.md` at synthesis; append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop — do not edit documentation files.
6. When `may_edit` is `true` and `write_target` is not `fix` → emit survey shape; note expected `write_target: fix` in Overview; stop — do not edit documentation files.
7. When `may_edit` is `true` and `write_target` is `fix`, fix High-Priority items within [category-scope.md](references/category-scope.md); emit apply shape with `### Changes` and `## Verification`; load `assets/pr-body-template.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md).

### Interactive / hook path

1. Run `bash scripts/detect_changes.sh --scope <scope>`. Parse JSON.
2. If `skip` is `true`, report skip and exit.
3. Triage `affected_docs` per [common-impact-map.md](references/common-impact-map.md); grep before full read.
4. When `may_edit` is `false`, emit survey shape with `### Candidates` per [common-output-format.md](references/common-output-format.md); stop — do not edit documentation files or run `git add`.
5. When `may_edit` is `true`, apply minimal patches per [common-checklist.md](references/common-checklist.md); regenerate `docs/index.md` when `docs/` files created/deleted/renamed; stage with `git add`; emit apply shape per [common-output-format.md](references/common-output-format.md).

### Error Handling

| Condition                                     | Severity    | Action                                                                           |
| --------------------------------------------- | ----------- | -------------------------------------------------------------------------------- |
| No git repository                             | Fatal       | Stop                                                                             |
| Empty diff / no findings                      | Info        | Report skip, exit                                                                |
| Affected doc file missing                     | Recoverable | Skip file; note in report                                                        |
| Exceeds scope (>3 H2, etc.)                   | Recoverable | Stop for file; recommend docs-creator                                            |
| mkdocs.yml missing                            | Recoverable | Skip nav update                                                                  |
| Fix requested but `may_edit` is `false`       | Info        | Survey only; note that edits require an explicit fix request or `may_edit: true` |
| `may_edit` true with `write_target` not `fix` | Recoverable | Survey only; note expected `write_target: fix`                                   |
