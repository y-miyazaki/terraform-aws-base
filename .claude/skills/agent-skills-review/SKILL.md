---
name: agent-skills-review
description: >-
  Review SKILL.md quality for Waza readiness and agent-skills-instructions compliance.
  Use when evaluating SKILL.md quality, checking compliance with skill authoring standards,
  preparing skills for release, reviewing skill PRs, or running waza readiness checks.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.6"
---

## Input

- Target: `<agent-root>/skills/*/SKILL.md`
- Evidence: `scripts/validate_waza.sh` and `scripts/validate.sh` outputs

## Output Specification

- Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).
- Include `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues`.

## Execution Scope

- Run validation scripts and parse results to assess SKILL.md quality against S-_, Q-_, P-_, and BP-_ checks.
- Check `waza check` token output; when SKILL.md exceeds 500 tokens, add Q-09 advisory in `## Issues` (not a Failed row unless sibling consistency was violated).
- Do not merge PRs or edit unrelated files.
- Do not review product runtime behavior or application business logic.

### USE FOR:

- review new SKILL drafts before release
- note token budget advisories when `waza check` exceeds 500 tokens (secondary to sibling consistency)
- fix SKILL spec compliance findings in PR reviews

### DO NOT USE FOR:

- implement product features
- debug product runtime failures unrelated to SKILL quality checks
- run benchmark content evaluations (`waza run eval.yaml`) as a substitute for compliance checks
- modify or overwrite the target SKILL.md without explicit user approval (review output only; do not write or commit changes)

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-structure.md](references/category-structure.md) (always read)
- [category-quality.md](references/category-quality.md) (always read)
- [category-patterns.md](references/category-patterns.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)

## Workflow

1. Run `bash scripts/validate_waza.sh <skill-name>` and `bash scripts/validate.sh <SKILL.md>` (CWD: `<agent-root>/skills/agent-skills-review/`).
2. Record token budget from `waza check` when present; if count > 500, add Q-09 advisory to `## Issues` (do not Fail Q-09 on count alone).
3. Apply checks in order: `S-*` (structure), `Q-*` (quality language), `P-*` (workflow/policy), `BP-*` (best-practice rules).
4. Report failed/deferred items with ItemIDs.
5. If target `SKILL.md` does not exist, return `status: failed` and stop without running other checks.
6. If one validation script fails and the other succeeds, report successful checks normally and mark unresolved checks as deferred with script name and exit status.
7. If both validation scripts fail, return `status: failed` and include both commands, exit statuses, and stderr summaries.

### Error Handling

| Condition                                       | Severity    | Action                                                                |
| ----------------------------------------------- | ----------- | --------------------------------------------------------------------- |
| Target `SKILL.md` does not exist                | Fatal       | Return `status: failed`; stop without other checks                    |
| `validate_waza.sh` or `validate.sh` missing     | Fatal       | Stop; report missing script path                                      |
| One validation script fails, the other succeeds | Recoverable | Report successful checks; defer failed script checks with exit status |
| Both validation scripts fail                    | Fatal       | Return `status: failed` with command, exit status, and stderr summary |
| `common-checklist.md` unavailable               | Fatal       | Stop; report missing dependency                                       |
| `common-output-format.md` unavailable           | Recoverable | Use inline output contract from Output Specification                  |
| Script output missing after one rerun           | Recoverable | Defer affected checks; include command and stderr per troubleshooting |

### Examples

- Prompt: `Review SKILL.md and report only failed/deferred items`.
- Output skeleton:

```markdown
## Checks Summary

- Total checks: <number>
- Passed: <count>
- Failed: <count>
- Deferred: <count>

## Checks (Failed/Deferred Only)

| ItemID | Status | Evidence | Fix |
| ------ | ------ | -------- | --- |

## Issues

1. <ItemID>: <ItemName>
   - File: <path>#L<line>
   - Problem: <specific issue>
   - Impact: <scope and severity>
   - Recommendation: <specific fix>
```
