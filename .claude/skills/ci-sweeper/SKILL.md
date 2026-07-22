---
name: ci-sweeper
description: >-
  Triage failing CI on integration branches and/or PR heads, classify failures,
  apply minimal fixes when actionable. Use when loop automation detects failed
  workflow runs or when explicitly invoked with detection JSON. Preferred entry
  via on-loop-ci-sweeper.yaml.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.4.4"
---

## Input

Injected JSON from loop-prompt-generate — see [category-input-schema.md](references/category-input-schema.md).

## Operating levels

`level` arrives in injected JSON — see [category-input-schema.md](references/category-input-schema.md#operating-levels).

## Output Specification

Triage report per [common-output-format.md](references/common-output-format.md).
At `L2`/`L3`, edit actionable `regression` failures within [category-scope.md](references/category-scope.md).

## Execution Scope

### USE FOR:

- Classify CI failures; apply minimal lint/workflow/shell/doc fixes
- Run validation after edits

### DO NOT USE FOR:

- Infra outages, secrets, or runner capacity issues (classify as Watch)
- Refactors >5 files or auth/payment/credential paths
- Merge PRs or push to default branch

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-scope.md](references/category-scope.md) (always read)
- [category-input-schema.md](references/category-input-schema.md) (always read)
- [category-run-ledger.md](references/category-run-ledger.md) (always read)
- [category-validation-commands.md](references/category-validation-commands.md) (always read)

## Workflow

1. Parse [category-input-schema.md](references/category-input-schema.md). If `skip` or no actionable `failures`, emit all session report sections; set Session Metrics **Outcome** to `no actionable failures`; stop.
2. Classify every item in `failures[]` per [common-checklist.md](references/common-checklist.md). Use detect `failure_type` as a hint only — reclassify when `log_excerpt` contradicts it. List `ignored[]` entries under `## Ignored`.
3. For `regression` at `L2`/`L3`, fix the first regression only when more than three failures are present; defer the rest as Watch. Edit only within [category-scope.md](references/category-scope.md) allowlist.
4. When infra/env/flake or >5 files are required, classify as Watch with no edits. Set Session Metrics **Outcome** to `watch` (or `deferred`) so finalize records `outcome: watch`.
5. Run validation per [category-validation-commands.md](references/category-validation-commands.md) and caller `## Instructions` stack routing; record outcome in Session Metrics. If validation tooling is missing, defer as Watch unless fixing a single reported line from `log_excerpt`.
6. Output session report per [common-output-format.md](references/common-output-format.md); reconcile Changes / Deferred with `git diff --name-only`; at synthesis load `assets/pr-body-template.md` and emit `## Overview`, `## Summary`, and `## Verification`.

### Error Handling

| Condition                              | Severity    | Action                                                |
| -------------------------------------- | ----------- | ----------------------------------------------------- |
| `skip` or no actionable `failures`     | Info        | Outcome `no actionable failures`; stop                |
| Infra/env/flake or >5 files required   | Recoverable | Classify Watch; no edits                              |
| Validation tooling missing           | Recoverable | Defer Watch unless fixing one line from `log_excerpt` |
| Path outside allowlist                 | Recoverable | Watch or defer; do not edit                           |
