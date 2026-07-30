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
  version: "2.0.6"
---

**UTILITY SKILL** — changelog survey and patch, not release tagging.

## Input

- **Interactive (required):** natural-language request; optional scope (`all`, or `range` with `--since`) — constraints in `## Constraints` or [category-scope.md](references/category-scope.md)
- **Automation (optional):** detect JSON in prompt — from a caller or optional skill detect script; not required for interactive runs. Read `may_edit`, `write_target`, and `report_file` (when `write_target: report`) from `## Constraints` per [category-automation-envelope.md](references/category-automation-envelope.md)

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
- [category-input-schema.md](references/category-input-schema.md) (read when detect JSON is present or the optional detect script is run)
- [category-automation-envelope.md](references/category-automation-envelope.md) (read on automation path)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)

## Workflow

Resolve **may_edit** before mapping commits:

| Source                                                      | `may_edit`                                                                                                                                 |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Interactive — default                                       | `false` — survey only; do not edit `changelog_file`                                                                                        |
| Interactive — explicit fix language in the same request     | `true` — examples: 修正して, update the changelog, apply these entries. Do **not** treat bare skill name `changelog` or bare `fix` as edit |
| Interactive — follow-up after a prior survey in the session | `true` when the user explicitly asks to apply listed entries or update the changelog                                                       |
| Automation — `## Constraints`                               | `may_edit: true` or `may_edit: false` from [category-automation-envelope.md](references/category-automation-envelope.md)                   |

When `may_edit` is `true`, resolve `write_target`: on the **interactive** path use `fix` (this skill); on the **automation** path read `write_target` from `## Constraints`. Do not branch on other caller metadata outside `## Constraints`.

1. Resolve scope ([category-scope.md](references/category-scope.md)). Parse detect JSON when present; otherwise run this skill's optional detect script when helpful, or gather commits/releases from the user request and repository tools. Load [category-input-schema.md](references/category-input-schema.md) when parsing detect output. On detect script non-zero exit, read stdout and stop.
2. On the automation path, read [category-automation-envelope.md](references/category-automation-envelope.md) for Constraints, PR templates, and Session Metrics.
3. IF detect reports `skip` OR both `commits` and `releases` are empty after gathering → emit survey no-op; on automation path append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop.
4. Map commits and releases per [common-checklist.md](references/common-checklist.md).
5. IF `may_edit` is `false` → emit survey shape with `### Candidates`; on automation path load `assets/pr-body-template-survey.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); stop — do not edit `changelog_file`.
6. ELSE IF `may_edit` is `true` AND `write_target` is not `fix` → emit survey shape; note expected `write_target: fix` in Overview; stop — do not edit `changelog_file`.
7. ELSE (`may_edit` is `true` AND `write_target` is `fix`) → edit only `changelog_file` per [category-scope.md](references/category-scope.md); emit apply shape with `### Changes` and `## Verification`; on automation path load `assets/pr-body-template.md` at synthesis and append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md).

### Error Handling

| Condition                                                       | Severity    | Action                                                                           |
| --------------------------------------------------------------- | ----------- | -------------------------------------------------------------------------------- |
| Detect script non-zero exit or `status: "error"` (when invoked) | Fatal       | Read stdout; stop — do not treat as success-path detect JSON                     |
| `skip` or empty commits/releases                                | Info        | Report skip outcome; stop                                                        |
| `changelog_file` outside scope                                  | Recoverable | Defer; note in report                                                            |
| Fix requested but `may_edit` is `false`                         | Info        | Survey only; note that edits require an explicit fix request or `may_edit: true` |
| `may_edit` true with `write_target` not `fix`                   | Recoverable | Survey only; note expected `write_target: fix`                                   |
| `changelog_exists` false and `may_edit` is `true`               | Recoverable | Create Keep a Changelog template, then add bullets                               |

### Examples

- Prompt: `Survey CHANGELOG gaps from unreleased commits`
- Result: Survey report per [references/common-output-format.md](references/common-output-format.md); edit `changelog_file` only when `may_edit` is true.
