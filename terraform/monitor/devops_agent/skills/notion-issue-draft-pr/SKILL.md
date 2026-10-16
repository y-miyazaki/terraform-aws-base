---
name: notion-issue-draft-pr
description: "Record an alarm investigation as a Notion incident page and, for a small confirmed fix, a GitHub Draft PR labeled devops-agent (to the repository default branch). Use this when an investigation of a CloudWatch alarm or incident finds a root cause and the team tracks incidents in Notion. It also replies to the Slack alert thread. Do not use it together with the GitHub Issue skill for the same alarm."
---

# Notion incident page and Draft PR from an alarm investigation

**ALARM FOLLOW-UP SKILL**: records a root cause as a Notion incident page (the Issue equivalent), proposes a small safe fix as a GitHub Draft PR linked from the page, and reports to the Slack alert thread. Run it also after a mitigation proposal, because it owns the record and the Slack replies. It requires the Notion MCP server and the GitHub MCP server to be connected to the Agent Space.

## Input

- The incident (title, description, priority, incident ID) of the current investigation. The description may end with a `slack_reply_target:` line.
- The incident database in Notion and the GitHub repositories associated with the Agent Space.

## Output Specification

- A Notion page and, when allowed, a Draft PR labeled `devops-agent`.
- Slack reply A (start), reply B (final), and reply C only for a human escalation, and the investigation result, in the formats of [common-output-format.md](references/common-output-format.md).
- Page and PR text from [page-body-template.md](assets/page-body-template.md) and [pr-body-template.md](assets/pr-body-template.md).
- The page, the PR, reply B, and the investigation result identify the repository (`<owner>/<repo>`) and label files as `<owner>/<repo>:<path>`, as links where possible (rules: CHK-02 in the checklist, rows Repository and File in the output format).

## Execution Scope

### USE FOR:

- An alarm or incident investigation that finds a root cause, when the team tracks incidents in Notion.
- A request to record an investigated problem in Notion and propose a Draft PR.

### DO NOT USE FOR:

- Chat questions, status checks, or investigations without an actionable root cause (create nothing; send reply B with `No action`).
- Tracking incidents as GitHub Issues (`github-issue-draft-pr`) or Linear Issues (`linear-issue-draft-pr`). Never run two tracker skills for the same alarm; if several are loaded, use this skill only when it is the one the team configured for this Agent Space, otherwise stop and report the conflict.
- Resources not defined in an associated repository (record the Notion page only and say why).

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read: language, branches, label, when to open a PR, prohibited actions)
- [common-output-format.md](references/common-output-format.md) (always read: link format, Slack reply A and B)
- [page-body-template.md](assets/page-body-template.md) (read when creating or updating the Notion page)
- [pr-body-template.md](assets/pr-body-template.md) (read when opening the PR)

## Delegation

Roles when the investigation lead delegates to a sub-agent (for example the mitigation sub-agent):

- The investigation lead sends reply A itself at the start. Before it finishes it checks that reply B was sent: the lead cannot read Slack, so it relies on the `ok` and `ts` the sub-agent reports, and it checks the Issue/page and PR itself with the read tools.
- Delegate the record to a generic sub-agent with `notion-issue-draft-pr` preloaded (`preloaded_skills` is valid only for generic sub-agents). A mitigation sub-agent may stop at the proposal and never run this skill.
- The lead puts three things verbatim in the prompt of the sub-agent that records the result: the `slack_reply_target:` line, the Incident value (omitted when `unknown`), and the instruction to run this skill to the end (also after a mitigation proposal). A sub-agent does not see the incident description; without the line it sends no Slack reply.
- The agent that creates the Issue/page and the PR sends reply B.

## Workflow

1. Send Slack reply A as soon as the investigation starts, unless reply A was already sent in this investigation (never send it twice; the lead normally sends it, see Delegation).
2. Search Notion for an existing page for the same alarm and resource (`notion-search`).
   IF an open one exists → append the new evidence, find the PR linked from it, record both URLs, go to step 7.
3. Create the page (`notion-create-pages`) in the incident database from the page template. Title: `[<environment>] <resource>: <problem>`. Properties: Status = Open, Severity, Environment, Resource, Investigation ID (when the database has them), and the tag `devops-agent` (when the database has a tag property).
4. Decide whether a Draft PR is allowed (CHK-04 in the checklist). IF not → set the `Links` section of the page to `PR: none (<reason>)` (`notion-update-page`), then go to step 7 with the page only.
5. Create the working branch `feature/devops-agent/<short-resource-name>-<yyyymmdd>` from the base branch (`create_branch`), make the smallest possible change to the failing resource definition (`get_file_contents`, `create_or_update_file` / `push_files`; IF the fix cannot be made in code, open no PR, set `PR: none (<reason>)`, and put the proposed fix on the page; a PR containing only a document that describes the fix is prohibited), open a **Draft** PR to the base branch (`create_pull_request`, `draft: true`) from the PR template, then add the label `devops-agent`.
6. Update the Notion page (`notion-update-page`) with the PR URL and set Status = PR Draft.
7. Send Slack reply B (by the agent that created the result; in every outcome). Send reply C only when a human decision is needed.
8. Report the outcome, Incident (omitted when `unknown`), Repository, page URL, and PR URL in the investigation result, in the format of reply B.

### Error Handling

| Condition                                | Severity    | Action                                                                                                                                                          |
| ---------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A tool call fails                        | Recoverable | Do not retry in a loop; report the failing tool, the error text, and the likely missing permission; put the page/PR text in the result so a human can create it |
| Incident database cannot be found        | Recoverable | Create nothing in Notion elsewhere; put the full text in the investigation result                                                                               |
| Base branch cannot be determined         | Recoverable | Record the Notion page only; say why                                                                                                                            |
| Label cannot be added to the PR          | Recoverable | Do not retry; say so in a PR comment and in reply B                                                                                                             |
| Slack reply A fails                      | Recoverable | Do not retry; continue; still attempt reply B                                                                                                                   |
| Slack reply B fails                      | Recoverable | Do not retry; report the error text in the result                                                                                                               |
| `slack_reply_target` absent or malformed | Info        | Send no Slack reply; do not guess a channel or timestamp                                                                                                        |

<!-- last_verified: 2026-10-12 (GitHub and Notion MCP server tool names; review quarterly) -->
