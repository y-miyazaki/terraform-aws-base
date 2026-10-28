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

- Starting a new alarm investigation or creating Issues, PRs, branches, or labels (`github-issue-draft-pr`).
- Items without the label `devops-agent`.
- Posting to Slack.

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read: language, scope, PR change conditions, close rules, prohibited actions)
- [common-output-format.md](references/common-output-format.md) (always read: run result format)
- [comment-template.md](assets/comment-template.md) (read when posting an answer comment)

## Memory Structure

This skill saves human operational decisions to the `suppressions` store (the custom memory store
attached to this custom agent; the managed `directives` store is read-only for custom agents), following the
same **one-file-per-alarm** convention the managed `monitors` store already uses. There
is no index file and no sub-folders: the agent finds the right memory by its `description`,
and each alarm's full history lives in a single file.

```
suppressions/
  monitors-<alarm-name>            ← one memory file per alarm (suppression + history + incidents)
```

The memory's `description` names the alarm, so an agent triaging a firing alarm matches
on the description and opens only that one file. No index, no fan-out.

**How the suppression is honored:** writing `## Suppression: ACTIVE` here makes the
investigation agent stop early on the next firing of the alarm (the triage stage does not
read this memory, so the investigation still starts). That enforcement rule lives in the
GENERIC `AGENTS.md` (incident-suppression: per-alarm memory directives). This skill is the
**writer**; the investigation agents are the **readers**. Keep the two in sync.

## Workflow

1. List the targets with `search_issues`: `repo:<owner>/<repo> label:devops-agent is:open`. Also list open Issues with the label whose linked PR is closed or merged (`search_issues`, `issue_read` with `method: get`). Issues that have no linked PR at all are also valid targets; handle their comments normally but do not attempt any PR changes.
2. For each target, find the unanswered human comments (CHK-02) and check the close conditions (CHK-05). IF neither applies → record `no unanswered comments` and go to the next item; it does not count toward the limit. Do not decide this from the item's `updated_at`; the agent's own comments, bots, labels, and pushes also change it.
3. Act on at most 20 items that need action per run, ordered by their oldest unanswered human comment (an item that only meets a close condition is ordered by its `updated_at`); record the rest as `deferred`. Deferred items carry no special state; in the next run they are ordered the same way — by their oldest unanswered human comment.
4. Classify each unanswered comment and act per the table below. Answer all unanswered comments of one item in a single comment; treat all questions inside one comment as a single unit and address every question in the reply.
5. Re-check the incident read-only (`use_aws`, `query_cloudwatch_logs`) when a comment reports a new fact, a recurrence, or asks about the current state; put the result in the answer. Use the same time window as the original investigation, or the last 24 hours when the comment reports a recurrence.
6. Post one answer comment per item with `add_issue_comment` (it also works for PRs) from the comment template.
7. Apply the close rules (CHK-05).
8. Harvest the closed items into memory (CHK-07, see "Step 8 — Closed-item harvest" below). It runs on every run, even when no open item needs action.
9. Report per item in the run result.

| Comment type                                                               | Action                                                                                                                        | Save to memory? (Step 5a)                              |
| -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| Question or request for status                                             | Answer in a comment with evidence (step 5 when it needs fresh data)                                                           | No                                                     |
| New information about the incident                                         | Append it to the Issue body under a section `Update <yyyy-mm-dd>` (`issue_write` update; keep the existing text), then answer | Yes — `note`                                           |
| Correction of root cause                                                   | Fix the title or body, then answer with what changed                                                                          | Yes — `root-cause`                                     |
| Correction of other Issue or PR text                                       | Fix the title or body (`issue_write` update, `update_pull_request`), then answer with what changed                            | No                                                     |
| Request to change the PR                                                   | Change code only when CHK-04 holds; otherwise answer why not and what a human must do                                         | No                                                     |
| Instruction to close                                                       | Apply CHK-05                                                                                                                  | Yes — `incident` entry                                 |
| Closed without a comment (a person closed it, or the linked PR was merged) | No answer comment; harvest it in step 8                                                                                       | Yes — `incident`, `root-cause`, `suppression` (step 8) |
| **Suppression instruction** (see Step 5a)                                  | **Set `## Suppression` to `ACTIVE`, save the memory, confirm in the comment, then apply CHK-05**                              | Yes — `suppression`                                    |
| **Un-suppression / resume monitoring** (see Step 5a)                       | **Set `## Suppression` to `NONE`, save the memory, confirm in the comment**                                                   | Yes — `suppression`                                    |
| Ambiguous or out of scope                                                  | Ask one specific clarifying question; do not guess                                                                            | No                                                     |

