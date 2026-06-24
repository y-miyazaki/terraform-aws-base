---
name: docs-updater
description: >-
  Sync documentation with code changes by detecting git diff impact on markdown files.
  Use when a stop hook or user explicitly requests documentation sync after code changes.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Trigger source: stop hook, commit-preparation hook, or explicit user instruction (required)
- `scope`: `staged` (default) or `all`

## Output Specification

Return structured report per [references/common-output-format.md](references/common-output-format.md).

## Execution Scope

Target: root `*.md`, `README.md`, `docs/**/*.md`, and `mkdocs.yml` (nav section).

### USE FOR:

- sync docs after code changes (package/workflow/skill/config additions, renames, deletions)

### DO NOT USE FOR:

- new document creation or full rewrites
- source code comments, non-markdown assets, auto-generated files
- markdown linting
- changes limited to tests or internal refactoring

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-impact-map.md](references/common-impact-map.md) (always read)

## Workflow

1. Run `bash scripts/detect_changes.sh --scope <scope>`. Parse JSON output to get `changed_files`, `deleted_files`, `renamed_files`, `affected_docs`, and `skip` flag.

2. If `skip` is `true` AND all changed markdown files are already staged, report "No documentation update required." and exit.

3. Read each `affected_docs` file and the relevant diffs. Identify stale references, missing entries, and dead references. If diff exceeds 500 changed lines, report exceeded-scope and stop.

4. Apply minimal updates: add/update/remove entries in existing structure. Do not reorder, rewrite, or add sections. When `docs/` files are added, deleted, or renamed, update the `nav` section in `mkdocs.yml` to match.

5. Scope guard: if changes affect >3 sections of one document, stop and report "Changes exceed diff-sync scope. Manual review of `<file>` recommended."

6. Stage updated files with `git add`. Return report.

### Error Handling

| Condition | Action |
|---|---|
| No git repository | Fatal: stop |
| Empty diff | Report, exit |
| Document missing | Skip, note in report |
| Exceeds scope | Stop for that file, recommend manual review |

## Best Practices

- Prefer updating existing entries over adding duplicates.
- Keep diffs minimal — change only what the code change necessitates.
- When in doubt about scope, stop and report rather than making incorrect updates.
