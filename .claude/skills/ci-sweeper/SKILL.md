---
name: ci-sweeper
description: >-
  Triage failing CI on integration branches and/or PR heads, classify failures,
  apply minimal fixes when actionable. Use when the user asks to triage or fix
  CI failures, when loop automation detects failed workflow runs, or when
  automation supplies detection JSON. Default is survey only; edit files only when
  the user explicitly requests a fix or automation sets may_edit in Constraints.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.6.0"
---

**UTILITY SKILL** — CI failure triage and minimal fix, not merge or release.

## Input

- **Interactive:** natural-language request; run `bash scripts/detect_ci_failures.sh` unless detect JSON is already in context — parse per [category-input-schema.md](references/category-input-schema.md)
- **Automation:** detect JSON in prompt; read `may_edit`, `write_target`, and `report_file` (when `write_target: report`) from `## Constraints` per [category-automation-envelope.md](references/category-automation-envelope.md)

Path allowlist, when present, arrives in `## Constraints`.

## Output Specification

Triage report per [common-output-format.md](references/common-output-format.md). Survey shape when files are not edited; apply shape when edited — within [category-scope.md](references/category-scope.md).

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
- [category-automation-envelope.md](references/category-automation-envelope.md) (always read — automation path)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)

## Workflow

Resolve **may_edit** before classifying failures:

| Source                                                      | `may_edit`                                                                                                               |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Interactive — default                                       | `false` — survey only; do not edit files                                                                                 |
| Interactive — fix language in the same request              | `true` — examples: fix, apply, 直して                                                                                    |
| Interactive — follow-up after a prior survey in the session | `true` when the user asks to fix or apply                                                                                |
| Automation — `## Constraints`                               | `may_edit: true` or `may_edit: false` from [category-automation-envelope.md](references/category-automation-envelope.md) |

When `may_edit` is `true`, resolve `write_target`: on the **interactive** path use `fix` (this skill); on the **automation** path read `write_target` from `## Constraints`. Do not branch on `level` or `delivery`.

1. Run `scripts/detect_ci_failures.sh` (interactive) or parse detect JSON per [category-input-schema.md](references/category-input-schema.md).
2. On the automation path, read [category-automation-envelope.md](references/category-automation-envelope.md) for Constraints, PR templates, and Session Metrics.
3. If `skip` or no actionable `failures`, emit survey no-op; on automation path append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop.
4. Classify every item in `failures[]` per [common-checklist.md](references/common-checklist.md). Note `ignored[]` in Overview when non-empty.
5. When `may_edit` is `false`, emit survey shape with `### Candidates`; on automation path load `assets/pr-body-template-survey.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop — do not edit files.
6. When `may_edit` is `true` and `write_target` is not `fix` → emit survey shape; note expected `write_target: fix` in Overview; stop — do not edit files.
7. When `may_edit` is `true` and `write_target` is `fix`, fix the first `regression` only when more than three failures are present; defer the rest within [category-scope.md](references/category-scope.md).
8. When infra/env/flake or >5 files are required, classify as Watch with no edits.
9. Run validation per [category-validation-commands.md](references/category-validation-commands.md); record outcome in Session Metrics on the automation path.
10. When `may_edit` is `true` and `write_target` is `fix`, emit apply shape per [common-output-format.md](references/common-output-format.md); reconcile **Changes** / **Deferred** with `git diff --name-only`; on automation path load `assets/pr-body-template.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md).

### Error Handling

| Condition                                     | Severity    | Action                                                                           |
| --------------------------------------------- | ----------- | -------------------------------------------------------------------------------- |
| `skip` or no actionable `failures`            | Info        | Outcome `no actionable failures`; stop                                           |
| Fix requested but `may_edit` is `false`       | Info        | Survey only; note that edits require an explicit fix request or `may_edit: true` |
| `may_edit` true with `write_target` not `fix` | Recoverable | Survey only; note expected `write_target: fix`                                   |
| Infra/env/flake or >5 files required          | Recoverable | Classify Watch; no edits                                                         |
| Validation tooling missing                    | Recoverable | Defer Watch unless fixing one line from `log_excerpt`                            |
| Path outside allowlist                        | Recoverable | Watch or defer; do not edit                                                      |