### Author identity (human vs. agent) — read before classifying

The GitHub MCP server authenticates with a Personal Access Token (PAT), so the agent's
own comments may appear under a human author identity. **Do not rely on the author name
or user type alone to tell human from agent.**

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

#### Human comment examples

Classify a comment by its meaning, not by exact wording. Typical comments and how to handle them:

| Human comment                                  | Type                                   | Memory change                                                                        |
| ---------------------------------------------- | -------------------------------------- | ------------------------------------------------------------------------------------ |
| 「magaseek 解約済みのため今後チェック不要」    | Suppression instruction                | `ACTIVE`; `suppression` bullet with the verbatim comment                             |
| 「契約終了まで監視不要。終了後は監視再開して」 | Suppression instruction                | `ACTIVE`; keep the resume condition in the verbatim bullet                           |
| 「監視再開して」「やっぱり調査して」           | Un-suppression / resume monitoring     | `NONE`; `unsuppression` bullet                                                       |
| 「修正 PR マージ済み、クローズして」           | Instruction to close (not suppression) | `## Incidents` line only                                                             |
| 「一旦様子見」                                 | Ambiguous                              | None; ask whether future firings of this alarm should be suppressed or only this one |

#### Procedure

1. `get_memory` for `monitors-<alarm-name>` in `suppressions`.
   - **Not found** → compose a new document in the format above and `create_memory` with `store: suppressions`.
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
4. Confirm in the answer comment, e.g. `メモリに保存しました: monitors-<alarm-name>（suppressions ストア）`.
5. Proceed to CHK-05 when closing.

**If no memory write tool is available, or the store is not attached:** record `memory write unavailable: suppressions`
in the run result, do not write `メモリに保存しました` in the answer comment, and tell the human in the answer comment that the
suppression was not saved.

**If the memory tool call fails:** log the error in the run result, skip the memory step,
and continue normally. Do not block the answer comment or the close on a memory failure.

### Step 8 — Closed-item harvest (CHK-07)

Steps 1–7 only see open items. An Issue that a person closes without a comment, or whose PR was
merged, never reaches Step 5a, so its root cause and conclusion would be lost. Step 8 records them.

1. List the closed items with `search_issues`: `repo:<owner>/<repo> label:devops-agent is:closed closed:>=<date 7 days before this run, YYYY-MM-DD>`.
2. Skip an item when its alarm memory already has a `## Incidents` line for this Issue number with a
   closed status (`resolved`, `cancelled`, or `suppressed`). This keeps the harvest idempotent across runs.
3. Alarm name: extract it from the Issue title as in Step 5a. When no alarm name can be extracted,
   skip the item and record `no alarm name` in the run result.
4. Read the Issue body (`issue_read` with `method: get`) and its last human comment (`issue_read` with
   `method: get_comments`). Take the root cause from a section headed `Root cause` or `根本原因` (when
   present) and the conclusion from the close reason in the last human comment or the body's conclusion section.
5. Apply Step 5a to the alarm's memory (one `get_memory` and one write per alarm):
   - A root cause was found → append a `root-cause` bullet to `## History`.
   - Set the `## Incidents` line for this Issue number: `[resolved]` for `state_reason: completed` (or a merged PR),
     `[cancelled]` for `not_planned`.
   - **Suppression conclusion** → when the conclusion contains one of 「調査不要」「誤検知」「設定変更済み」
     「対応不要」「修正不要」「今後チェック不要」「監視不要」 / "no investigation needed" / "false positive" /
     "config already changed" / "won't fix" / "no longer needed", set `## Suppression` to `ACTIVE`, append
     a `suppression` bullet with the verbatim phrase and the source Issue number, and set the Incidents line to
     `[suppressed]`. Do **not** treat "resolved" or "fix is merged" as a suppression conclusion.
6. Record the item in the run result with its alarm memory name, or with the reason it was skipped.

### Error Handling

| Condition                                | Severity    | Action                                                                                                                   |
| ---------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------ |
| A tool call fails                        | Recoverable | Do not retry in a loop; skip the item; record the failing tool and error text in the result; continue with the next item |
| Label search returns nothing             | Info        | Report `no targets`; stop                                                                                                |
| Comment author cannot be classified      | Recoverable | Use the `-- devops-agent` footer rule above; when still ambiguous, treat the comment as the agent's own and skip it      |
| Instruction conflicts with a prohibition | Info        | Do not act; answer that you cannot and why                                                                               |

<!-- last_verified: 2026-10-17 (GitHub MCP server tool names; review quarterly) -->
