---
name: docs-updater
description: >-
  Detect documentation drift and patch affected docs (candidate survey, git
  hook, range cursor, or detect JSON). Use in conversation when the user asks
  to sync or update docs after code changes. Also the loop entry skill for
  documentation drift automation. Interactive default is survey only; edit
  docs when the request asks for changes to be made (for example fix, apply,
  or update) or automation sets agent_edit_allowed in Constraints. Not for new
  document creation or markdown linting.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "3.4.3"
---

**UTILITY SKILL** — automated diff-sync and drift repair, not content authoring.

## Input

- **Interactive / hook (required):** resolve scope per [category-detect-scope.md](references/category-detect-scope.md) — Interactive free-form → `all` (full candidate docs); git hook → `staged`; automation cursor → `range` with `--since` — triage per [common-impact-map.md](references/common-impact-map.md); validate patches per [common-checklist.md](references/common-checklist.md)
- **Automation (optional):** detect JSON in prompt — from a caller or optional skill detect script; not required for interactive runs. Read `agent_edit_allowed` and `agent_edit_target` from `## Constraints` per [category-automation-envelope.md](references/category-automation-envelope.md); load [category-input-schema.md](references/category-input-schema.md) on that path only

Path allowlist, when present, arrives in `## Constraints`.

## Output Specification

Report per [common-output-format.md](references/common-output-format.md). On the automation path, also follow [common-output-format-automation.md](references/common-output-format-automation.md) and [category-automation-envelope.md](references/category-automation-envelope.md). Stay within [category-scope.md](references/category-scope.md).

## Execution Scope

Target: candidate documentation per [common-impact-map.md](references/common-impact-map.md) Search Scope — typically root `*.md`, the repository's documentation tree, nested `README.md` files (excluding generated directories), and site nav config when present.

### USE FOR:

- Survey candidate documentation for drift and sync opportunities (Interactive `all`); update cross-references, tables, lists, and nav entries for changed paths
- Remove dead links; update paths for renames
- Apply minimal documentation patches per [common-checklist.md](references/common-checklist.md) and [category-documentation-maintenance.md](references/category-documentation-maintenance.md)

### DO NOT USE FOR:

- New document creation or content improvement
- Non-documentation file edits
- Markdown linting
- Run detection scripts for other skills or manage caller state

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-impact-map.md](references/common-impact-map.md) (read on interactive path)
- [category-documentation-maintenance.md](references/category-documentation-maintenance.md) (read when deduplication or same-change sync applies)
- [category-scope.md](references/category-scope.md) (always read)
- [category-detect-scope.md](references/category-detect-scope.md) (read on interactive path)
- [category-input-schema.md](references/category-input-schema.md) (read when detect JSON is present or the optional detect script is run)
- [category-automation-envelope.md](references/category-automation-envelope.md) (read on automation path)
- [common-output-format-automation.md](references/common-output-format-automation.md) (read on automation path)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [category-pr-body-links.md](references/category-pr-body-links.md) (read when synthesizing the PR body)
- `assets/pr-body-template.md` and `assets/pr-body-template-survey.md` (read when synthesizing the PR body)

## Workflow

Resolve **agent_edit_allowed** before patching (git hook runs follow the Interactive rows):

| Source                                                                                                          | `agent_edit_allowed`                                                                                                                         |
| --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Interactive — default: the request asks to look, check, triage, or survey, or only names the skill              | `false` — survey only; do not edit documentation files                                                                                       |
| Interactive — the request asks for changes to be made (for example fix, apply, 修正して, 適用して, update, add) | `true`                                                                                                                                       |
| Interactive — follow-up after a survey asking to apply                                                          | `true`                                                                                                                                       |
| Automation — `## Constraints`                                                                                   | `agent_edit_allowed: true` or `agent_edit_allowed: false` from [category-automation-envelope.md](references/category-automation-envelope.md) |

When intent is unclear, survey and offer to apply — edits are harder to undo than a report.

When `agent_edit_allowed` is `true`, resolve `agent_edit_target`: on the **interactive** path use `fix` (this skill); on the **automation** path read `agent_edit_target` from `## Constraints`. Do not branch on other caller metadata outside `## Constraints`.

### Interactive / hook path

1. Resolve scope ([category-scope.md](references/category-scope.md)). Parse detect JSON when present; otherwise resolve the detect universe from the prompt ([category-detect-scope.md](references/category-detect-scope.md)), run this skill's optional detect script with the resolved `--scope` (default `all` for Interactive free-form; `staged` for git hook; `range` when the user named a SHA range), then Agent-complement beyond mechanical output; if tools for detect are unavailable, gather changed paths from git and the user request instead of silent no-op. On detect script non-zero exit, read stdout and stop.
2. IF detect reports `skip` OR no documentation impact after gathering → emit survey no-op per [common-output-format.md](references/common-output-format.md) (Overview explains no-op); stop.
3. Triage affected docs per [common-impact-map.md](references/common-impact-map.md); grep before full read.
4. IF `agent_edit_allowed` is `false` OR `agent_edit_target` is not `fix` → emit survey shape per [common-output-format.md](references/common-output-format.md); stop — do not edit documentation files or run `git add`.
5. ELSE → apply minimal patches per [common-checklist.md](references/common-checklist.md); when the repository maintains a generated documentation index and documentation files were created/deleted/renamed, regenerate it per UV-05; stage with `git add`; emit apply shape per [common-output-format.md](references/common-output-format.md).

### Automation path

When detect JSON and `## Constraints` are present: follow [category-automation-envelope.md](references/category-automation-envelope.md) for edit gate, report shape, and synthesis. Triage and patch per [common-checklist.md](references/common-checklist.md) and [category-documentation-maintenance.md](references/category-documentation-maintenance.md). Do not manage caller state.

### Error Handling

| Condition                                                           | Severity    | Action                                                                                        |
| ------------------------------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------- |
| Detect script non-zero exit or `status: "error"` (when invoked)     | Fatal       | Read stdout; stop — do not treat as success-path detect JSON                                  |
| No git repository                                                   | Fatal       | Stop                                                                                          |
| Empty diff / no documentation impact                                | Info        | Emit survey no-op (Overview explains no-op); stop                                             |
| Affected doc file missing                                           | Recoverable | Skip file; note in report                                                                     |
| Exceeds scope (>3 H2, new top-level document, etc.)                 | Recoverable | Stop for file; note out of scope for new top-level authoring                                  |
| `mkdocs.yml` missing                                                | Recoverable | Skip nav update                                                                               |
| Edit requested but `## Constraints` set `agent_edit_allowed: false` | Info        | Survey only; note that the caller Constraints disallow edits                                  |
| Automation `agent_edit_target` mismatch                             | Recoverable | Survey only per [category-automation-envelope.md](references/category-automation-envelope.md) |

### Examples

- Prompt: `Sync docs after the latest commit diff`
- Result: Survey or apply report per [references/common-output-format.md](references/common-output-format.md); stay within the UV-04 scope gate in [references/common-checklist.md](references/common-checklist.md).
