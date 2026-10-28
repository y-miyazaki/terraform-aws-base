---
name: github-issue-triage
description: >-
  Classify GitHub Issues, apply allowlisted triage labels, and post analysis
  or clarifying questions as Issue comments. Use in conversation when asked
  to triage an Issue (URL or number) without opening a PR. Also the L1 loop
  entry skill for Issue events. Default is API side effects (labels/comments);
  do not edit repository files unless Constraints set agent_edit_allowed true.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "0.1.5"
---

**UTILITY SKILL** — Issue triage (labels + comments), not autofix or PR creation.

## Input

- **Automation:** detect JSON in the prompt with issue facts from `detect_issue.sh`. Read `agent_edit_allowed` from `## Constraints`. When the prompt names a message directory (a line `Loop message directory: <path>`), the run is a message run: write files there instead of posting.
- **Interactive:** natural-language Issue URL or number; same label/comment rules.

## Output Specification

Session report per [common-output-format.md](references/common-output-format.md). Side effects are GitHub Issue labels and comments, not repository file edits. Interactive: applied via `gh` and `scripts/issue_comment.sh`. Message run: `message.md` (comment markdown) and optional `message_labels.json` (`{"add":[...],"remove":[...]}`) in the message directory; the platform posts the comment and applies the labels.

## Execution Scope

### USE FOR:

- Classify Issue type when confident (`bug`, `feature`, `question`, `documentation`)
- Drive label FSM (`needs-triage`, `triage:needs-info`, `triage:ready`, `triage:failed`) per [category-fsm.md](references/category-fsm.md)
- Post analysis and clarifying questions as Issue comments

### DO NOT USE FOR:

- Opening or revising PRs (github-issue-autofix / github-pr-revise)
- Firing `repository_dispatch` or starting github-issue-autofix (autofix starts only from a human action, such as adding the `autofix` label)
- Mentions / `@` triggers
- Applying labels outside `scripts/labels.json`
- Relying on AskUserQuestion — questions go to the Issue thread

## Reference Files Guide

- [category-fsm.md](references/category-fsm.md) (always read)
- [category-prompt-rules.md](references/category-prompt-rules.md) (always read)
- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-pr-body-links.md](references/category-pr-body-links.md) (read when writing an Issue comment)

## Workflow

1. Parse detect JSON (`result.issue_number`, title, body, labels, event).
2. Skip silently if detect already skipped (bot / policy).
3. Load allowlist from `scripts/labels.json`. Interactive only: ensure missing allowlisted labels exist before apply (`gh label create` only for catalog entries). Message run: do not create labels.
4. Classify when confident; if low confidence → keep/apply `needs-triage` only and ask clarifying questions on the Issue (**no question self-censorship** — see [category-prompt-rules.md](references/category-prompt-rules.md)).
5. Compute FSM transitions using [category-fsm.md](references/category-fsm.md) events (`opened`, `mark_needs_info`, `mark_ready`, `human_retriage`). Interactive: apply them via `gh issue edit` / `gh api`. Message run: do not run `gh issue edit` or any label write; write the transition (`label_fsm_next_state` output `{"add":[...],"remove":[...]}`) to `message_labels.json` in the message directory.
6. Comment per [category-prompt-rules.md](references/category-prompt-rules.md). Interactive: post via `scripts/issue_comment.sh` — `create` on each FSM transition or re-triage; `correct` only for minor edits to the latest marked bot comment. Message run: post nothing; write the comment markdown (no preamble, status line, or leading `---`) to `message.md` in the message directory — one comment per run.
7. When marking `triage:ready`, comment that a human may add `autofix` (or future assign-command) to request a draft PR — do not invoke autofix.
8. Emit session report; do not modify repository files when `agent_edit_allowed: false`.

### Error Handling

| Condition                                 | Severity    | Action                                                                   |
| ----------------------------------------- | ----------- | ------------------------------------------------------------------------ |
| Detect `status: error`                    | Fatal       | Stop; do not mutate Issue                                                |
| Unknown / non-allowlisted label requested | Recoverable | Do not apply; keep `needs-triage`                                        |
| `gh` failure                              | Recoverable | Report in session output; avoid partial unlabeled state when possible    |
| Unsafe partial failure                    | Recoverable | Apply allowlisted `triage:failed` (message run: add it to `message_labels.json`); detect skips until a human removes it |
