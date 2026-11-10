---
name: github-issue-autofix
description: >-
  Implement a GitHub Issue fix on a branch and open a PR (Fixes #N). Use in
  conversation when the user gives an Issue number or URL and asks to
  implement or fix it. Also the L2 loop entry skill after autofix label,
  repository_dispatch, or workflow_dispatch. Interactive default is survey
  only; implement the fix when the request asks for changes to be made (for
  example fix, apply, or update) or automation sets agent_edit_allowed in
  Constraints. Detect skips when an open/draft PR already closes the Issue.
  Agent must not fire repository_dispatch.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "0.1.2"
---

**UTILITY SKILL** — Issue→PR autofix on the branch caller (not entity observe).

## Input

- **Automation:** detect JSON from `detect_autofix.sh` with `result.issue_number`. Read `agent_edit_allowed` / `agent_edit_target` from `## Constraints`.
- **Interactive:** Issue number (or URL resolved to a number) plus optional failure context; there is no detect JSON. Read the Issue with read-only `gh issue view <n> --json number,title,body,state,labels,comments`. `agent_edit_allowed` follows the edit gate in Workflow: survey unless the request asks for changes to be made.

## Output Specification

Report per [common-output-format.md](references/common-output-format.md). On the automation path, follow [category-automation-envelope.md](references/category-automation-envelope.md). Apply shape: PR body includes the literal `Fixes #<N>`. Survey shape: reference the Issue as `Refs #<N>` and never use a closing keyword (`Fixes`, `Closes`, `Resolves`) — merging a survey PR must not close the Issue.

## Execution Scope

### USE FOR:

- Implement a minimal fix for the Issue on the integration branch worktree when `agent_edit_allowed: true`
- Synthesize PR body from `assets/pr-body-template.md` including `Fixes #<N>`

### DO NOT USE FOR:

- Issue triage labels/comments (github-issue-triage)
- PR revision from review comments (github-pr-revise)
- Calling `repository_dispatch` from the Agent

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-automation-envelope.md](references/category-automation-envelope.md) (read on automation path)
- [category-pr-body-links.md](references/category-pr-body-links.md) (read when synthesizing PR body)
- `assets/pr-body-template.md` (read when synthesizing apply PR body)
- `assets/pr-body-template-survey.md` (read when synthesizing survey PR body)

## Workflow

Resolve **agent_edit_allowed** before implementing:

| Source                                                                                                          | `agent_edit_allowed`                                                                                                                         |
| --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Interactive — default: the request asks to look, check, triage, or survey, or only names the skill              | `false` — survey only; do not edit files                                                                                                     |
| Interactive — the request asks for changes to be made (for example fix, apply, 修正して, 適用して, update, add) | `true` — implement the fix for the Issue                                                                                                     |
| Interactive — follow-up after a survey asking to apply                                                          | `true` — implement the surveyed fix candidates                                                                                               |
| Automation — `## Constraints`                                                                                   | `agent_edit_allowed: true` or `agent_edit_allowed: false` from [category-automation-envelope.md](references/category-automation-envelope.md) |

When intent is unclear, survey and offer to apply — edits are harder to undo than a report.

When `agent_edit_allowed` is `true`, resolve `agent_edit_target`: on the **interactive** path use `fix` (this skill); on the **automation** path read `agent_edit_target` from `## Constraints`. Do not branch on other caller metadata outside `## Constraints`.

**Delivery.** Interactive: leave edits in the working tree and report them; commit, push, or open a PR only when the user explicitly asks for that step, because those change shared state that other people see and cannot be quietly taken back. Automation: do not push or open a PR yourself; the caller delivers the branch and composes the PR body from your report.

1. Automation: read detect JSON; if `skip: true` or `status: error`, report the reason and stop. Interactive: resolve the Issue from the user's URL or number with `gh issue view`; if the Issue is closed, report that and stop. Check for an open or draft PR that already closes the Issue (for example `gh pr list --state open --search "<n> in:body"` and confirm a closing keyword for `#<n>` in its body); if one exists, report it as a skip and stop — same as the detect skip.
2. On the automation path, read [category-automation-envelope.md](references/category-automation-envelope.md) for Constraints and PR templates.
3. IF `agent_edit_allowed` is `false` → emit survey shape; load `assets/pr-body-template-survey.md` at synthesis when on automation path; stop.
4. ELSE IF `agent_edit_allowed` is `true` AND `agent_edit_target` is not `fix` → emit survey shape; note expected `agent_edit_target: fix`; stop.
5. ELSE IF `agent_edit_allowed` is `true` AND `agent_edit_target` is `fix` → implement the minimal fix for Issue `#N` on the worktree.
6. At synthesis, load the apply PR template; ensure body includes `Fixes #<N>` (interactive: the body is written for a PR the user asks you to open, or reported in chat).
7. Do **not** fire `repository_dispatch` or start other loops from the Agent.

### Error Handling

| Condition                                                 | Severity    | Action                                                          |
| --------------------------------------------------------- | ----------- | --------------------------------------------------------------- |
| Detect `status: error`                                    | Fatal       | Stop; do not mutate repository files                            |
| Detect `skip: true`                                       | Info        | Report skip reason; do not open a PR                            |
| Interactive: Issue is closed                              | Info        | Report that the Issue is closed; do not edit files or open a PR |
| Interactive: an open or draft PR already closes the Issue | Info        | Report it as a skip with the PR number; do not open another PR  |
| `agent_edit_allowed: false`                               | Info        | Survey only; do not edit files                                  |
| `agent_edit_target` not `fix` when edits expected         | Recoverable | Survey only; note mismatch in Overview                          |
| Validation tooling missing after edits                    | Recoverable | Defer in report; do not claim passing checks                    |
