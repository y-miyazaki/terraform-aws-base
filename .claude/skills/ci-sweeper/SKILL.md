---
name: ci-sweeper
description: >-
  Triage failing CI on integration branches and/or PR heads, classify
  failures, apply minimal fixes when actionable. Use in conversation when the
  user asks to triage or fix CI failures. Also the loop entry skill when
  automation detects failed workflow runs or supplies detection JSON.
  Interactive default is survey only; edit files when the request asks for
  changes to be made (for example fix, apply, or update) or automation sets
  agent_edit_allowed in Constraints.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.6.4"
---

**UTILITY SKILL** — CI failure triage and minimal fix, not merge or release.

## Input

- **Interactive (required):** natural-language request; optional failure context (URLs, logs, job names) — constraints in `## Constraints` or [category-scope.md](references/category-scope.md)
- **Automation (optional):** detect JSON in prompt — from a caller or optional skill detect script; not required for interactive runs. Read `agent_edit_allowed` and `agent_edit_target` from `## Constraints` per [category-automation-envelope.md](references/category-automation-envelope.md)

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
- [category-detect-scope.md](references/category-detect-scope.md) (read on interactive path)
- [category-input-schema.md](references/category-input-schema.md) (read when detect JSON is present or the optional detect script is run)
- [category-run-ledger.md](references/category-run-ledger.md) (read when ignored[] is non-empty)
- [category-automation-envelope.md](references/category-automation-envelope.md) (read on automation path)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [category-pr-body-links.md](references/category-pr-body-links.md) (read when synthesizing the PR body)
- `assets/pr-body-template.md` and `assets/pr-body-template-survey.md` (read when synthesizing the PR body)

## Workflow

Resolve **agent_edit_allowed** before classifying failures:

| Source                                                                                                          | `agent_edit_allowed`                                                                                                                         |
| --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Interactive — default: the request asks to look, check, triage, or survey, or only names the skill              | `false` — survey only; do not edit files                                                                                                     |
| Interactive — the request asks for changes to be made (for example fix, apply, 修正して, 適用して, update, add) | `true`                                                                                                                                       |
| Interactive — follow-up after a survey asking to apply                                                          | `true`                                                                                                                                       |
| Automation — `## Constraints`                                                                                   | `agent_edit_allowed: true` or `agent_edit_allowed: false` from [category-automation-envelope.md](references/category-automation-envelope.md) |

When intent is unclear, survey and offer to apply — edits are harder to undo than a report.

When `agent_edit_allowed` is `true`, resolve `agent_edit_target`: on the **interactive** path use `fix` (this skill); on the **automation** path read `agent_edit_target` from `## Constraints`. Do not branch on other caller metadata outside `## Constraints`.

1. Resolve scope ([category-scope.md](references/category-scope.md)). Parse detect JSON when present; otherwise resolve the detect universe from the prompt ([category-detect-scope.md](references/category-detect-scope.md)), run this skill's optional detect script with the resolved `--scope` (default `all`), then Agent-complement beyond mechanical output; if tools for detect are unavailable, gather failures from the user request and available CI/log context instead of silent no-op. Load [category-input-schema.md](references/category-input-schema.md) when parsing detect output. On detect script non-zero exit, read stdout and stop.
2. On the automation path, read [category-automation-envelope.md](references/category-automation-envelope.md) for Constraints, PR templates, and Session Metrics.
3. IF detect reports `skip` OR no actionable failures after gathering → emit survey no-op per [common-output-format.md](references/common-output-format.md) (Overview explains no-op); on automation path append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop.
4. Classify **each** failure per [common-checklist.md](references/common-checklist.md): fixable `regression` within scope, or Watch-class (`flake`, `infra`, `env`, or a fix requiring more than five files). Note `ignored[]` in Overview when non-empty.
5. IF `agent_edit_allowed` is `false` → emit survey shape (`### Candidates` for regressions, `### Watch` for Watch-class failures); on automation path load `assets/pr-body-template-survey.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop — do not edit files.
6. ELSE IF `agent_edit_allowed` is `true` AND `agent_edit_target` is not `fix` → emit survey shape; note expected `agent_edit_target: fix` in Overview; stop — do not edit files.
7. ELSE IF no failure is a fixable regression (every failure is Watch-class) → emit survey shape with `### Watch` per [common-output-format.md](references/common-output-format.md); on automation path load `assets/pr-body-template-survey.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop — do not edit files.
8. ELSE (`agent_edit_allowed` is `true` AND `agent_edit_target` is `fix`) → fix fixable regressions within [category-scope.md](references/category-scope.md). When more than three failures are present, fix only the first regression and defer the rest. Watch-class failures get no edits.
9. After edits, run the repository's existing check for each fixed job (the command the failing job runs, when available locally) and record commands and outcomes in `## Verification`; never claim a check passed when it failed or was not run.
10. Emit apply shape per [common-output-format.md](references/common-output-format.md): fixed regressions under `### Changes`; deferred regressions and Watch-class failures under `### Deferred`. Reconcile **Changes** / **Deferred** with `git diff --name-only`; on automation path load `assets/pr-body-template.md` at synthesis and append `## Session Metrics` (including validation commands) per [category-automation-envelope.md](references/category-automation-envelope.md).

### Error Handling

| Condition                                                           | Severity    | Action                                                                                  |
| ------------------------------------------------------------------- | ----------- | --------------------------------------------------------------------------------------- |
| Detect script non-zero exit or `status: "error"` (when invoked)     | Fatal       | Read stdout; stop — do not treat as success-path detect JSON                            |
| `skip` or no actionable `failures`                                  | Info        | Emit survey no-op (Overview explains no-op); stop                                       |
| Edit requested but `## Constraints` set `agent_edit_allowed: false` | Info        | Survey only; note that the caller Constraints disallow edits                            |
| `agent_edit_allowed` true with `agent_edit_target` not `fix`        | Recoverable | Survey only; note expected `agent_edit_target: fix`                                     |
| A failure is infra/env/flake or needs >5 files                      | Recoverable | No edits for that failure; Watch (survey) or Deferred (apply); continue with the others |
| Validation tooling missing                                          | Recoverable | Defer the failure unless fixing one line from `log_excerpt`                             |
| Path outside allowlist                                              | Recoverable | Watch or defer; do not edit                                                             |

### Examples

- Prompt: `Triage failing CI on the integration branch`
- Result: Survey report per [references/common-output-format.md](references/common-output-format.md); apply one-line regression fixes only when `agent_edit_allowed` is true and `agent_edit_target` is `fix`.
