# Automation Envelope

For automation-path runs. Load on the automation path — see SKILL.md Reference Files Guide.

## Constraints

The caller injects `## Constraints` after detect JSON in the assembled prompt. The agent reads:

| Field                | Type    | Description                                                                             |
| -------------------- | ------- | --------------------------------------------------------------------------------------- |
| `agent_edit_allowed` | boolean | `false` — survey shape only; do not edit files. `true` — apply fix and emit apply shape |
| `agent_edit_target`  | string  | `fix` when `agent_edit_allowed: true` for this skill                                    |
| `agent_report_file`  | string  | Not used for this skill                                                                 |
| `Allowed paths`      | string  | Optional allowlist globs from the caller                                                |

Callers supply `agent_edit_allowed`, `agent_edit_target` (`fix` | `report`), and optional `agent_report_file` in `## Constraints`. The skill branches on `agent_edit_allowed` and `agent_edit_target` only — do not branch on `delivery` or invent mention triggers.

## PR body synthesis

Use [common-output-format.md](common-output-format.md) for report shape. At synthesis, load:

| `agent_edit_allowed` | Template                            |
| -------------------- | ----------------------------------- |
| `false`              | `assets/pr-body-template-survey.md` |
| `true`               | `assets/pr-body-template.md`        |

When `agent_edit_allowed: true` but the run emits survey shape (`agent_edit_target` mismatch), use `assets/pr-body-template-survey.md` at synthesis.

PR body rules:

- Top-level `## Overview`, `## Summary`, and `## Verification` (apply only) — match the apply/survey templates in `assets/`
- Under Summary use `### Changes` or `### Candidates`; use `### Deferred` for apply deferrals; use `### Watch` for survey-only non-actionable rows
- **Links:** At synthesis, read [category-pr-body-links.md](category-pr-body-links.md).
- **Overview contract:** trigger → substance → action; write enough detail for a reviewer without opening the diff; name PR number and the review feedback addressed; omit Target, boilerplate, and Failure context run URLs (platform adds `## Failure context`)
- **List vs table:** one item → bullet list; two or more rows or multiple columns → markdown table; omit empty `###` headings
- **Summary content to omit:** `**Outcome:**` one-liners, `### Suggested next action`, top-level `## Changes`, `### Validation` inside Summary (use `## Verification`)
- Reconcile `### Changes` and `### Deferred` with `git diff --name-only` before synthesis — a path MUST NOT appear in both; every path in `git diff` MUST appear in **Changes**; revert edits to deferred paths before synthesis

The caller extracts Overview and Summary from the agent report for PR body composition.
