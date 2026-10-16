---
name: linear-issue-draft-pr
description: "Record an alarm investigation as a Linear Issue labeled devops-agent and, for a small confirmed fix, a GitHub Draft PR labeled devops-agent (to the repository default branch). Use this when an investigation of a CloudWatch alarm or incident finds a root cause and the team tracks incidents in Linear. It also replies to the Slack alert thread. Do not use it together with another tracker skill for the same alarm."
---

# Linear Issue and Draft PR from an alarm investigation

**ALARM FOLLOW-UP SKILL**: records a root cause as a Linear Issue, proposes a small safe fix as a GitHub Draft PR linked from the Issue, and reports to the Slack alert thread. Run it also after a mitigation proposal, because it owns the record and the Slack replies. It requires the Linear MCP server and the GitHub MCP server to be connected to the Agent Space.

## Input

- The incident (title, description, priority, incident ID) of the current investigation. The description may end with a `slack_reply_target:` line.
- The Linear team named by the line `Linear team: <team>` in `AGENTS.md` (set per Agent Space in tfvars `agent_spaces.<name>.linear.team`).
- The GitHub repositories associated with the Agent Space.

## Output Specification

- A Linear Issue labeled `devops-agent` and, when allowed, a GitHub Draft PR labeled `devops-agent`.
- Slack reply A (start), reply B (final), and reply C only for a human escalation, and the investigation result, in the formats of [common-output-format.md](references/common-output-format.md).
- Issue and PR text from [issue-body-template.md](assets/issue-body-template.md) and [pr-body-template.md](assets/pr-body-template.md).
- The Linear Issue, the PR, reply B, and the investigation result identify the repository (`<owner>/<repo>`) and label files as `<owner>/<repo>:<path>`, as links where possible (rules: CHK-03 in the checklist, rows Repository and File in the output format).

## Execution Scope

### USE FOR:

- An alarm or incident investigation that finds a root cause, when the team tracks incidents in Linear.
- A request to record an investigated problem in Linear and propose a Draft PR.

### DO NOT USE FOR:

- Chat questions, status checks, or investigations without an actionable root cause (create nothing; send reply B with `No action`).
- Replying to comments on existing Issues and PRs (`linear-issue-pr-followup`).
- Tracking incidents as GitHub Issues (`github-issue-draft-pr`) or Notion pages (`notion-issue-draft-pr`). Never run two tracker skills for the same alarm; if several are loaded, use this skill only when it is the one the team configured for this Agent Space, otherwise stop and report the conflict.
- Resources not defined in an associated repository (record the Linear Issue only and say why).
- An Agent Space whose `AGENTS.md` has no `Linear team:` line (create nothing in Linear; say so in reply B with `Failed`).

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read: language, team, branches, label, when to open a PR, prohibited actions)
- [common-output-format.md](references/common-output-format.md) (always read: link format, Slack reply A and B)
- [issue-body-template.md](assets/issue-body-template.md) (read when creating or updating the Issue)
- [pr-body-template.md](assets/pr-body-template.md) (read when opening the PR)

## Delegation

Roles when the investigation lead delegates to a sub-agent (for example the mitigation sub-agent):

- The investigation lead sends reply A itself at the start. Before it finishes it checks that reply B was sent: the lead cannot read Slack, so it relies on the `ok` and `ts` the sub-agent reports, and it checks the Issue and PR itself with the read tools.
- Delegate the record to a generic sub-agent with `linear-issue-draft-pr` preloaded (`preloaded_skills` is valid only for generic sub-agents). A mitigation sub-agent may stop at the proposal and never run this skill.
- The lead puts three things verbatim in the prompt of the sub-agent that records the result: the `slack_reply_target:` line, the Incident value (omitted when `unknown`), and the instruction to run this skill to the end (also after a mitigation proposal). A sub-agent does not see the incident description; without the line it sends no Slack reply.
- The agent that creates the Issue and the PR sends reply B.

## Workflow

