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

- Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).
- Include `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues`.

## Execution Scope

- Run validation scripts and parse results to assess SKILL.md quality against S-_, Q-_, P-_, and BP-_ checks.
- Check `waza check` token output; report as warning if SKILL.md exceeds 500 tokens.
- Do not merge PRs or edit unrelated files.
- Do not review product runtime behavior or application business logic.

### USE FOR:

- review new SKILL drafts before release
- reduce `waza check` token count when SKILL.md exceeds 500 tokens
- fix SKILL spec compliance findings in PR reviews

### DO NOT USE FOR:

- implement product features
- debug product runtime failures unrelated to SKILL quality checks
- run benchmark content evaluations (`waza run eval.yaml`) as a substitute for compliance checks
- modify or overwrite the target SKILL.md without explicit user approval (review output only; do not write or commit changes)

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-structure.md](references/category-structure.md) - Read when checking required section structure (S-\* checks).
- [category-quality.md](references/category-quality.md) - Read when evaluating quality language (Q-\* checks).
- [category-patterns.md](references/category-patterns.md) - Read when reviewing workflow and policy patterns (P-\* checks).
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read on script failure or missing output

## Workflow

1. Run `bash scripts/validate_waza.sh <skill-name>` and `bash scripts/validate.sh <SKILL.md>` (CWD: `<agent-root>/skills/agent-skills-review/`).
2. Check token warning threshold: Token count > 500 (warning).
3. Apply checks in order: `S-*` (structure), `Q-*` (quality language), `P-*` (workflow/policy), `BP-*` (best-practice rules).
4. Report failed/deferred items with ItemIDs.
5. If target `SKILL.md` does not exist, return `status: failed` and stop without running other checks.
6. If one validation script fails and the other succeeds, report successful checks normally and mark unresolved checks as deferred with script name and exit status.
7. If both validation scripts fail, return `status: failed` and include both commands, exit statuses, and stderr summaries.

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

