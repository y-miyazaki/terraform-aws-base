---
name: github-pr-revise
description: >-
  Apply human PR review feedback to a pull request. Use in conversation when
  the user gives a PR URL or number plus the feedback to apply. Also the L2
  loop entry skill on PR heads when detect finds a configured mention
  (@loop). Interactive default is survey; apply when the user explicitly
  requests apply or may_edit is true. Do not invent mention-less automation
  triggers or act on bot comments.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "0.1.2"
---

**UTILITY SKILL** — PR revise from mention-gated human feedback (branch / PR-head caller).

## Input

- **Automation:** detect JSON from `detect_pr_revise.sh` with `result.pr_number`, trigger comment fields, and `result.comments` (array of open human `@mention` comments with `comment_id`, `body`, `path`, `line`, `start_line`, `side`, `diff_hunk`, `in_reply_to_id`, `source`, `subject_type`). Read `may_edit` / `write_target` from `## Constraints`. Address the full `comments` array — not only `comment_body`.
- **Interactive:** PR URL or number plus the human feedback to apply; same Constraints defaults as automation survey unless the user explicitly requests apply.

## Output Specification

Report per [common-output-format.md](references/common-output-format.md). Automation envelope: [category-automation-envelope.md](references/category-automation-envelope.md).

## Execution Scope

### USE FOR:

- Apply the human's mention-gated feedback to the PR head (or stacked branch when landing is `open_pr`)
- Synthesize PR body / session report from skill templates

### DO NOT USE FOR:

- Issue triage or github-issue-autofix
- Acting on bot comments or mention-less comments

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-automation-envelope.md](references/category-automation-envelope.md) (read on automation path)
- [category-pr-body-links.md](references/category-pr-body-links.md) (read when synthesizing PR body)
- `assets/pr-body-template.md` (read when synthesizing apply PR body)
- `assets/pr-body-template-survey.md` (read when synthesizing survey PR body)

## Workflow

Resolve **may_edit** before revising:

| Source                                | `may_edit`                                                                                                               |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Interactive — default                 | `false` — survey only; do not edit files                                                                                 |
| Interactive — explicit apply language | `true` — user asks to apply/revise in the same request                                                                   |
| Automation — `## Constraints`         | `may_edit: true` or `may_edit: false` from [category-automation-envelope.md](references/category-automation-envelope.md) |

When `may_edit` is `true`, resolve `write_target`: on the **interactive** path use `fix` (this skill); on the **automation** path read `write_target` from `## Constraints`. Do not branch on other caller metadata outside `## Constraints`.

1. Read detect JSON; if `skip: true`, report and stop.
2. On the automation path, read [category-automation-envelope.md](references/category-automation-envelope.md) for Constraints and PR templates.
3. IF `may_edit` is `false` → emit survey shape; load `assets/pr-body-template-survey.md` at synthesis when on automation path; stop.
4. ELSE IF `may_edit` is `true` AND `write_target` is not `fix` → emit survey shape; note expected `write_target: fix`; stop.
5. ELSE IF `may_edit` is `true` AND `write_target` is `fix` → apply the requested revision on the PR head worktree.
6. At synthesis, load the apply PR template.
7. Do not invent triggers beyond the configured mention / explicit dispatch.

### Error Handling

| Condition                                    | Severity    | Action                                       |
| -------------------------------------------- | ----------- | -------------------------------------------- |
| Detect `status: error`                       | Fatal       | Stop; do not mutate repository files         |
| Detect `skip: true`                          | Info        | Report skip reason; do not push              |
| `may_edit: false`                            | Info        | Survey only; do not edit files               |
| `write_target` not `fix` when edits expected | Recoverable | Survey only; note mismatch in Overview       |
| Validation tooling missing after edits       | Recoverable | Defer in report; do not claim passing checks |
