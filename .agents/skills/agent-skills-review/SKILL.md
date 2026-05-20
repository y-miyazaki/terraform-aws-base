---
name: agent-skills-review
description: >-
  Review SKILL.md quality for Waza readiness and agent-skills-instructions compliance in final release checks.
  Use when creating skills, reviewing skill PRs, or fixing waza check findings.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Target: `<agent-root>/skills/*/SKILL.md`
- Evidence: `scripts/validate_waza.sh` and `scripts/validate.sh` outputs

## Output Specification

- Return structured Markdown with `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues`.
- Use [references/common-output-format.md](references/common-output-format.md) as the field-level contract.

## Execution Scope

- Review required sections, section order, output-contract consistency, and ambiguity violations.
- Run `scripts/validate_waza.sh` and `scripts/validate.sh` from the target skill directory.
- Treat `waza check` Token Budget <= 500 as a warning threshold.
- Do not merge PRs or edit unrelated files.
- Do not review product runtime behavior or application business logic.

### USE FOR:

- review new SKILL drafts before release
- reduce `waza check` token warnings when feasible (`Token Budget > 500`)
- fix SKILL spec compliance findings in PR reviews

### DO NOT USE FOR:

- implement product features
- debug product runtime failures unrelated to SKILL quality checks
- run benchmark content evaluations (`waza run eval.yaml`) as a substitute for compliance checks

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-structure.md](references/category-structure.md) - Read for structure.
- [category-quality.md](references/category-quality.md) - Read for quality.
- [category-patterns.md](references/category-patterns.md) - Read for workflow.

## Workflow

1. Run `bash scripts/validate_waza.sh <skill-name>` and `bash scripts/validate.sh <SKILL.md>` from `./<agent-root>/skills/agent-skills-review/`.
2. Check token warning threshold: Token Budget <= 500 (warning if exceeded).
3. Apply checks in order: `S-*` (structure), `Q-*` (quality language), `P-*` (workflow/policy), `BP-*` (best-practice rules).
4. Report failed/deferred items with ItemIDs.
5. If target `SKILL.md` does not exist, return `status: failed` and stop without running other checks.
6. If one validation script fails and the other succeeds, report successful checks normally and mark unresolved checks as deferred with script name and exit status.
7. If both validation scripts fail, return `status: failed` and include both commands, exit statuses, and stderr summaries.

### Examples

- Prompt: `Review SKILL.md and report only failed/deferred items`.
- Output skeleton:

```markdown
Checks Summary:

- Passed: <count>
- Failed: <count>
- Deferred: <count>

Checks (Failed/Deferred Only):
| ItemID | Status | Evidence | Fix |
|---|---|---|---|

Issues:

- <issue summary>
```

## Error Handling and Troubleshooting

- If script output is missing, rerun once.
- If rerun still fails, defer affected checks and include command, exit status, and stderr summary.
- If only one script fails, do not block reporting from the successful script.

## Best Practices

- Prioritize clarity and determinism over token-only reductions.
- Prioritize `S-*` and `Q-*` failures before style-only `BP-*` findings.
