---
name: tech-debt
description: >-
  Discover and classify technical debt from mechanical signals, apply closed-set
  fixes when requested, and publish structured reports (override via
  TECH_DEBT_DIR or report_file from detect JSON / Constraints).
  Use for scheduled automation scans, ad-hoc surveys from detection JSON, or when the user
  asks to fix safe documentation/dependency debt. Default is survey only; write
  report_file and apply fixes only when the user explicitly requests apply or
  automation sets may_edit in Constraints. Delegate structural work to refactor.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "2.1.0"
---

**UTILITY SKILL** — technical debt survey and closed-set apply, not structural refactor.

## Input

- **Interactive:** natural-language request; run this skill's detect script unless detect JSON is already in context — parse per [category-input-schema.md](references/category-input-schema.md)
- **Automation:** detect JSON in prompt; read `may_edit`, `write_target`, and `report_file` from `## Constraints` per [category-automation-envelope.md](references/category-automation-envelope.md)

Path allowlist, when present, arrives in `## Constraints`.

## Output Specification

Tech-debt report per [common-output-format.md](references/common-output-format.md). Survey shape when `report_file` is not written; apply shape when written — within [category-scope.md](references/category-scope.md).

## Execution Scope

### USE FOR:

- Classify mechanical `signals[]` and `hotspots[]` into prioritized debt findings
- Survey: emit Candidates with Delegate hints (`refactor`, `docs-updater`, `self`, `human`)
- Apply: write `report_file`; apply closed-set fixes (`broken_doc_ref`, `stale_doc`, simple `pin_drift`) within allowlist

### DO NOT USE FOR:

- Structural refactors or architecture changes (use refactor)
- CI repair (use ci-sweeper)
- Security remediation beyond reporting
- Edit caller state files (owned by the caller after verification)

## Reference Files Guide

- [category-debt-taxonomy.md](references/category-debt-taxonomy.md) (always read)
- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-scope.md](references/category-scope.md) (always read)
- [category-input-schema.md](references/category-input-schema.md) (always read)
- [category-automation-envelope.md](references/category-automation-envelope.md) (always read — automation path)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- Previous report at `previous_report` (always read when path exists)

## Workflow

Resolve **may_edit** before classifying signals:

| Source                                                      | `may_edit`                                                                                                               |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Interactive — default                                       | `false` — survey only; do not write `report_file`                                                                        |
| Interactive — apply language in the same request            | `true` — examples: 直して, apply fixes, write the report, update the report path                                         |
| Interactive — follow-up after a prior survey in the session | `true` when the user asks to fix, apply, or write the report                                                             |
| Automation — `## Constraints`                               | `may_edit: true` or `may_edit: false` from [category-automation-envelope.md](references/category-automation-envelope.md) |

When `may_edit` is `true`, resolve `write_target` and `report_file`: on the **interactive** path use `write_target: report` and `report_file` from detect JSON (`report_file` field) or the user request; on the **automation** path read both from `## Constraints`. Do not branch on other caller metadata outside `## Constraints`.

1. Run this skill's detect script (interactive) or parse detect JSON per [category-input-schema.md](references/category-input-schema.md). On non-zero exit, read stdout and stop.
2. On the automation path, read [category-automation-envelope.md](references/category-automation-envelope.md) for Constraints, PR templates, and Session Metrics.
3. Read `previous_report` when set. Compare per [common-checklist.md](references/common-checklist.md#previous-report-comparison). If `skip` or both `signals` and `hotspots` are empty, emit survey no-op; on automation path append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop.
4. For each signal/hotspot, read ±30 lines. Classify per [category-debt-taxonomy.md](references/category-debt-taxonomy.md). Assign Delegate per taxonomy row.
5. When `may_edit` is `false`, emit survey shape with `### Candidates` and optional `### Watch`; on automation path load `assets/pr-body-template-survey.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop — do not write `report_file`.
6. When `may_edit` is `true` and `write_target` is not `report` → emit survey shape; note expected `write_target: report` in Overview; stop — do not write `report_file`.
7. When `may_edit` is `true` and `write_target` is `report` but `report_file` is missing or empty → emit survey shape; note missing `report_file` in Overview; stop.
8. When `may_edit` is `true` and `write_target` is `report`, write `report_file` within allowlist with full persisted structure; apply closed-set fixes per [category-scope.md](references/category-scope.md); emit apply shape with `### Changes`, optional `### Deferred`, and `## Verification`; on automation path load `assets/pr-body-template.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md).

### Error Handling

| Condition                                                              | Severity    | Action                                                                             |
| ---------------------------------------------------------------------- | ----------- | ---------------------------------------------------------------------------------- |
| Detect script non-zero exit or `status: "error"`                       | Fatal       | Read stdout; stop — do not treat as success-path detect JSON                       |
| `skip` or empty signals/hotspots                                       | Info        | Report skip outcome; stop                                                          |
| Path outside allowlist/denylist                                        | Recoverable | Classify Watch; do not edit                                                        |
| `previous_report` path missing                                         | Recoverable | Skip comparison; note in Overview                                                  |
| Apply requested but `may_edit` is `false`                              | Info        | Survey only; note that edits require an explicit apply request or `may_edit: true` |
| `may_edit` true with `write_target` not `report`                       | Recoverable | Survey only; note expected `write_target: report`                                  |
| `may_edit` true with missing `report_file` when `write_target: report` | Recoverable | Survey only; note missing `report_file` in Constraints or detect JSON              |
| Cap exceeded (>25 Critical+High-Priority)                              | Recoverable | Retain Critical first; defer overflow to Watch; note truncation                    |
