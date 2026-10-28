# Automation Envelope

For automation-path runs. Load on the automation path — see SKILL.md Reference Files Guide.

## Constraints

The caller injects `## Constraints` after detect JSON in the assembled prompt. The agent reads:

| Field                | Type    | Description                                                                                  |
| -------------------- | ------- | -------------------------------------------------------------------------------------------- |
| `agent_edit_allowed` | boolean | `false` — survey shape only; write no file. `true` — write the report file                   |
| `agent_edit_target`  | string  | `report` when `agent_edit_allowed: true` for this skill                                      |
| `agent_report_file`  | string  | Report path; prefer detect `result.report_path` when both are present                        |
| `response_language`  | string  | Language for agent-written prose; overrides the PR language (see category-review-rules.md)   |
| `Allowed paths`      | string  | Optional allowlist globs from the caller; the report file is the only path this skill writes |

Callers supply `agent_edit_allowed`, `agent_edit_target` (`fix` | `report`), and optional `agent_report_file` in `## Constraints`. The skill branches on `agent_edit_allowed` and `agent_edit_target` only.

## Report and session output

Write the report file per [common-output-format.md](common-output-format.md). The session report to the caller uses `## Overview`, `## Summary`, and `### Deferred`:

- **Links:** At synthesis, read [category-pr-body-links.md](category-pr-body-links.md).
- **Overview contract:** trigger → substance → action; name the PR number, the intent sources read, and the number of findings written; omit run URLs and boilerplate
- **List vs table:** one item → bullet list; two or more rows or multiple columns → markdown table; omit empty `###` headings
- Do not post from the agent: after the checker verdict, the platform renders the report and posts one COMMENT review

### Deferred

List findings dropped for missing evidence and areas not reviewed (for example, binary files), with a plain-language reason. Omit the heading when empty.

The checker verifies that the report file is the only changed file, that every finding has evidence, and that `premises` records the PR intent.
