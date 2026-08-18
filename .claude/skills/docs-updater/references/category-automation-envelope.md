# Automation Envelope

For automation-path runs. Load on the automation path — see SKILL.md Reference Files Guide.

## Constraints

The caller injects `## Constraints` after detect JSON in the assembled prompt. The agent reads:

| Field           | Type    | Description                                                                                                          |
| --------------- | ------- | -------------------------------------------------------------------------------------------------------------------- |
| `may_edit`      | boolean | `false` — survey shape only; do not edit documentation files. `true` — edit documentation files and emit apply shape |
| `write_target`  | string  | `fix` when `may_edit: true` for this skill (`report` is invalid here)                                                |
| `report_file`   | string  | Not used for this skill                                                                                              |
| `Allowed paths` | string  | Optional allowlist globs from the caller                                                                             |

Callers supply `may_edit`, `write_target` (`fix` | `report`), and optional `report_file` in `## Constraints`. The skill branches on `may_edit` and `write_target` only — do not branch on other caller metadata.

Denylist is enforced by the automation checker — see [category-scope.md](category-scope.md).

Example (survey):

```text
## Constraints
may_edit: false
Allowed paths: docs/**/*.md, README.md, mkdocs.yml
```

Example (apply):

```text
## Constraints
may_edit: true
write_target: fix
Allowed paths: docs/**/*.md, README.md, mkdocs.yml
```

## PR body synthesis

Use [common-output-format-automation.md](common-output-format-automation.md) for report shape. At synthesis, load:

| `may_edit` | Template                            |
| ---------- | ----------------------------------- |
| `false`    | `assets/pr-body-template-survey.md` |
| `true`     | `assets/pr-body-template.md`        |

When `may_edit: true` but the run emits survey shape (`write_target` mismatch), use `assets/pr-body-template-survey.md` at synthesis.

PR body rules:

- Top-level `## Overview`, `## Summary`, and `## Verification` (apply only) — match the apply/survey templates in `assets/`
- Under Summary use `### Changes` or `### Candidates`; use `### Deferred` for apply deferrals; use `### Watch` for survey-only rows
- **Overview contract:** trigger → substance → action; write enough detail for a reviewer without opening the diff; name finding types and affected doc paths; omit Target, and boilerplate
- **Links:** At synthesis, read [category-pr-body-links.md](category-pr-body-links.md).
- **List vs table:** one item → bullet list; two or more rows or multiple columns → markdown table; omit empty `###` headings
- **Summary content to omit:** `**Outcome:**` one-liners, `### Suggested next action`, top-level `## Changes`, `### Validation` inside Summary (use `## Verification`)
- Reconcile `### Changes` and `### Deferred` with `git diff --name-only` before synthesis — a path MUST NOT appear in both; every path in `git diff` MUST appear in **Changes**; revert edits to deferred paths before synthesis

The caller extracts Overview and Summary from the agent report for PR body composition.

## Session metrics (checker / logs)

After survey or apply work, append:

```markdown
## Session Metrics

| Field             | Value             |
| ----------------- | ----------------- |
| may_edit          | <true\|false>     |
| Commit range      | <commit_range>    |
| Findings assessed | <count>           |
| Files modified    | <count>           |
| Outcome           | <one-line result> |
```

Optional caller metadata may be appended when supplied — do not branch behavior on it.
