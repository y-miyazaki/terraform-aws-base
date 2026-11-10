---
name: agent-skills-review
description: >-
  Review SKILL.md quality for Waza readiness and agent-skills-instructions compliance.
  Use when evaluating SKILL.md quality, checking compliance with skill authoring standards,
  preparing skills for release, reviewing skill PRs, or running waza readiness checks.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.10"
---

## Input

- Target (required): `<agent-root>/skills/*/SKILL.md`
- Sibling skills (optional): other `<agent-root>/skills/*/SKILL.md` in the same package or sharing the target's contract files — enables P-04; without them P-04 is deferred
- Evidence (required when not pre-supplied): outputs from `scripts/validate_waza.sh` and `scripts/validate.sh` — run both in Workflow step 1 when absent from context

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md). That file is the source of truth for the output contract.

Skill-local addition: unlike other review skills, this skill runs validation scripts, so `Status: failed` also applies when both scripts fail. The `## Issues` cause entry (no ItemID) then lists both commands, exit statuses, and stderr summaries.

## Execution Scope

- Run validation scripts and parse results to assess SKILL.md quality against S-_, Q-_, P-_, and BP-_ checks.
- Check `waza check` token output and apply Q-09 per Workflow step 2.

### USE FOR:

- review new SKILL drafts before release
- note token budget advisories when `waza check` exceeds 500 tokens (Q-09)
- report SKILL spec compliance findings in PR reviews

### DO NOT USE FOR:

- implement product features
- debug product runtime failures unrelated to SKILL quality checks
- run benchmark content evaluations (`waza run eval.yaml`) as a substitute for compliance checks
- modify or overwrite the target SKILL.md without explicit user approval (review output only; do not write or commit changes)
- merge PRs or edit unrelated files
- review product runtime behavior or application business logic

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-best-practices.md](references/category-best-practices.md) (always read)
- [category-patterns.md](references/category-patterns.md) (always read)
- [category-quality.md](references/category-quality.md) (always read)
- [category-structure.md](references/category-structure.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)

## Workflow

1. If target `SKILL.md` does not exist, set `Status: failed` per [references/common-output-format.md](references/common-output-format.md) and stop without running other checks. Otherwise run `bash scripts/validate_waza.sh <skill-name>` and `bash scripts/validate.sh <SKILL.md>` (CWD: `<agent-root>/skills/agent-skills-review/`).
2. Record token budget from `waza check` when present; if count > 500, add a Q-09 advisory entry to `## Issues` and do not list Q-09 in `## Checks (Failed/Deferred Only)`. Q-09 fails only when `waza check` ran but its token count is not recorded; if `validate_waza.sh` failed, defer Q-09 per step 5. A skill compressed below sibling depth is a BP-04 finding, not Q-09.
3. Apply checks in order: `BP-*` (best practices), `P-*` (workflow/policy), `Q-*` (quality language), `S-*` (structure). For Q-12, read every `references/` file and the option parsing of bundled `scripts/`; for P-04, compare shared rules with the sibling skills.
4. Report failed/deferred items with ItemIDs.
5. If one validation script fails and the other succeeds, report successful checks normally and mark unresolved checks as deferred with script name and exit status.
6. If both validation scripts fail, set `Status: failed` and include both commands, exit statuses, and stderr summaries in `## Issues`.

### Error Handling

| Condition                                       | Severity    | Action                                                                                                |
| ----------------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| Target `SKILL.md` does not exist                | Fatal       | Set `Status: failed`; stop without other checks                                                       |
| `validate_waza.sh` or `validate.sh` missing     | Fatal       | Stop; report missing script path                                                                      |
| One validation script fails, the other succeeds | Recoverable | Report successful checks; defer failed script checks with exit status                                 |
| Both validation scripts fail                    | Fatal       | Set `Status: failed` with command, exit status, and stderr summary in `## Issues`                     |
| `common-checklist.md` unavailable               | Fatal       | Stop; report missing dependency                                                                       |
| `common-output-format.md` unavailable           | Recoverable | Note missing file; emit `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues` only |
| Script output missing after one rerun           | Recoverable | Defer affected checks; include command and stderr per troubleshooting                                 |

### Examples

- Prompt: `Review SKILL.md and report only failed/deferred items`
- Result: Structured report per [references/common-output-format.md](references/common-output-format.md) (failed/deferred only).
