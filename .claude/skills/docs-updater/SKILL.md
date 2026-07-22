---
name: docs-updater
description: >-
  Detect documentation drift and patch affected docs — via git diff (hooks, manual)
  or loop-injected findings (integration branch scan). Keeps references, links, tables,
  and nav entries accurate. Use when syncing docs after code changes, before PRs, on doc
  sync requests, or when loop automation reports documentation drift. Not for new
  document creation (use docs-creator) or markdown linting (use markdown-validation).
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "3.1.0"
---

**UTILITY SKILL** — automated diff-sync and drift repair, not content authoring.

## Input

- **Interactive / hook:** trigger source + `scope` (`staged`, `all`, `range` with `--since`) — run `scripts/detect_changes.sh`
- **Loop:** injected JSON from loop-prompt-generate with `findings[]` — see [category-loop-input-schema.md](references/category-loop-input-schema.md). Caller `allowlist` / `denylist` (`LOOP_ALLOWLIST` / `LOOP_DENYLIST`); see [category-scope.md](references/category-scope.md).

## Operating levels

`level` arrives in loop JSON — see [category-loop-input-schema.md#operating-levels](references/category-loop-input-schema.md#operating-levels).

## Output Specification

Interactive / hook: report per [common-output-format.md](references/common-output-format.md).
Loop (`findings[]` present): [common-output-format-loop.md](references/common-output-format-loop.md). At `L2`/`L3`, edit High-Priority items within [category-scope.md](references/category-scope.md).

## Execution Scope

Target: root `*.md`, `docs/**/*.md`, nested `**/README.md` (excluding generated directories), and `mkdocs.yml` (nav section).

### USE FOR:

- Update cross-references, tables, lists, and nav entries for changed paths
- Remove dead links; update paths for renames
- Loop: classify `findings[]`, fix High-Priority items at L2/L3 within allowlist

### DO NOT USE FOR:

- New document creation or content improvement (use docs-creator)
- Non-documentation file edits
- Markdown linting (use markdown-validation)
- Run detection or manage loop state

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read — interactive / hook path)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-impact-map.md](references/common-impact-map.md) (always read — interactive path)
- [common-checklist-loop.md](references/common-checklist-loop.md) (always read — loop path)
- [common-output-format-loop.md](references/common-output-format-loop.md) (always read — loop path)
- [category-loop-input-schema.md](references/category-loop-input-schema.md) (always read — loop path)
- [category-scope.md](references/category-scope.md) (always read — loop path)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)

## Workflow

### Loop path (`findings[]` in loop-prompt-generate JSON)

1. Parse [category-loop-input-schema.md](references/category-loop-input-schema.md). Read `## Constraints` when present.
2. If input `skip` is true or no actionable `findings[]` → emit loop report with Outcome `No documentation impact detected`; stop.
3. Classify per [common-checklist-loop.md](references/common-checklist-loop.md); fix High-Priority at L2/L3 within [category-scope.md](references/category-scope.md).
4. Emit report per [common-output-format-loop.md](references/common-output-format-loop.md); reconcile Fixes Applied / Deferred with `git diff --name-only`; at synthesis load `assets/pr-body-template.md` for `## Overview` + `## Summary`.

### Interactive / hook path

1. Run `bash scripts/detect_changes.sh --scope <scope>`. Parse JSON.
2. If `skip` is `true`, report skip and exit.
3. Triage `affected_docs` per [common-impact-map.md](references/common-impact-map.md); grep before full read.
4. Apply minimal patches per [common-checklist.md](references/common-checklist.md).
5. Regenerate `docs/index.md` when `docs/` files created/deleted/renamed.
6. Stage with `git add`; return [common-output-format.md](references/common-output-format.md) report.

### Error Handling

| Condition                   | Severity    | Action                                  |
| --------------------------- | ----------- | --------------------------------------- |
| No git repository           | Fatal       | Stop                                    |
| Empty diff / no findings    | Info        | Report skip, exit                       |
| Affected doc file missing   | Recoverable | Skip file; note in report               |
| Exceeds scope (>3 H2, etc.) | Recoverable | Stop for file; recommend docs-creator   |
| mkdocs.yml missing          | Recoverable | Skip nav update                         |