1. Send Slack reply A as soon as the investigation starts, unless reply A was already sent in this investigation (never send it twice; the lead normally sends it, see Delegation).
2. Resolve the team (CHK-02): read `Linear team:` from `AGENTS.md` and confirm it exists with `list_teams`. IF it is missing or does not exist → create nothing in Linear, go to step 9 with `Failed`.
3. Check the label `devops-agent` (CHK-05: `list_issue_labels`, then `save_issue_label` when it is missing).
4. Search Linear for an existing open Issue for the same alarm and resource (`list_issues` with `team`, `label: devops-agent`, and `query`).
   IF one is open → add the new evidence with `save_comment`, find the PR linked from it, record both URLs, go to step 9.
5. Create the Issue (`save_issue` without `id`, `team`, `title`, `description`, `labels: ["devops-agent"]`) from the Issue template. Title: `[<environment>] <resource>: <problem>`. The `Pull request` section starts as `none (PR not created yet)`; step 6 or step 8 replaces it, so the Issue never ends with that placeholder.
6. Decide whether a Draft PR is allowed (CHK-04 in the checklist). IF not → set the `Pull request` section of the Issue to `none (<reason>)` (`save_issue` with `id` and `patch`), then go to step 9 with the Issue only.
7. Create the working branch `feature/devops-agent/<short-resource-name>-<yyyymmdd>` from the base branch (`create_branch`, GitHub MCP), then read the target files (`get_file_contents`, `search_code`) and make the smallest possible change to the failing resource definition (`create_or_update_file`, or `push_files` for several files). IF the fix cannot be made in code → do not open a PR; set the `Pull request` section to `none (<reason>)`, put the proposed fix in the Issue, and go to step 9. A PR containing only a document that describes the fix is prohibited. Follow `AGENTS.md` / `CLAUDE.md` when present.
8. Open a **Draft** PR to the base branch (`create_pull_request`, `draft: true`) from the PR template with the Linear identifier (for example `ENG-123`) in the body, then add the GitHub label `devops-agent` (CHK-05). Then set the `Pull request` section of the Issue to the full PR URL and `Draft`, and attach the PR as a link (`save_issue` with `id`, `patch`, and `links: [{url, title}]`).
9. Send Slack reply B (by the agent that created the result; in every outcome). Send reply C only when a human decision is needed.
10. Report the outcome, Incident (omitted when `unknown`), Repository, Issue URL, and PR URL in the investigation result, in the format of reply B.

### Error Handling

| Condition                                | Severity    | Action                                                                                                                                                                                  |
| ---------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A tool call fails                        | Recoverable | Do not retry in a loop; report the failing tool, the error text, and the likely missing permission; put the Issue/PR text in the result so a human can create it                        |
| `Linear team:` missing or team not found | Recoverable | Create nothing in Linear and never fall back to another team; reply B with `Failed`; put the Issue text in the result                                                                   |
| Label `devops-agent` cannot be created   | Recoverable | Do not retry; create no Issue without the label (the follow-up agent would never find it); reply B with `Failed`, naming the Linear permission needed; put the Issue text in the result |
| Base branch cannot be determined         | Recoverable | Record the Linear Issue only; say why                                                                                                                                                   |
| Repository is ambiguous                  | Recoverable | Record the Linear Issue only; say why                                                                                                                                                   |
| GitHub label `devops-agent` is missing   | Recoverable | The GitHub MCP has no label-creation tool and a person with Label creation permission must create it (CHK-05); do not retry; say so in a PR comment and in reply B                      |
| Slack reply A fails                      | Recoverable | Do not retry; continue; still attempt reply B                                                                                                                                           |
| Slack reply B fails                      | Recoverable | Do not retry; report the error text in the result                                                                                                                                       |
| `slack_reply_target` absent or malformed | Info        | Send no Slack reply; do not guess a channel or timestamp                                                                                                                                |

<!-- last_verified: 2026-10-13 (Linear and GitHub MCP server tool names; review quarterly) -->
