# Automation Envelope

For automation-path runs. Load on the automation path — see SKILL.md Reference Files Guide.

## Constraints

The caller injects `## Constraints` after the detect JSON in the assembled prompt. Read:

| Field           | Type    | Description                                                                                    |
| --------------- | ------- | ---------------------------------------------------------------------------------------------- |
| `may_edit`      | boolean | `false` — survey shape only; do not write files. `true` — write tests and emit the apply shape |
| `write_target`  | string  | `fix` when `may_edit: true` for this skill (`report` is invalid here)                          |
| `Allowed paths` | string  | Allowlist globs from the caller                                                                |

The skill branches on `may_edit` and `write_target` only. Denylist is enforced by the automation checker — see [category-scope.md](category-scope.md).

Example (survey):

```text
## Constraints
may_edit: false
Allowed paths: test/**
```

Example (apply):

```text
## Constraints
may_edit: true
write_target: fix
Allowed paths: test/**
```

## PR body synthesis

Use [common-output-format.md](common-output-format.md). At synthesis, load:

| `may_edit` | Template                            |
| ---------- | ----------------------------------- |
| `false`    | `assets/pr-body-template-survey.md` |
| `true`     | `assets/pr-body-template.md`        |

When `may_edit: true` but the run emits the survey shape (`write_target` mismatch), use `assets/pr-body-template-survey.md`.

PR body rules:

- Top-level `## Overview`, `## Summary`, and `## Verification` (apply only).
- Under Summary use `### Candidates` (survey) or `### Changes` and `### Deferred` (apply). Use `### Deferred`, not `### Skipped`.
- **Overview contract:** trigger → substance → action. Name the target file and the behaviors covered. Write enough for a reviewer to understand without opening the diff.
- **Links:** At synthesis, read [category-pr-body-links.md](category-pr-body-links.md).
- Reconcile `### Changes` and `### Deferred` with `git diff --name-only` before synthesis. A path MUST NOT appear in both. Every path in the diff MUST appear in Changes.

## Session Metrics

Append `## Session Metrics` with the target, number of tests added, and files read.
