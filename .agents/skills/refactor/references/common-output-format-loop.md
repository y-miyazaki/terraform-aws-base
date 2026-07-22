# Refactor Loop Session Report Format

Use when loop JSON (`hints[]`, `level`) is present. Interactive runs use [common-output-format.md](common-output-format.md).

Survey-only (`L1`) and apply (`L2`/`L3`) use **different** PR body templates — see [PR body templates](#pr-body-templates).

## Session report (verifier / logs)

Always emit for loop runs:

```markdown
# Refactor Session Report

## Session Metrics

| Field          | Value |
| -------------- | ----- |
| Level          | <L1\|L2\|L3> |
| Mode           | <survey\|apply> |
| Commit range   | <commit_range or "n/a"> |
| Hints assessed | <count> |
| Candidates     | <count> |
| Applied        | <count or "0"> |
| Outcome        | <one-line verifier result> |
```

## PR body templates

| Mode | Level | Template asset | Summary subsections |
| ---- | ----- | -------------- | ------------------- |
| Survey | `L1` | `assets/pr-body-template-survey.md` | `### Candidates`, optional `### Watch` |
| Apply | `L2`/`L3` | `assets/pr-body-template.md` | `### Changes`, optional `### Deferred` |

At synthesis time, load the template for the resolved mode and emit **exactly**:

1. `## Overview`
2. `## Summary` (subsections per template — **do not mix survey and apply subsections**)
3. `## Verification` — **apply mode only**; omit for survey-only (`L1`)

`loop-finalize` extracts Overview, Summary, and Verification (when present). It adds `## Run Metadata` and omits mechanical `## Changes` when Summary contains `### Changes`.

See repository `docs/explanation/loop-engineering/loop-pr-body-skill-contract.md`.

## Survey PR body (`L1` / `mode: survey`)

- Load `assets/pr-body-template-survey.md`
- **MUST NOT** include `### Changes`, `### Deferred`, or `## Verification`
- `### Candidates` required when candidates exist; `### Watch` optional

## Apply PR body (`L2`/`L3` / `mode: apply`)

- Load `assets/pr-body-template.md`
- **MUST NOT** include `### Candidates` or `### Watch` in final output
- `### Changes` required when branch diff is non-empty
- `## Verification` required when Phase B ran

## Fixes / Deferred consistency (apply mode only)

**Deferred** means no fix remains in the working tree for that path.

| Rule | Requirement |
| ---- | ----------- |
| Mutual exclusion | A path MUST NOT appear in both **Changes** and **Deferred** |
| Git alignment | Every path in `git diff` MUST have a **Changes** row |
| Deferred = no edit | Revert edits to deferred paths before synthesis |

Before PR synthesis, run `git diff --name-only` and reconcile **Changes** and **Deferred**.

## Rules

- Emit session **Session Metrics** for verifier/logs; PR body uses the mode-specific template only.
- At `L1`, use survey template; do not edit files.
- At `L2`/`L3`, survey all `hints[]` internally, apply all apply candidates, emit apply template once.
- Never claim verification passed when commands failed or were not run.
