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
- GitHub Issues (`github-issue-pr-followup`).
- Linear Issues without the label `devops-agent`, or Issues of another team.
- Posting to Slack.
- An Agent Space whose `AGENTS.md` has no `Linear team:` line (report `no targets (Linear team not configured)` and stop).

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read: language, scope, PR change conditions, close rules, prohibited actions)
- [common-output-format.md](references/common-output-format.md) (always read: run result format)
- [comment-template.md](assets/comment-template.md) (read when posting an answer comment)

## Memory Structure

This skill saves human operational decisions to the `directives` store, following the
same **one-file-per-alarm** convention the managed `monitors` store already uses. There
is no index file and no sub-folders: the agent finds the right memory by its `description`,
and each alarm's full history lives in a single file.

```
directives/
  monitors-<alarm-name>            ← one memory file per alarm (suppression + history + incidents)
```

The memory's `description` names the alarm, so an agent triaging a firing alarm matches
on the description and opens only that one file. No index, no fan-out.

**How the suppression is honored:** writing `## Suppression: ACTIVE` here is what makes the
triage / investigation agents skip the alarm. That enforcement rule lives in the GENERIC
`AGENTS.md` (incident-suppression: per-alarm memory directives). This skill is the **writer**;
the triage/RCA agents are the **readers**. Keep the two in sync.

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

| Comment type                              | Action                                                                                                                                                      | Save to memory? (Step 5a) |
| ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| Question or request for status            | Answer in a comment with evidence (step 6 when it needs fresh data)                                                                                         | No                        |
| New information about the incident        | Append it to the Issue description under a section `Update <yyyy-mm-dd>` (`save_issue` with `id` and `patch` `append`; keep the existing text), then answer | Yes — `note`              |
| Correction of root cause                  | Fix the title or description, then answer with what changed                                                                                                 | Yes — `root-cause`        |
| Correction of other Issue or PR text      | Fix the title or description (`save_issue` with `id`, `update_pull_request`), then answer with what changed                                                 | No                        |
| Request to change the PR                  | Change code only when CHK-04 holds; otherwise answer why not and what a human must do                                                                       | No                        |
| Instruction to close                      | Apply CHK-05                                                                                                                                                | Yes — `incident` entry    |
| **Suppression instruction** (see Step 5a) | **Set `## Suppression` to `ACTIVE`, save the memory, confirm in the comment, then apply CHK-05**                                                            | Yes — `suppression`       |
| **Un-suppression / resume monitoring** (see Step 5a) | **Set `## Suppression` to `NONE`, save the memory, confirm in the comment**                                                                      | Yes — `suppression`       |
| Ambiguous or out of scope                 | Ask one specific clarifying question; do not guess                                                                                                          | No                        |

### Author identity (human vs. agent) — read before classifying

The Linear and GitHub MCP servers authenticate with a Personal Access Token (PAT), so
the agent's own comments may appear under a human author identity. **Do not rely on the
author name or user type alone to tell human from agent.**

- The **definitive signal** that a comment was written by this agent is the footer line
  `-- devops-agent` at the end of the comment body. **Skip any comment ending with
  `-- devops-agent`** — it is the agent's own, never a human comment to answer.
- A comment with no `-- devops-agent` footer is treated as a human comment.
- When in doubt (e.g. a footer is present but malformed), treat the comment as the agent's
  own and skip it, to avoid the agent answering itself in a loop.

### Step 5a — Memory save workflow (one file per alarm)

**Extract the alarm name** from the Issue title: the string after the environment prefix
(`[prd]`/`[stg]`/`[dev]`) and before the first `:`. Convert to lowercase kebab-case
(replace spaces and `/` with `-`). The memory name is `monitors-<alarm-name>`.

All information for one alarm lives in that single memory file. Read it once with
`get_memory`, update the relevant section(s), and write it back once — a single
`create_memory` (first time) or `update_memory` (thereafter) per run per alarm.

#### Memory document format

