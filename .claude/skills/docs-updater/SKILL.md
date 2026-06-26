---
name: docs-updater
description: >-
  Detect code changes via git diff and patch affected documentation to keep references,
  links, tables, and nav entries accurate. Use when code changes may have made documentation
  stale — after commits, before PRs, when files are renamed/deleted/added, or whenever the
  user mentions syncing docs with code. Also triggers from stop hooks and commit-preparation hooks.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "2.0.0"
---

**UTILITY SKILL** — automated diff-sync, not content authoring.

## Input

- Trigger source: stop hook, commit-preparation hook, or explicit user instruction (required)
- `scope`: `staged` (default), `all`, or `range` (with `--since <ref>`)

## Output Specification

Return structured report per [references/common-output-format.md](references/common-output-format.md).

## Execution Scope

Target: root `*.md`, `docs/**/*.md`, nested `**/README.md` (excluding generated directories), and `mkdocs.yml` (nav section).

### USE FOR:

- Update cross-references, tables, lists, and nav entries that reference changed paths
- Remove dead links to deleted files
- Update paths for renamed files

### DO NOT USE FOR:

- New document creation or content improvement (use docs-creator skill)
- Source code comments, non-markdown assets, auto-generated files
- Markdown linting (use markdown-validation skill)
- Changes limited to tests or internal refactoring with no doc-facing impact

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) — Always read. Update validation criteria.
- [common-output-format.md](references/common-output-format.md) — Always read. Report structure.
- [common-impact-map.md](references/common-impact-map.md) — Always read. How to identify affected docs.

## Workflow

1. Run `bash scripts/detect_changes.sh --scope <scope>`. Parse JSON output.

2. If `skip` is `true`, report "No documentation update required." and exit.

3. **Triage affected_docs**: Do not read all candidates. First, grep each candidate for references to changed/deleted/renamed paths. Only read files that actually contain a match. Skip files with zero matches.

4. For matched files, identify: dead references (deleted paths), stale paths (renames), missing entries (additions belonging in existing lists/tables).

5. Apply minimal, structure-preserving updates:
   - Do not reorder, rewrite, or add sections.
   - Respect Diataxis placement for mkdocs.yml nav entries.
   - Table/list entries: maintain existing format and sort order.
   - Cross-references: relative paths with `.md` extension.

6. If any `docs/` file is created, deleted, or renamed, regenerate `docs/index.md` per [common-checklist.md](references/common-checklist.md).

7. **Scope guards** — report "exceeded-scope" and recommend docs-creator if:
   - A single file's diff exceeds 500 changed lines
   - Changes would affect >3 H2 sections of one document
   - The required update is a rewrite rather than a patch

8. Stage updated files with `git add`. Return report.

### Error Handling

| Condition | Severity | Action |
|---|---|---|
| No git repository | Fatal | Stop |
| Empty diff | Info | Report skip, exit |
| Affected doc file missing | Recoverable | Skip, note in report |
| Exceeds scope | Recoverable | Stop for that file, recommend docs-creator |
| mkdocs.yml missing | Recoverable | Skip nav update |

### Examples

- **Rename**: `git mv ci-build.yaml ci-build-deploy.yaml` → replace old path in docs referencing it.
- **Addition**: new workflow added → add entry to relevant table, nav entry in mkdocs.yml.
- **Deletion**: workflow removed → remove references and nav entry.
- **docs/ file added**: → add nav entry, regenerate `docs/index.md`.
- **No impact**: test file modified → report skip.
