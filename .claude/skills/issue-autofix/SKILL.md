---
name: issue-autofix
description: >-
  Implement an Issue fix on a branch and open a PR (Fixes #N). Use for L2
  issue-autofix automation after autofix label, repository_dispatch, or
  workflow_dispatch. Detect skips when an open/draft PR already closes the
  Issue. Do not fire repository_dispatch from the Agent.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "0.1.0"
---

**UTILITY SKILL** — Issue→PR autofix on the branch caller (not entity observe).

## Input

- **Automation:** detect JSON from `detect_autofix.sh` with `result.issue_number`. Read `may_edit` / `write_target` from `## Constraints`.
- **Interactive:** Issue number (or URL resolved to a number) plus optional failure context; same Constraints defaults as automation survey unless the user explicitly requests a fix.

## Output Specification

Report per [common-output-format.md](references/common-output-format.md). On the automation path, follow [category-automation-envelope.md](references/category-automation-envelope.md). PR body must include `Fixes #<N>`.

## Execution Scope

### USE FOR:

- Implement a minimal fix for the Issue on the integration branch worktree when `may_edit: true`
- Synthesize PR body from `assets/pr-body-template.md` including `Fixes #<N>`

### DO NOT USE FOR:

- Issue triage labels/comments (issue-triage)
- PR revision from review comments (pr-revise)
- Calling `repository_dispatch` from the Agent

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-automation-envelope.md](references/category-automation-envelope.md) (read on automation path)
- [category-pr-body-links.md](references/category-pr-body-links.md) (read when synthesizing PR body)
- `assets/pr-body-template.md` (read when synthesizing apply PR body)
- `assets/pr-body-template-survey.md` (read when synthesizing survey PR body)

## Workflow

Resolve **may_edit** before implementing:

| Source | `may_edit` |
| --- | --- |
| Interactive — default | `false` — survey only; do not edit files |
| Interactive — explicit fix language | `true` — user asks to implement/fix the Issue in the same request |
| Automation — `## Constraints` | `may_edit: true` or `may_edit: false` from [category-automation-envelope.md](references/category-automation-envelope.md) |

When `may_edit` is `true`, resolve `write_target`: on the **interactive** path use `fix` (this skill); on the **automation** path read `write_target` from `## Constraints`. Do not branch on other caller metadata outside `## Constraints`.

1. Read detect JSON; if `skip: true`, report skip reason and stop.
2. On the automation path, read [category-automation-envelope.md](references/category-automation-envelope.md) for Constraints and PR templates.
3. IF `may_edit` is `false` → emit survey shape; load `assets/pr-body-template-survey.md` at synthesis when on automation path; stop.
4. ELSE IF `may_edit` is `true` AND `write_target` is not `fix` → emit survey shape; note expected `write_target: fix`; stop.
5. ELSE IF `may_edit` is `true` AND `write_target` is `fix` → implement the minimal fix for Issue `#N` on the worktree.
6. At synthesis, load the apply PR template; ensure body includes `Fixes #<N>`.
7. Do **not** fire `repository_dispatch` or start other loops from the Agent.

### Error Handling

| Condition | Severity | Action |
| --- | --- | --- |
| Detect `status: error` | Fatal | Stop; do not mutate repository files |
| Detect `skip: true` | Info | Report skip reason; do not open a PR |
| `may_edit: false` | Info | Survey only; do not edit files |
| `write_target` not `fix` when edits expected | Recoverable | Survey only; note mismatch in Overview |
| Validation tooling missing after edits | Recoverable | Defer in report; do not claim passing checks |
