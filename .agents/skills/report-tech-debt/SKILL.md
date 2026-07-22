---
name: report-tech-debt
description: >-
  Discover and classify technical debt from mechanical signals, then publish a
  structured report under docs/report/report-tech-debt/. Use for scheduled loop
  scans or explicit ad-hoc reports from detection JSON. Do not apply code fixes
  (use refactor) or CI repair (use ci-sweeper). Preferred via on-loop-report-tech-debt.yaml.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.3.3"
---

## Input

Injected JSON from loop-prompt-generate — see [category-input-schema.md](references/category-input-schema.md). Path allowlist and denylist arrive in the prompt `## Constraints` section (caller `LOOP_ALLOWLIST`, `LOOP_DENYLIST`).

## Operating levels

`level` arrives in injected JSON — see [category-input-schema.md#operating-levels](references/category-input-schema.md#operating-levels).

## Output Specification

Session summary per [common-output-format.md](references/common-output-format.md).
At `L2`/`L3`, write the full report to `report_file` within [category-scope.md](references/category-scope.md).

## Execution Scope

### USE FOR:

- Classify mechanical `signals[]` and `hotspots[]` into prioritized debt findings
- Produce a dated technical debt report with evidence and recommendations
- At `L2`/`L3`, create or update `docs/report/report-tech-debt/YYYY-MM-DD.md`

### DO NOT USE FOR:

- Apply code fixes, refactors, or dependency upgrades
- Edit loop state files (bundled by finalize after verification)
- Run detection or manage loop state
- Replace domain review skills; invoke named skills only when caller `## Instructions` lists them

## Reference Files Guide

- [category-debt-taxonomy.md](references/category-debt-taxonomy.md) (always read)
- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-scope.md](references/category-scope.md) (always read)
- [category-input-schema.md](references/category-input-schema.md) (always read)
- Previous report at `previous_report` (always read when path exists)

## Workflow

1. Parse [category-input-schema.md](references/category-input-schema.md). Read prompt `## Constraints` for the allowlist. If `skip` or both `signals` and `hotspots` are empty, emit session summary with Outcome `No technical debt signals detected`; stop without creating `report_file`.
2. Read `previous_report` when set and the file exists. Compare per [common-checklist.md](references/common-checklist.md#previous-report-comparison); note resolved, recurring, and regression items in session report sections and the persisted report (not in PR `## Summary` — that is emitted at synthesis from `assets/pr-body-template.md`).
3. For each `signals[]` / `hotspots[]` entry, read ±30 lines of source. Classify per [category-debt-taxonomy.md](references/category-debt-taxonomy.md) and [common-checklist.md](references/common-checklist.md) (`category`, severity section, optional `nature`).
4. Emit session summary per [common-output-format.md](references/common-output-format.md). At synthesis time load `assets/pr-body-template.md` and emit `## Overview` (scan scope, severity, report path) + `## Summary` for PR composition. Respect level and cap rules in [common-checklist.md](references/common-checklist.md).

### Error Handling

| Condition                          | Severity    | Action                                           |
| ---------------------------------- | ----------- | ------------------------------------------------ |
| `skip` or empty signals/hotspots   | Info        | Outcome `No technical debt signals detected`; stop without `report_file` |
| Path outside allowlist/denylist    | Recoverable | Classify Watch or Noise; do not edit             |
| `previous_report` path missing     | Recoverable | Skip comparison; note in session report          |
| Cap exceeded (>25 Critical+High-Priority) | Recoverable | Retain Critical first, then High-Priority to cap; defer overflow to Watch; note truncation in Summary |
