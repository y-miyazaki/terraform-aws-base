# Technical Debt Loop Report Format

Emit a session summary on every run, including no-action exits.
At `L2`/`L3`, also write the persisted report file described below.
Category and severity rules: [category-debt-taxonomy.md](category-debt-taxonomy.md).

## Session report (verifier / logs)

```markdown
# Technical Debt Loop Report

## Critical

- **Path:** <path>:<line or "n/a">
- **Category:** <code_quality|test_gap|architecture|dependency_version|documentation|security|operational>
- **Nature:** <prudent-deliberate|reckless-deliberate|reckless-inadvertent|prudent-inadvertent|omitted>
- **Kind:** <signal kind or hotspot metric>
- **Reason:** <severity severity rationale; cite taxonomy axis>
- **Recommendation:** <actionable next step, or "None">

## High-Priority

- **Path:** <path>:<line or "n/a">
- **Category:** <...>
- **Nature:** <... or omitted>
- **Kind:** <signal kind or hotspot metric>
- **Reason:** <why this is debt>
- **Recommendation:** <actionable next step, or "None">

## Watch

- **Path:** <path>
- **Category:** <...>
- **Reason:** <why deferred>

## Noise / Ignore

- <duplicate, out-of-scope, or empty evidence items, or "None">

## Session Metrics

| Field             | Value                                                        |
| ----------------- | ------------------------------------------------------------ |
| Level             | <L1\|L2\|L3>                                                 |
| Commit range      | <commit_range>                                               |
| Signals assessed  | <count>                                                      |
| Hotspots assessed | <count>                                                      |
| Report file       | <report_file or "None">                                      |
| Outcome           | <one-line result, e.g. "No technical debt signals detected"> |
```

## PR body contract (human-facing)

At synthesis time, load `assets/pr-body-template.md` and emit `## Overview`, `## Summary`, and `## Verification`.

The persisted report file (`docs/report/report-tech-debt/YYYY-MM-DD.md`) may contain fuller tables; the PR body template is the concise human-facing summary.

See repository `docs/explanation/loop-engineering/loop-pr-body-skill-contract.md`.

### Overview (skill-specific)

Emit one paragraph under `## Overview` that answers:

| Element | report-tech-debt content                                                         |
| ------- | -------------------------------------------------------------------------------- |
| Trigger | Debt scan scope (`<commit_range>` or hotspot/signal scan)                        |
| Problem | Whether Critical/High debt exists; dominant categories if any                    |
| Action  | Report file path; this skill reports, does not edit application code             |

**Good:** `Debt scan over abc..def found no Critical/High items; 21 Watch signals recorded in docs/report/report-tech-debt/2026-07-21.md.`

**Bad:** `Technical debt loop completed.` / listing every signal in Overview

## Persisted Report File

At `L2`/`L3`, write `report_file` (`docs/report/report-tech-debt/YYYY-MM-DD.md`) with this structure:

```markdown
# Technical Debt Report — YYYY-MM-DD

## Scope

- **Commit range:** <commit_range>
- **Previous report:** <previous_report or "None">
- **Signals:** <count>
- **Hotspots:** <count>
- **Taxonomy:** Fowler quadrant · Google eng-practices · Sonar software qualities · SemVer · Diátaxis

## Critical

| Path        | Category   | Nature        | Kind   | Evidence            | Recommendation |
| ----------- | ---------- | ------------- | ------ | ------------------- | -------------- |
| <path:line> | <category> | <nature or —> | <kind> | <snippet or metric> | <next step>    |

## High-Priority

| Path        | Category   | Nature        | Kind   | Evidence            | Recommendation |
| ----------- | ---------- | ------------- | ------ | ------------------- | -------------- |
| <path:line> | <category> | <nature or —> | <kind> | <snippet or metric> | <next step>    |

## Watch

| Path   | Category   | Reason         |
| ------ | ---------- | -------------- |
| <path> | <category> | <why deferred> |

## Resolved Since Previous

- <item from previous_report no longer present, or "None">

## Report Outcome

- **Findings (Critical + High):** <count>
- **Watch:** <count>
- **Truncated:** <yes/no>
- **Outcome:** <one-line result>
```

## Rules

- Always emit all five session `##` sections plus PR `## Overview`, `## Summary`, and `## Verification`.
- `## Session Metrics` MUST use a Field \| Value table (not bullet list).
- At `L1`, emit the session summary only — do not write `report_file`.
- At `L2`/`L3`, write only `report_file` within the prompt `## Constraints` allowlist (see `category-scope.md`).
- Cap Critical + High-Priority rows at 25 combined: retain **all Critical** first, then **High-Priority** until the cap; move remaining High-Priority rows to Watch and set Truncated to `yes`.
- Every Critical / High-Priority / Watch row must include `Category` from the taxonomy.
- Verifier expects the persisted report to cite detect facts without invented paths or metrics.

