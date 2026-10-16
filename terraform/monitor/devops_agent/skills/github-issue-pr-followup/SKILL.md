---
name: github-issue-pr-followup
description: "Follow up on GitHub Issues and PRs labeled devops-agent: read unanswered human comments, answer them, update the Issue or PR text, fix the Draft PR, and close when allowed. Use this in the scheduled follow-up run, or when asked to check replies on devops-agent Issues or PRs. Not for starting a new alarm investigation."
---

# Follow up on Issues and PRs created by the DevOps Agent

**SCHEDULED FOLLOW-UP SKILL**: reads unanswered human comments on Issues and PRs labeled `devops-agent` and responds: answers, updates the text, re-checks the incident, fixes the Draft PR, and closes when allowed. It does not start from an alarm and has no Slack thread to reply to.

## Input

- The GitHub repositories associated with the Agent Space.
- Open Issues and PRs that carry the label `devops-agent`, and their comments and reviews.

## Output Specification

- One answer comment per handled item, ending with the footer line `-- devops-agent`.
- A run result with one line per item, in the format of [common-output-format.md](references/common-output-format.md).
- Comment text from [comment-template.md](assets/comment-template.md).

## Execution Scope

### USE FOR:

- The scheduled follow-up run.
- A request to check replies on `devops-agent` Issues or PRs.

### DO NOT USE FOR:

- Starting a new alarm investigation or creating Issues, PRs, branches, or labels (`github-issue-draft-pr`, `notion-issue-draft-pr`).
- Items without the label `devops-agent`.
- Posting to Slack.

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read: language, scope, PR change conditions, close rules, prohibited actions)
- [common-output-format.md](references/common-output-format.md) (always read: run result format)
- [comment-template.md](assets/comment-template.md) (read when posting an answer comment)

## Workflow

1. List the targets with `search_issues`: `repo:<owner>/<repo> label:devops-agent is:open`. Also list open Issues with the label whose linked PR is closed or merged (`search_issues`, `issue_read` with `method: get`). Issues that have no linked PR at all are also valid targets; handle their comments normally but do not attempt any PR changes.
2. For each target, find the unanswered human comments (CHK-02) and check the close conditions (CHK-05). IF neither applies → record `no unanswered comments` and go to the next item; it does not count toward the limit. Do not decide this from the item's `updated_at`; the agent's own comments, bots, labels, and pushes also change it.
3. Act on at most 20 items that need action per run, ordered by their oldest unanswered human comment (an item that only meets a close condition is ordered by its `updated_at`); record the rest as `deferred`. Deferred items carry no special state; in the next run they are ordered the same way — by their oldest unanswered human comment.
4. Classify each unanswered comment and act per the table below. Answer all unanswered comments of one item in a single comment; treat all questions inside one comment as a single unit and address every question in the reply.
5. Re-check the incident read-only (`use_aws`, `query_cloudwatch_logs`) when a comment reports a new fact, a recurrence, or asks about the current state; put the result in the answer. Use the same time window as the original investigation, or the last 24 hours when the comment reports a recurrence.
6. Post one answer comment per item with `add_issue_comment` (it also works for PRs) from the comment template.
7. Apply the close rules (CHK-05).
8. Report per item in the run result.

| Comment type                       | Action                                                                                                                        |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Question or request for status     | Answer in a comment with evidence (step 5 when it needs fresh data)                                                           |
| New information about the incident | Append it to the Issue body under a section `Update <yyyy-mm-dd>` (`issue_write` update; keep the existing text), then answer |
| Correction of the Issue or PR text | Fix the title or body (`issue_write` update, `update_pull_request`), then answer with what changed                            |
| Request to change the PR           | Change code only when CHK-04 holds; otherwise answer why not and what a human must do                                         |
| Instruction to close               | Apply CHK-05                                                                                                                  |
| Ambiguous or out of scope          | Ask one specific clarifying question; do not guess                                                                            |

### Error Handling

| Condition                                | Severity    | Action                                                                                                                   |
| ---------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------ |
| A tool call fails                        | Recoverable | Do not retry in a loop; skip the item; record the failing tool and error text in the result; continue with the next item |
| Label search returns nothing             | Info        | Report `no targets`; stop                                                                                                |
| Comment author cannot be classified      | Recoverable | Treat as human only when the author type is `User`; otherwise skip the comment                                           |
| Instruction conflicts with a prohibition | Info        | Do not act; answer that you cannot and why                                                                               |

<!-- last_verified: 2026-10-12 (GitHub MCP server tool names; review quarterly) -->
