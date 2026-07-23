# Documentation Triage Report Format

Automation-path report shapes. Interactive/hook runs use [common-output-format.md](common-output-format.md).

## Overview contract

Every run emits `## Overview` first. Write 1–2 plain-language sentences (~280 characters max).

| Element   | Include                                                                   |
| --------- | ------------------------------------------------------------------------- |
| Trigger   | Scan scope, workflow/job, or commit range                                 |
| Substance | Dominant categories, named files, or failure types — **not counts alone** |
| Action    | Recorded, fixed, deferred, or no edits                                    |

Omit level, commit SHAs, run URLs, and boilerplate.

## Survey-only result (`may_edit: false`)

No file edits.

```markdown
# docs-updater Result

## Overview

<commit range → dominant doc drift by file/category → no edits applied>

## Summary

### Candidates

| Target           | Evidence                  | Suggested approach       | Priority              |
| ---------------- | ------------------------- | ------------------------ | --------------------- |
| `path/to/doc.md` | <stale/missing reference> | <plain-language fix dir> | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
```

### Survey rules

| Rule              | Requirement                                          |
| ----------------- | ---------------------------------------------------- |
| `### Candidates`  | Required when any apply-worthy row exists            |
| `### Watch`       | Optional                                             |
| `### Changes`     | **MUST NOT** appear                                  |
| `### Deferred`    | **MUST NOT** appear                                  |
| `## Verification` | **MUST NOT** appear                                  |
| Zero candidates   | Overview explains no-op; omit empty `### Candidates` |

## Apply result (`may_edit: true`)

```markdown
# docs-updater Result

## Overview

<what doc files were fixed vs deferred — name paths or drift types>

## Summary

### Changes

| Target           | What was wrong            | What changed            |
| ---------------- | ------------------------- | ----------------------- |
| `path/to/doc.md` | <stale/missing reference> | <minimal patch summary> |

### Deferred

| Target | Why deferred |
| ------ | ------------ |

## Verification

| Check                               | Result                 |
| ----------------------------------- | ---------------------- |
| <markdown-validation or link check> | <pass \| fail \| skip> |
```

### Apply rules

| Rule              | Requirement                                            |
| ----------------- | ------------------------------------------------------ |
| `### Changes`     | Required when `git diff` is non-empty                  |
| `### Deferred`    | Watch/skip rows plus apply failures; omit when empty   |
| `### Candidates`  | **MUST NOT** appear in final output                    |
| `### Watch`       | **MUST NOT** appear — fold into **Deferred**           |
| `## Verification` | Required when apply phase ran                          |
| Git alignment     | Reconcile with `git diff --name-only` before synthesis |

## Session metrics (verifier / logs)

Separate from PR body. Emit after survey or apply work per [category-automation-envelope.md](category-automation-envelope.md):

```markdown
## Session Metrics

| Field             | Value                      |
| ----------------- | -------------------------- |
| may_edit          | <true\|false>              |
| Commit range      | <commit_range>             |
| Findings assessed | <count>                    |
| Files modified    | <count>                    |
| Outcome           | <one-line verifier result> |
```

## PR body templates

| `may_edit` | Template                            |
| ---------- | ----------------------------------- |
| `false`    | `assets/pr-body-template-survey.md` |
| `true`     | `assets/pr-body-template.md`        |

At synthesis, load the template for the resolved `may_edit`. Emit **exactly** `## Overview`, `## Summary`, and `## Verification` (apply only).

## Fixes / Deferred consistency

**Deferred** means no fix remains in the working tree for that path. Reconcile with `git diff --name-only` before synthesis.