The body is **append-only** — add new bullets to the relevant section; never overwrite or
remove prior bullets, so the full history of a recurring alarm is preserved. The one
exception is the `## Suppression` state line, which is a single current value (`ACTIVE` or
`NONE`) that you overwrite — but every change to it must also leave a `## History` bullet,
so the state transitions remain auditable.

```
---
name: monitors-<alarm-name>
description: "<alarm-name> の対応方針・抑制状態・履歴。<alarm-name> のトリアージ・調査時に読む。"
---

## Suppression

<ACTIVE | NONE>  ← ACTIVE のときは「インシデント登録・調査・Issue/PR 作成をしない」

## History
- <yyyy-mm-dd> | <IssueID> | <commenter> | suppression   | "<verbatim instruction>"
- <yyyy-mm-dd> | <IssueID> | <commenter> | unsuppression | "<verbatim instruction>"
- <yyyy-mm-dd> | <IssueID> | <commenter> | root-cause    | <correction text>
- <yyyy-mm-dd> | <IssueID> | <commenter> | note          | <note text>

## Incidents
- <IssueID>: <one-line summary> (<yyyy-mm-dd>) [<suppressed|resolved|cancelled|open>]
```

#### Procedure

1. `get_memory` for `monitors-<alarm-name>` in `directives`.
   - **Not found** → compose a new document in the format above and `create_memory` with `store: directives`.
   - **Found** → edit the retrieved document in place, preserving all existing bullets.
2. Apply the change for the comment type:
   - **Suppression instruction** — set `## Suppression` to `ACTIVE` and append a `suppression` bullet to `## History`.
     Trigger phrases (any language): 「今後チェック不要」「監視不要」「解約済み」「対応不要」 / "won't fix" /
     "false positive" / "no longer needed" / "contract cancelled" / "decommissioned" — or any equivalent stating
     future occurrences should be ignored. Do **not** trigger on "fix is merged" / "resolved" (normal close).
   - **Un-suppression / resume monitoring** — set `## Suppression` to `NONE`, append an `unsuppression` bullet to
     `## History`, and update any `## Incidents` line previously marked `[suppressed]` for this alarm to `[open]`
     so the incident status reflects that monitoring resumed. Trigger phrases (any language): 「監視再開」「抑制解除」
     「やっぱり調査して」「再開」 / "resume monitoring" / "re-enable" / "unsuppress" / "start investigating again" — or
     any equivalent reversing a prior suppression. When no memory exists yet, treat as a no-op (nothing to
     un-suppress) and just answer.
   - **Root-cause correction** — append a `root-cause` bullet to `## History`.
   - **New information / recurrence / note** — append a `note` bullet to `## History`.
   - **On close (any reason)** — append or update the matching line under `## Incidents` (if a line for this
     Issue ID already exists, update its status rather than adding a duplicate).
3. `update_memory` (or `create_memory` if it was new) — one write per alarm.
4. Confirm in the answer comment, e.g. `メモリに保存しました: monitors-<alarm-name>（directives ストア）`.
5. Proceed to CHK-05 when closing.

**If the memory tool call fails:** log the error in the run result, skip the memory step,
and continue normally. Do not block the answer comment or the close on a memory failure.

### Error Handling

| Condition                                | Severity    | Action                                                                                                                   |
| ---------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------ |
| A tool call fails                        | Recoverable | Do not retry in a loop; skip the item; record the failing tool and error text in the result; continue with the next item |
| Label search returns nothing             | Info        | Report `no targets`; stop                                                                                                |
| `Linear team:` missing or team not found | Recoverable | Report `no targets (<reason>)`; never search another team; stop                                                          |
| Comment author cannot be classified      | Recoverable | Use the `-- devops-agent` footer rule above; when still ambiguous, treat the comment as the agent's own and skip it      |
| Instruction conflicts with a prohibition | Info        | Do not act; answer that you cannot and why                                                                               |

<!-- last_verified: 2026-10-17 (Linear and GitHub MCP server tool names; review quarterly) -->
