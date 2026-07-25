## Automation Envelope

For automation-path runs. Load on the automation path — see SKILL.md Reference Files Guide.

### Constraints

The caller injects `## Constraints` after detect JSON in the assembled prompt. The agent reads:

| Field           | Type    | Description                                                                                                    |
| --------------- | ------- | -------------------------------------------------------------------------------------------------------------- |
| `may_edit`      | boolean | `false` — survey shape only; do not edit `changelog_file`. `true` — edit `changelog_file` and emit apply shape |
| `write_target`  | string  | `fix` when `may_edit: true` for this skill (`report` is invalid here)                                          |
| `report_file`   | string  | Not used for this skill                                                                                        |
| `Allowed paths` | string  | Optional allowlist globs from the caller                                                                       |

Callers supply `may_edit`, `write_target` (`fix` | `report`), and optional `report_file` in `## Constraints`. The skill branches on `may_edit` and `write_target` only — do not branch on other caller metadata.

Denylist is enforced by the automation verifier — see [category-scope.md](category-scope.md).

Example (survey):

```text
## Constraints
may_edit: false
Allowed paths: CHANGELOG.md
```

Example (apply):

```text
## Constraints
may_edit: true
write_target: fix
Allowed paths: CHANGELOG.md
```

### PR body synthesis

Use [common-output-format.md](common-output-format.md) for report shape. At synthesis, load:

| `may_edit` | Template                            |
| ---------- | ----------------------------------- |
| `false`    | `assets/pr-body-template-survey.md` |
| `true`     | `assets/pr-body-template.md`        |

When `may_edit: true` but the run emits survey shape (`write_target` mismatch), use `assets/pr-body-template-survey.md` at synthesis.

PR body rules:

- Top-level `## Overview`, `## Summary`, and `## Verification` (apply only) — match the apply/survey templates in `assets/`
- Under Summary use `### Changes` or `### Candidates`; use `### Skipped` for this skill (not `### Deferred`)
- **Overview contract:** trigger → substance → action; write enough detail for a reviewer without opening the diff; name commit types and CHANGELOG sections; link commit ranges when `compare_url` is available; omit Target, run URLs, and boilerplate
- **List vs table:** one item → bullet list; two or more rows or multiple columns → markdown table; omit empty `###` headings
- **Summary content to omit:** `**Outcome:**` one-liners, `### Suggested next action`, top-level `## Changes`, `### Validation` inside Summary (use `## Verification`)
- Reconcile `### Changes` and `### Skipped` with `git diff --name-only` before synthesis

The caller extracts Overview and Summary from the agent report for PR body composition.

### Session metrics (verifier / logs)

After survey or apply work, append:

```markdown
## Session Metrics

| Field            | Value                      |
| ---------------- | -------------------------- |
| may_edit         | <true\|false>              |
| Commit range     | <commit_range>             |
| Commits assessed | <count>                    |
| File modified    | <changelog_file or "None"> |
| Outcome          | <one-line result>          |
```

Optional caller metadata may be appended when supplied — do not branch behavior on it.
