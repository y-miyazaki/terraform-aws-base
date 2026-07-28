---
name: ci-sweeper
description: >-
  Triage failing CI on integration branches and/or PR heads, classify failures,
  apply minimal fixes when actionable. Use when the user asks to triage or fix
  CI failures, when automation detects failed workflow runs, or when
  automation supplies detection JSON. Default is survey only; edit files only when
  the user explicitly requests a fix or automation sets may_edit in Constraints.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.6.0"
---

**UTILITY SKILL** — CI failure triage and minimal fix, not merge or release.

## Input

- **Interactive:** natural-language request; run this skill's detect script unless detect JSON is already in context — parse per [category-input-schema.md](references/category-input-schema.md)
- **Automation:** detect JSON in prompt; read `may_edit`, `write_target`, and `report_file` (when `write_target: report`) from `## Constraints` per [category-automation-envelope.md](references/category-automation-envelope.md)

Path allowlist, when present, arrives in `## Constraints`.

## Output Specification

Triage report per [common-output-format.md](references/common-output-format.md). Survey shape when files are not edited; apply shape when edited — within [category-scope.md](references/category-scope.md).

## Execution Scope

### USE FOR:

- Classify CI failures; apply minimal lint/workflow/shell/doc fixes

### DO NOT USE FOR:

- Infra outages, secrets, or runner capacity issues (classify as Watch)
- Refactors >5 files or auth/payment/credential paths
- Merge PRs or push to default branch

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-scope.md](references/category-scope.md) (always read)
- [category-input-schema.md](references/category-input-schema.md) (always read)
- [category-run-ledger.md](references/category-run-ledger.md) (read when ignored[] is non-empty)
- [category-automation-envelope.md](references/category-automation-envelope.md) (read on automation path)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)

## Workflow

Resolve **may_edit** before classifying failures:

| Source                                                      | `may_edit`                                                                                                               |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Interactive — default                                       | `false` — survey only; do not edit files                                                                                 |
| Interactive — fix language in the same request              | `true` — examples: fix, apply, 直して                                                                                    |
| Interactive — follow-up after a prior survey in the session | `true` when the user asks to fix or apply                                                                                |
| Automation — `## Constraints`                               | `may_edit: true` or `may_edit: false` from [category-automation-envelope.md](references/category-automation-envelope.md) |

When `may_edit` is `true`, resolve `write_target`: on the **interactive** path use `fix` (this skill); on the **automation** path read `write_target` from `## Constraints`. Do not branch on other caller metadata outside `## Constraints`.

1. Run this skill's detect script (interactive) or parse detect JSON per [category-input-schema.md](references/category-input-schema.md). On non-zero exit, read stdout and stop.
2. On the automation path, read [category-automation-envelope.md](references/category-automation-envelope.md) for Constraints, PR templates, and Session Metrics.
3. IF `skip` OR no actionable `failures` → emit survey no-op; on automation path append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop.
4. Classify every item in `failures[]` per [common-checklist.md](references/common-checklist.md). Note `ignored[]` in Overview when non-empty.
5. IF `may_edit` is `false` → emit survey shape with `### Candidates`; on automation path load `assets/pr-body-template-survey.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop — do not edit files.
6. ELSE IF `may_edit` is `true` AND `write_target` is not `fix` → emit survey shape; note expected `write_target: fix` in Overview; stop — do not edit files.
7. ELSE IF `may_edit` is `true` AND `write_target` is `fix` AND (infra/env/flake OR >5 files required) → classify as Watch with no edits; emit survey shape with `### Watch` per [common-output-format.md](references/common-output-format.md); on automation path append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop — do not emit apply shape.
8. ELSE IF `may_edit` is `true` AND `write_target` is `fix` → fix the first `regression` only when more than three failures are present; defer the rest within [category-scope.md](references/category-scope.md).
9. When validation was run (interactive fix path or caller CI), record commands and outcomes in Session Metrics on the automation path.
10. IF `may_edit` is `true` AND `write_target` is `fix` AND NOT (infra/env/flake OR >5 files required) → emit apply shape per [common-output-format.md](references/common-output-format.md); reconcile **Changes** / **Deferred** with `git diff --name-only`; on automation path load `assets/pr-body-template.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md).

### Error Handling

| Condition                                        | Severity    | Action                                                                           |
| ------------------------------------------------ | ----------- | -------------------------------------------------------------------------------- |
| Detect script non-zero exit or `status: "error"` | Fatal       | Read stdout; stop — do not treat as success-path detect JSON                     |
| `skip` or no actionable `failures`               | Info        | Outcome `no actionable failures`; stop                                           |
| Fix requested but `may_edit` is `false`          | Info        | Survey only; note that edits require an explicit fix request or `may_edit: true` |
| `may_edit` true with `write_target` not `fix`    | Recoverable | Survey only; note expected `write_target: fix`                                   |
| Infra/env/flake or >5 files required             | Recoverable | Classify Watch; no edits                                                         |
| Validation tooling missing                       | Recoverable | Defer Watch unless fixing one line from `log_excerpt`                            |
| Path outside allowlist                           | Recoverable | Watch or defer; do not edit                                                      |

### Examples

- Prompt: `Triage failing CI on the integration branch`
- Result: Survey report per [references/common-output-format.md](references/common-output-format.md); apply one-line regression fixes only when `may_edit` is true.
