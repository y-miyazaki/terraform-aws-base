---
name: github-issue-triage
description: >-
  Classify GitHub Issues, apply allowlisted triage labels, and post analysis
  or clarifying questions as Issue comments. Use in conversation when asked
  to triage an Issue (URL or number) without opening a PR. Also the L1 loop
  entry skill for Issue events. Default is API side effects (labels/comments);
  do not edit repository files unless Constraints set may_edit true.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "0.1.4"
---

**UTILITY SKILL** — Issue triage (labels + comments), not autofix or PR creation.

## Input

- **Automation:** detect JSON in the prompt with issue facts from `detect_issue.sh`. Read `may_edit` from `## Constraints`.
- **Interactive:** natural-language Issue URL or number; same label/comment rules.

## Output Specification

Session report per [common-output-format.md](references/common-output-format.md). Side effects are GitHub Issue labels and comments via `gh`, not repository file edits.

## Execution Scope

### USE FOR:

- Classify Issue type when confident (`bug`, `feature`, `question`, `documentation`)
- Drive label FSM (`needs-triage`, `triage:needs-info`, `triage:ready`, `triage:failed`) per [category-fsm.md](references/category-fsm.md)
- Post analysis and clarifying questions as Issue comments
- On `triage:ready` with human `autofix` label, detect may request dispatch; **Agent must not** HTTP-dispatch or run autofix

### DO NOT USE FOR:

- Opening or revising PRs (github-issue-autofix / github-pr-revise)
- Firing `repository_dispatch` or starting github-issue-autofix from the Agent (trusted detect hook only)
- Mentions / `@` triggers
- Applying labels outside `scripts/labels.json`
- Relying on AskUserQuestion — questions go to the Issue thread

## Reference Files Guide

- [category-fsm.md](references/category-fsm.md) (always read)
- [category-prompt-rules.md](references/category-prompt-rules.md) (always read)
- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)

## Workflow

1. Parse detect JSON (`result.issue_number`, title, body, labels, event).
2. Skip silently if detect already skipped (bot / policy).
3. Load allowlist from `scripts/labels.json`. Ensure missing allowlisted labels exist before apply (`gh label create` only for catalog entries).
4. Classify when confident; if low confidence → keep/apply `needs-triage` only and ask clarifying questions on the Issue (**no question self-censorship** — see [category-prompt-rules.md](references/category-prompt-rules.md)).
5. Apply FSM transitions via `gh issue edit` / `gh api` using [category-fsm.md](references/category-fsm.md) events (`opened`, `mark_needs_info`, `mark_ready`, `human_retriage`).
6. Post Issue comments via `scripts/issue_comment.sh` per [category-prompt-rules.md](references/category-prompt-rules.md): `create` on each FSM transition or re-triage; `correct` only for minor edits to the latest marked bot comment.
7. When marking `triage:ready`, comment that a human may add `autofix` (or future assign-command) to request a draft PR — do not invoke autofix.
8. Emit session report; do not modify repository files when `may_edit: false`.

### Error Handling

| Condition                                 | Severity    | Action                                                                   |
| ----------------------------------------- | ----------- | ------------------------------------------------------------------------ |
| Detect `status: error`                    | Fatal       | Stop; do not mutate Issue                                                |
| Unknown / non-allowlisted label requested | Recoverable | Do not apply; keep `needs-triage`                                        |
| `gh` failure                              | Recoverable | Report in session output; avoid partial unlabeled state when possible    |
| Unsafe partial failure                    | Recoverable | Apply allowlisted `triage:failed`; detect skips until a human removes it |
