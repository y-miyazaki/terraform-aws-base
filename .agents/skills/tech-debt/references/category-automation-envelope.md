# Automation Envelope

For automation-path runs. Load on the automation path — see SKILL.md Reference Files Guide.

## Constraints

The caller injects `## Constraints` after detect JSON in the assembled prompt. The agent reads:

| Field           | Type    | Description                                                                                                                         |
| --------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `may_edit`      | boolean | `false` — survey shape only; do not write `report_file`. `true` — write `report_file`, apply closed-set fixes, and emit apply shape |
| `write_target`  | string  | `report` when `may_edit: true` for this skill (`fix` is invalid here)                                                               |
| `report_file`   | string  | Required when `write_target: report` — path within allowlist (caller- or detect-supplied; not a fixed skill path)                   |
| `Allowed paths` | string  | Optional allowlist globs from the caller                                                                                            |

Callers supply `may_edit`, `write_target` (`fix` | `report`), and optional `report_file` in `## Constraints`. The skill branches on `may_edit` and `write_target` only — do not branch on other caller metadata.

Denylist is enforced by the automation verifier — see [category-scope.md](category-scope.md).

Example (survey):

```text
## Constraints
may_edit: false
Allowed paths: reports/tech-debt/**/*.md, docs/**/*.md
```

Example (apply):

```text
## Constraints
may_edit: true
write_target: report
report_file: reports/tech-debt/2026-07-23.md
Allowed paths: reports/tech-debt/**/*.md, docs/**/*.md
```

Use consumer-specific report directories in real callers. Resolve `report_file` via `TECH_DEBT_DIR` (detect) and/or `report_file` in `## Constraints`.

## PR body synthesis

Use [common-output-format.md](common-output-format.md) for report shape. At synthesis, load:

| `may_edit` | Template                            |
| ---------- | ----------------------------------- |
| `false`    | `assets/pr-body-template-survey.md` |
| `true`     | `assets/pr-body-template.md`        |

When `may_edit: true` but the run emits survey shape (`write_target` mismatch), use `assets/pr-body-template-survey.md` at synthesis.

PR body rules:

- Top-level `## Overview`, `## Summary`, and `## Verification` (apply only) — match the apply/survey templates in `assets/`
- Under Summary use `### Candidates` or `### Changes`; use `### Deferred` for this skill (not `### Skipped`)
- **Overview contract:** trigger → substance → action; write enough detail for a reviewer without opening the diff; name signal kinds and report sections; omit Target, and boilerplate
- **Links:** At synthesis, read [category-pr-body-links.md](category-pr-body-links.md).
- **List vs table:** one item → bullet list; two or more rows or multiple columns → markdown table; omit empty `###` headings
- **Summary content to omit:** `**Outcome:**` one-liners, `### Suggested next action`, top-level `## Changes`, `### Validation` inside Summary (use `## Verification`)
- Reconcile `### Changes` and `### Deferred` with `git diff --name-only` before synthesis — a path MUST NOT appear in both; every path in `git diff` MUST appear in **Changes**; revert edits to deferred paths before synthesis

The caller extracts Overview and Summary from the agent report for PR body composition.

## Session metrics (verifier / logs)

After survey or apply work, append:

```markdown
## Session Metrics

| Field             | Value                   |
| ----------------- | ----------------------- |
| may_edit          | <true\|false>           |
| Commit range      | <commit_range>          |
| Signals assessed  | <count>                 |
| Hotspots assessed | <count>                 |
| Report file       | <report_file or "None"> |
| Outcome           | <one-line result>       |
```

Optional caller metadata may be appended when supplied — do not branch behavior on it.
