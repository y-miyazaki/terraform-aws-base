## Automation Envelope

For LE workflow-driven runs. Load on the automation path — see SKILL.md Reference Files Guide.

### Constraints

The caller injects `## Constraints` after detect JSON via `loop-prompt-generate`. The agent reads:

| Field           | Type    | Description                                                                               |
| --------------- | ------- | ----------------------------------------------------------------------------------------- |
| `may_edit`      | boolean | `false` — survey shape only; do not edit files. `true` — apply edits and emit apply shape |
| `write_target`  | string  | `fix` when `may_edit: true` for this skill (`report` is invalid here)                     |
| `report_file`   | string  | Not used for this skill                                                                   |
| `Allowed paths` | string  | Optional allowlist globs (`LOOP_ALLOWLIST`)                                               |

Callers supply `may_edit`, `write_target` (`fix` | `report`), and optional `report_file` in `## Constraints`. The skill branches on `may_edit` and `write_target` only — do not interpret `level` or `delivery`.

Denylist is enforced by the loop verifier — see [category-scope.md](category-scope.md).

Example (survey):

```text
## Constraints
may_edit: false
Allowed paths: scripts/**
```

Example (apply):

```text
## Constraints
may_edit: true
write_target: fix
Allowed paths: scripts/**
```

### PR body synthesis

Use [common-output-format-loop.md](common-output-format-loop.md) for report shape. At synthesis, load:

| `may_edit` | Template                            |
| ---------- | ----------------------------------- |
| `false`    | `assets/pr-body-template-survey.md` |
| `true`     | `assets/pr-body-template.md`        |

When `may_edit: true` but the run emits survey shape (`write_target` mismatch), use `assets/pr-body-template-survey.md` at synthesis.

PR body rules:

- Top-level `## Overview`, `## Summary`, and `## Verification` (apply only) — match the apply/survey templates in `assets/`
- Under Summary use `### Changes` or `### Candidates`; use `### Deferred` for apply-phase skips (not `### Skipped`)
- **Overview contract:** 1–2 sentences (max ~280 characters) — trigger → substance → action; name hint kinds and touched paths; omit level, SHAs, run URLs, and boilerplate
- **List vs table:** one item → bullet list; two or more rows or multiple columns → markdown table; omit empty `###` headings
- **Summary content to omit:** `**Outcome:**` one-liners, `### Suggested next action`, top-level `## Changes`, `### Validation` inside Summary (use `## Verification`)
- Reconcile `### Changes` and `### Deferred` with `git diff --name-only` before synthesis — a path MUST NOT appear in both; every path in `git diff` MUST appear in **Changes**; revert edits to deferred paths before synthesis

`loop-finalize` extracts Overview and Summary from the agent report.

### Session metrics (verifier / logs)

After survey or apply work, append:

```markdown
## Session Metrics

| Field          | Value             |
| -------------- | ----------------- |
| may_edit       | <true\|false>     |
| Commit range   | <commit_range>    |
| Hints assessed | <count>           |
| Candidates     | <count>           |
| Applied        | <count or "0">    |
| Outcome        | <one-line result> |
```

Optional caller metadata (`level`, run id) may be appended when supplied — do not branch behavior on it.
