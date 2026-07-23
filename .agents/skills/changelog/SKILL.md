---
name: changelog
description: >-
  Survey and update CHANGELOG.md from unreleased commits and undocumented releases
  (conventional, renovate, chore, pin/finalize subjects, and git tags). Use when
  the user asks to check, review, or update the changelog, or when automation supplies
  commit/release detect JSON. Default is survey only; edit CHANGELOG.md only when the
  user explicitly requests a fix or automation sets may_edit in Constraints.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "2.0.3"
---

**UTILITY SKILL** — changelog survey and patch, not release tagging.

## Input

- **Interactive:** natural-language request; run `bash scripts/detect_changelog_commits.sh --scope all` (or `--scope range --since <ref>`) unless detect JSON is already in context — parse per [category-input-schema.md](references/category-input-schema.md)
- **Automation:** detect JSON in prompt; read `may_edit`, `write_target`, and `report_file` (when `write_target: report`) from `## Constraints` per [category-automation-envelope.md](references/category-automation-envelope.md)

Path allowlist, when present, arrives in `## Constraints`.

## Output Specification

Changelog report per [common-output-format.md](references/common-output-format.md). Survey shape when `changelog_file` is not edited; apply shape when edited — within [category-scope.md](references/category-scope.md).

## Execution Scope

### USE FOR:

- Survey unreleased commits and undocumented releases; emit Candidates under `## [Unreleased]`
- Create `CHANGELOG.md` from the Keep a Changelog template when `changelog_exists` is false and edits are allowed
- Group detect `commits[]` into Keep a Changelog sections under `## [Unreleased]`
- Promote detect `releases[]` into `## [x.y.z] - date` sections and move matching bullets out of `## [Unreleased]`
- Preserve existing released version sections and formatting

### DO NOT USE FOR:

- Create git tags or cut releases in CI outside the changelog file
- Run detection when the caller already supplied complete detect JSON (automation path)

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-scope.md](references/category-scope.md) (always read)
- [category-input-schema.md](references/category-input-schema.md) (always read)
- [category-automation-envelope.md](references/category-automation-envelope.md) (always read — automation path)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)

## Workflow

Resolve **may_edit** before mapping commits:

| Source                                                      | `may_edit`                                                                                                               |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Interactive — default                                       | `false` — survey only; do not edit `changelog_file`                                                                      |
| Interactive — fix language in the same request              | `true` — examples: 修正して, update the changelog, apply these entries                                                   |
| Interactive — follow-up after a prior survey in the session | `true` when the user asks to fix, apply, or update the changelog                                                         |
| Automation — `## Constraints`                               | `may_edit: true` or `may_edit: false` from [category-automation-envelope.md](references/category-automation-envelope.md) |

When `may_edit` is `true`, resolve `write_target`: on the **interactive** path use `fix` (this skill); on the **automation** path read `write_target` from `## Constraints`. Do not branch on `level` or `delivery`.

1. Run `scripts/detect_changelog_commits.sh` (interactive) or parse detect JSON per [category-input-schema.md](references/category-input-schema.md).
2. On the automation path, read [category-automation-envelope.md](references/category-automation-envelope.md) for Constraints, PR templates, and Session Metrics.
3. If `skip` or both `commits` and `releases` are empty, emit survey no-op; on automation path append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop.
4. Map commits and releases per [common-checklist.md](references/common-checklist.md).
5. When `may_edit` is `false`, emit survey shape with `### Candidates`; on automation path load `assets/pr-body-template-survey.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop — do not edit `changelog_file`.
6. When `may_edit` is `true` and `write_target` is not `fix` → emit survey shape; note expected `write_target: fix` in Overview; stop — do not edit `changelog_file`.
7. When `may_edit` is `true` and `write_target` is `fix`, edit only `changelog_file` per [category-scope.md](references/category-scope.md); emit apply shape with `### Changes` and `## Verification`; on automation path load `assets/pr-body-template.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md).

### Error Handling

| Condition                                         | Severity    | Action                                                                           |
| ------------------------------------------------- | ----------- | -------------------------------------------------------------------------------- |
| `skip` or empty commits/releases                  | Info        | Report skip outcome; stop                                                        |
| `changelog_file` outside scope                    | Recoverable | Defer; note in report                                                            |
| Fix requested but `may_edit` is `false`           | Info        | Survey only; note that edits require an explicit fix request or `may_edit: true` |
| `may_edit` true with `write_target` not `fix`     | Recoverable | Survey only; note expected `write_target: fix`                                   |
| `changelog_exists` false and `may_edit` is `true` | Recoverable | Create Keep a Changelog template, then add bullets                               |
