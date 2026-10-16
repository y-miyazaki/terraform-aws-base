---
name: linear-issue-pr-followup
description: "Follow up on unanswered human comments on Linear Issues and their GitHub PRs labeled devops-agent: answer, update the text, re-check the incident, fix the Draft PR, and close when allowed. Use this in the scheduled follow-up run. Do not use it to start an investigation or to create Issues, PRs or labels."
---

# Follow up on Linear Issues and PRs created by the DevOps Agent

**SCHEDULED FOLLOW-UP SKILL**: reads unanswered human comments on Linear Issues labeled `devops-agent` and on the GitHub PRs linked from them, and responds: answers, updates the text, re-checks the incident, fixes the Draft PR, and closes when allowed. It does not start from an alarm and has no Slack thread to reply to. It requires the Linear MCP server and the GitHub MCP server to be connected to the Agent Space.

## Input

- The Linear team named by the line `Linear team: <team>` in `AGENTS.md` (set per Agent Space in tfvars `agent_spaces.<name>.linear.team`).
- Open Linear Issues of that team that carry the label `devops-agent`, and their comments.
- The GitHub PRs linked from those Issues (the `Pull request` section), their comments and reviews, and the GitHub repositories associated with the Agent Space.

## Output Specification

- One answer comment per handled Issue or PR, ending with the footer line `-- devops-agent`.
- A run result with one line per item, in the format of [common-output-format.md](references/common-output-format.md).
- Comment text from [comment-template.md](assets/comment-template.md).

## Execution Scope

### USE FOR:

- The scheduled follow-up run.
- A request to check replies on `devops-agent` Linear Issues or their PRs.

### DO NOT USE FOR:

- Starting a new alarm investigation or creating Issues, PRs, branches, or labels (`linear-issue-draft-pr`).
- GitHub Issues (`github-issue-pr-followup`) or Notion pages.
- Linear Issues without the label `devops-agent`, or Issues of another team.
- Posting to Slack.
- An Agent Space whose `AGENTS.md` has no `Linear team:` line (report `no targets (Linear team not configured)` and stop).

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read: language, scope, PR change conditions, close rules, prohibited actions)
- [common-output-format.md](references/common-output-format.md) (always read: run result format)
- [comment-template.md](assets/comment-template.md) (read when posting an answer comment)

## Workflow

1. Resolve the team (CHK-01): read `Linear team:` from `AGENTS.md` and confirm it exists with `list_teams`. IF it is missing or does not exist → report it and stop.
2. List the targets with `list_issues` (`team`, `label: devops-agent`, `state` of type `unstarted` or `started`, `fields` including `url`, `status`, `updatedAt`, `description`); page with `cursor` until all are read. Also list Issues with the label whose linked PR is closed or merged (read the PR URL from the `Pull request` section and `pull_request_read`). Issues that have no linked PR at all are also valid targets; handle their comments normally but do not attempt any PR changes.
3. For each target, find the unanswered human comments (CHK-02: `list_comments` for the Issue, `pull_request_read` for the PR) and check the close conditions (CHK-05). IF neither applies → record `no unanswered comments` and go to the next item; it does not count toward the limit. Do not decide this from the item's `updatedAt`; the agent's own comments, bots, labels, and pushes also change it.
4. Act on at most 20 items that need action per run, ordered by their oldest unanswered human comment (an item that only meets a close condition is ordered by its `updatedAt`); record the rest as `deferred`. Deferred items carry no special state; in the next run they are ordered the same way — by their oldest unanswered human comment.
5. Classify each unanswered comment and act per the table below. Answer all unanswered comments of one item in a single comment; treat all questions inside one comment as a single unit and address every question in the reply.
6. Re-check the incident read-only (`use_aws`, `query_cloudwatch_logs`) when a comment reports a new fact, a recurrence, or asks about the current state; put the result in the answer. Use the same time window as the original investigation, or the last 24 hours when the comment reports a recurrence.
7. Post one answer comment per item from the comment template: `save_comment` with `issueId` for a Linear Issue (reply in the thread with `parentId` when the comment is part of a thread), `add_issue_comment` for a GitHub PR.
8. Apply the close rules (CHK-05).
9. Report per item in the run result.

| Comment type                       | Action                                                                                                                                                      |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Question or request for status     | Answer in a comment with evidence (step 6 when it needs fresh data)                                                                                         |
| New information about the incident | Append it to the Issue description under a section `Update <yyyy-mm-dd>` (`save_issue` with `id` and `patch` `append`; keep the existing text), then answer |
| Correction of the Issue or PR text | Fix the title or description (`save_issue` with `id`, `update_pull_request`), then answer with what changed                                                 |
| Request to change the PR           | Change code only when CHK-04 holds; otherwise answer why not and what a human must do                                                                       |
| Instruction to close               | Apply CHK-05                                                                                                                                                |
| Ambiguous or out of scope          | Ask one specific clarifying question; do not guess                                                                                                          |

### Error Handling

| Condition                                | Severity    | Action                                                                                                                   |
| ---------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------ |
| A tool call fails                        | Recoverable | Do not retry in a loop; skip the item; record the failing tool and error text in the result; continue with the next item |
| Label search returns nothing             | Info        | Report `no targets`; stop                                                                                                |
| `Linear team:` missing or team not found | Recoverable | Report `no targets (<reason>)`; never search another team; stop                                                          |
| Comment author cannot be classified      | Recoverable | Treat as human only when the author is a person (not a bot, app, or integration user); otherwise skip the comment        |
| Instruction conflicts with a prohibition | Info        | Do not act; answer that you cannot and why                                                                               |

<!-- last_verified: 2026-10-13 (Linear and GitHub MCP server tool names; review quarterly) -->
