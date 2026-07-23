# Technical Debt Result Format

Deferred subsection name for this skill: `### Deferred` (not `### Skipped`).

Category and severity rules: [category-debt-taxonomy.md](category-debt-taxonomy.md).

## Survey result (`may_edit: false`)

No file edits. **Do not write `report_file`.** **Do not emit `### Changes`, `### Deferred`, or `## Verification`.**

```markdown
# Technical Debt Result

## Overview

<scan scope → dominant categories/files found → no edits applied; name substance, not counts only>

## Summary

### Candidates

| Target      | Category   | Evidence            | Suggested approach         | Delegate                                       | Priority              |
| ----------- | ---------- | ------------------- | -------------------------- | ---------------------------------------------- | --------------------- |
| `path:line` | <category> | <snippet or metric> | <plain-language direction> | self \| refactor \| docs-updater \| human \| — | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
```

### Survey rules

- **MUST NOT** include `### Changes`, `### Deferred`, or `## Verification`
- Zero candidates — Overview explains no-op; omit empty `### Candidates`
- **Delegate:** `self` = closed-set apply candidate; `refactor` = structural; `docs-updater` = doc drift; `human` = security or judgment; `—` = report-only

## Apply result (`may_edit: true`)

Survey runs internally first; final output uses apply shape. Write `report_file` within allowlist.

```markdown
# Technical Debt Result

## Overview

<scope → what was recorded/fixed by category or file → deferrals; name substance>

## Summary

### Changes

| Target                                | What was wrong | What changed                    |
| ------------------------------------- | -------------- | ------------------------------- |
| `docs/report/tech-debt/YYYY-MM-DD.md` | <finding gap>  | <report recorded>               |
| `path/to/file`                        | <debt fact>    | <minimal closed-set fix if any> |

### Deferred

| Target | Why deferred |
| ------ | ------------ |

## Verification

| Check          | Result                 |
| -------------- | ---------------------- |
| Detect sensors | <pass \| fail \| skip> |
```

### Apply rules

- **MUST NOT** include `### Candidates` in final output
- Fold Watch + non-applied candidates into `### Deferred`; omit when empty
- Reconcile `### Changes` with `git diff --name-only` before synthesis

## Session metrics (automation)

On the automation path, append `## Session Metrics` per [category-automation-envelope.md](category-automation-envelope.md).

## Persisted report file (`may_edit: true` only)

Write `report_file` (`docs/report/tech-debt/YYYY-MM-DD.md`) with extended tables (Resolved Since Previous, Report Outcome). PR Summary uses apply/survey shape only — not a copy of the full persisted file.

```markdown
# Technical Debt Report — YYYY-MM-DD

## Scope

- **Commit range:** <commit_range>
- **Previous report:** <previous_report or "None">
- **Signals:** <count>
- **Hotspots:** <count>

## Critical

| Path | Category | Nature | Kind | Evidence | Recommendation |
| ---- | -------- | ------ | ---- | -------- | -------------- |

## High-Priority

| Path | Category | Nature | Kind | Evidence | Recommendation |

## Watch

| Path | Category | Reason |

## Resolved Since Previous

- <item or "None">

## Report Outcome

- **Findings (Critical + High):** <count>
- **Watch:** <count>
- **Truncated:** <yes/no>
- **Outcome:** <one-line>
```

## Rules

- Pick **one** result shape per run — survey-only **or** apply.
- Cap Critical + High-Priority at 25 combined; defer overflow to Watch with truncation note.
- Every finding row must include `Category` from the taxonomy.

## Overview (skill-specific)

**Good (survey):** `Debt scan over abc..def found broken links in docs/guide and pin drift in package.json; 12 TODO markers logged as Watch; no edits applied.`

**Good (apply):** `Recorded 2 High documentation findings in docs/report/tech-debt/2026-07-23.md and fixed a broken link in docs/guide/overview.md; deferred one architecture hotspot to refactor.`

**Bad:** `Technical debt run finished.`
