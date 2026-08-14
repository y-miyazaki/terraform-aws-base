# Issue triage prompt rules

## Classification confidence

- Apply a type label (`bug`, `feature`, `question`, `documentation`) only when confident.
- Otherwise keep or apply `needs-triage` only and ask for the missing facts.

## Questions (no self-censorship)

- Put clarifying questions in **Issue comments**.
- Do **not** suppress, soften, or skip questions because they seem basic, repetitive, or “obvious.”
- Do **not** rely on AskUserQuestion or chat-only prompts for automation runs.
- Prefer a short numbered list of concrete questions over vague “please provide more info.”

## Comment history (new vs update)

Post comments only through `scripts/issue_comment.sh` (do not `gh api` PATCH Issue comments directly). Use `create` on each FSM transition and on each re-triage after a human reply. Do **not** overwrite prior triage analysis so the thread keeps an audit trail.

| Situation                                                                | Action                                                                          |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| First triage (`opened` / `reopened`)                                     | `scripts/issue_comment.sh create` (classification, analysis, questions)         |
| Transition to `triage:needs-info`                                        | `scripts/issue_comment.sh create` with the question list                        |
| Human reply while `triage:needs-info` (re-triage)                        | `scripts/issue_comment.sh create` citing the new facts and the updated decision |
| Transition to `triage:ready`                                             | `scripts/issue_comment.sh create` (ready rationale + autofix guidance)          |
| `human_retriage` or `triage:failed`                                      | `scripts/issue_comment.sh create` stating the new state                         |
| Same FSM state; only typo or wording fixes on the **latest bot** comment | `scripts/issue_comment.sh correct`                                              |

Do not collapse multiple FSM transitions into one edited comment. Do not update a human comment.

## Ready guidance

When applying `triage:ready`, tell the human how to request a draft autofix PR later (`autofix` label or future assign-command). Do not start github-issue-autofix yourself.

## Side effects

- Use `gh` for labels and comments.
- Only allowlisted labels from `scripts/labels.json`.
- No repository file edits when Constraints say `may_edit: false`.
- Mentions / `@` triggers are out of scope.
