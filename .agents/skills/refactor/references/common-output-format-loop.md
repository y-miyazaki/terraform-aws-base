# Refactor Automation Report Format

Use when detect JSON (`hints[]`) is present on the automation path. Interactive runs use [common-output-format.md](common-output-format.md).

Branch on `may_edit` from `## Constraints` — see [category-automation-envelope.md](category-automation-envelope.md). Do not branch on `level`.

## Session report (verifier / logs)

Always emit for automation runs. Append `## Session Metrics` per [category-automation-envelope.md](category-automation-envelope.md):

| Field          | Value                      |
| -------------- | -------------------------- |
| may_edit       | <true\|false>              |
| Commit range   | <commit_range or "n/a">    |
| Hints assessed | <count>                    |
| Candidates     | <count>                    |
| Applied        | <count or "0">             |
| Outcome        | <one-line verifier result> |

## PR body templates

| `may_edit` | Template asset                      | Summary subsections                    |
| ---------- | ----------------------------------- | -------------------------------------- |
| `false`    | `assets/pr-body-template-survey.md` | `### Candidates`, optional `### Watch` |
| `true`     | `assets/pr-body-template.md`        | `### Changes`, optional `### Deferred` |

At synthesis time, load the template for resolved `may_edit` and emit **exactly**:

1. `## Overview`
2. `## Summary` (subsections per template — **do not mix survey and apply subsections**)
3. `## Verification` — **apply only** (`may_edit: true`); omit for survey-only

`loop-finalize` extracts Overview, Summary, and Verification (when present). It adds `## Run Metadata` and omits mechanical `## Changes` when Summary contains `### Changes`.

## Survey PR body (`may_edit: false`)

- Load `assets/pr-body-template-survey.md`
- **MUST NOT** include `### Changes`, `### Deferred`, or `## Verification`
- `### Candidates` required when candidates exist; `### Watch` optional

## Apply PR body (`may_edit: true`)

- Load `assets/pr-body-template.md`
- **MUST NOT** include `### Candidates` or `### Watch` in final output
- `### Changes` required when branch diff is non-empty
- `## Verification` required when Phase B ran

## Fixes / Deferred consistency (apply only)

**Deferred** means no fix remains in the working tree for that path.

| Rule               | Requirement                                                 |
| ------------------ | ----------------------------------------------------------- |
| Mutual exclusion   | A path MUST NOT appear in both **Changes** and **Deferred** |
| Git alignment      | Every path in `git diff` MUST have a **Changes** row        |
| Deferred = no edit | Revert edits to deferred paths before synthesis             |

Before PR synthesis, run `git diff --name-only` and reconcile **Changes** and **Deferred**.

## Rules

- Emit **Session Metrics** for verifier/logs; PR body uses the `may_edit`-specific template only.
- When `may_edit` is `false`, use survey template; do not edit files.
- When `may_edit` is `true`, survey all `hints[]` internally, apply all apply candidates, emit apply template once.
- Never claim verification passed when commands failed or were not run.
