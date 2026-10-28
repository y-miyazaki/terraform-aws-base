---
name: github-issue-draft-pr
description: "Record an alarm investigation as a GitHub Issue labeled devops-agent and, for a small confirmed fix, a Draft PR (to the repository default branch). Use this when an investigation of a CloudWatch alarm or incident finds a root cause that needs follow-up in the repository, or when asked to file an Issue or PR. It also replies to the Slack alert thread."
---

# GitHub Issue and Draft PR from an alarm investigation

**ALARM FOLLOW-UP SKILL**: records a root cause as a GitHub Issue, proposes a small safe fix as a Draft PR, and reports to the Slack alert thread. Run it also after a mitigation proposal, because it owns the record and the Slack replies.

## Input

- The incident (title, description, priority, incident ID) of the current investigation. The description may end with a `slack_reply_target:` line.
- The GitHub repositories associated with the Agent Space.

## Output Specification

- A GitHub Issue and, when allowed, a Draft PR, both labeled `devops-agent`.
- Slack reply A (start), reply B (final), and reply C only for a human escalation, and the investigation result, in the formats of [common-output-format.md](references/common-output-format.md).
- Issue and PR text from [issue-body-template.md](assets/issue-body-template.md) and [pr-body-template.md](assets/pr-body-template.md).
- The Issue, the PR, reply B, and the investigation result identify the repository (`<owner>/<repo>`) and label files as `<owner>/<repo>:<path>`, as links where possible (rules: CHK-02 in the checklist, rows Repository and File in the output format).

## Execution Scope

### USE FOR:

- An alarm or incident investigation that finds a root cause needing follow-up in the repository.
- A request to file an Issue or a Draft PR for an investigated problem.

### DO NOT USE FOR:

- Chat questions, status checks, or investigations without an actionable root cause (create nothing; send reply B with `No action`).
- Replying to comments on existing Issues and PRs (`github-issue-pr-followup`).
- Tracking incidents in Linear (`linear-issue-draft-pr`). Never run two tracker skills for the same alarm; if several are loaded, use this skill only when it is the one the team configured for this Agent Space, otherwise stop and report the conflict.
- Resources not defined in an associated repository (create the Issue only and say why).

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read: language, branches, label, when to open a PR, prohibited actions)
- [common-output-format.md](references/common-output-format.md) (always read: link format, Slack reply A and B)
- [issue-body-template.md](assets/issue-body-template.md) (read when creating or updating the Issue)
- [pr-body-template.md](assets/pr-body-template.md) (read when opening the PR)

## Suppression pre-check (before creating anything)

This is a second safety net for the GENERIC `AGENTS.md` rule _incident-suppression: per-alarm
memory directives_. Even though the investigation should already have stopped early, re-check here so a
suppressed alarm never gets a fresh Issue/PR at the record step.

- Extract the alarm name from the incident title: the string after the environment prefix
  (`[prd]`/`[stg]`/`[dev]`) and before the first `:`, lowercase kebab-case (spaces and `/` → `-`).
- `get_memory` for `monitors-<alarm-name>` in `suppressions`, then in `directives`.
- IF either memory's `## Suppression` is `ACTIVE` → create **no** GitHub Issue and **no** PR. Send Slack
  reply B with `No action`, noting the alarm is suppressed by an active directive (cite the
  memory name), and go straight to the final report.
- IF `NONE`/absent in both, or neither memory exists → proceed with the workflow below.

## Delegation

Roles when the investigation lead delegates to a sub-agent (for example the mitigation sub-agent):

- The investigation lead sends reply A itself at the start. Before it finishes it checks that reply B was sent: the lead cannot read Slack, so it relies on the `ok` and `ts` the sub-agent reports, and it checks the Issue/page and PR itself with the read tools.
- Delegate the record to a generic sub-agent with `github-issue-draft-pr` preloaded (`preloaded_skills` is valid only for generic sub-agents). A mitigation sub-agent may stop at the proposal and never run this skill.
- The lead puts three things verbatim in the prompt of the sub-agent that records the result: the `slack_reply_target:` line, the Incident value (omitted when `unknown`), and the instruction to run this skill to the end (also after a mitigation proposal). A sub-agent does not see the incident description; without the line it sends no Slack reply.
- The agent that creates the Issue/page and the PR sends reply B.

## Workflow

1. Send Slack reply A as soon as the investigation starts, unless reply A was already sent in this investigation (never send it twice; the lead normally sends it, see Delegation).
2. Run the **Suppression pre-check** above. IF suppressed → create nothing, send reply B with `No action`, and go to step 9.
3. Search for an existing Issue (`search_issues`, `list_issues`) using the alarm name and resource name.
   IF one is open → add the new evidence with `add_issue_comment`, make sure it has the label `devops-agent`, find the linked PR, record both URLs, go to step 9.
4. Create the Issue (`issue_write`, `labels: ["devops-agent"]`) from the Issue template. Title: `[<environment>] <resource>: <problem>`. The `Pull request` section starts as `none (PR not created yet)`; step 5 or step 8 replaces it, so the Issue never ends with that placeholder.
5. Decide whether a Draft PR is allowed (CHK-04 in the checklist). IF not → set the `Pull request` section of the Issue to `none (<reason>)` (`issue_write` update, keep the other text), then go to step 9 with the Issue only.
6. Create the working branch `feature/devops-agent/<short-resource-name>-<yyyymmdd>` from the base branch (`create_branch`).
7. Read the target files (`get_file_contents`, `search_code`) and make the smallest possible change to the failing resource definition (`create_or_update_file`, or `push_files` for several files). IF the fix cannot be made in code → do not open a PR; set the `Pull request` section to `none (<reason>)`, put the proposed fix in the Issue, and go to step 9. A PR containing only a document that describes the fix is prohibited. Follow `AGENTS.md` / `CLAUDE.md` when present.
8. Open a **Draft** PR to the base branch (`create_pull_request`, `draft: true`) from the PR template, then add the label `devops-agent`. Then set the `Pull request` section of the Issue to the full PR URL and `Draft` (`issue_write` update, keep the other text).
9. Send Slack reply B (by the agent that created the result; in every outcome). Send reply C only when a human decision is needed.
10. Report the outcome, Incident (omitted when `unknown`), Repository, Issue URL, and PR URL in the investigation result, in the format of reply B.

### Error Handling

| Condition                                 | Severity    | Action                                                                                                                                                                                                     |
| ----------------------------------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A tool call fails (e.g. `403`)            | Recoverable | Do not retry in a loop; report the failing tool, the error text, and the required permission (Issues, Contents, Pull requests: read and write); put the Issue/PR text in the result so a human can file it |
| Base branch cannot be determined          | Recoverable | Create the Issue only; say why                                                                                                                                                                             |
| Repository is ambiguous                   | Recoverable | Create the Issue only; say why                                                                                                                                                                             |
| Label `devops-agent` is missing in GitHub | Recoverable | The GitHub MCP has no label-creation tool, so a person with Label creation permission must create it (CHK-05); do not retry; say so in the Issue and in reply B                                            |
| Label cannot be added to the PR           | Recoverable | Do not retry; say so in a PR comment and in reply B                                                                                                                                                        |
| Slack reply A fails                       | Recoverable | Do not retry; continue; still attempt reply B                                                                                                                                                              |
| Slack reply B fails                       | Recoverable | Do not retry; report the error text in the result                                                                                                                                                          |
| `slack_reply_target` absent or malformed  | Info        | Send no Slack reply; do not guess a channel or timestamp                                                                                                                                                   |

<!-- last_verified: 2026-10-17 (GitHub MCP server tool names; review quarterly) -->
