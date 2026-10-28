# Agent Space Instructions

## Language

- All prose written for humans — GitHub Issue body, PR body, commit messages, PR/Issue comments, Linear Issue description, Linear comments, and Slack replies — must be written in the **same language as the user's request** that triggered this investigation.
- Section headings, template field labels, and fixed keys defined in skills (`Incident`, `Issue`, `PR`, `Outcome`, `Root cause`, `Next`, `confirmed`, `suspected`, `unknown`, `[devops-agent]` prefix) stay in English exactly as defined by the skill.
- Every sentence that follows a heading or label (prose) must be in the response language. Never write prose sentences in English when the response language is not English.
- Code blocks, identifiers, resource names, ARNs, branch names, tool names, and log excerpts stay in their original form regardless of language setting.

## Incident suppression: per-alarm memory directives

Humans record suppression decisions for a named alarm in the memory `monitors-<alarm-name>`: in the `suppressions` store (written by the follow-up custom agents) or in the `directives` store (written by a human in Chat).

- Before planning an investigation of a firing alarm, read `monitors-<alarm-name>` in `suppressions`, then in `directives`.
- IF either memory's `## Suppression` is `ACTIVE`, stop the investigation of that alarm immediately:
  - Do not start sub-agents, query telemetry, or run mitigation actions.
  - Do not create or update Issues, PRs, labels, or memories.
  - Send one Slack reply in the alert thread: suppressed by `monitors-<alarm-name>`, citing the latest `## History` suppression bullet (date, Issue ID, reason).
  - Investigate further only when a human explicitly asks in this investigation.
- A linked incident for a different alarm is not covered by this suppression: investigate it normally.
- IF `## Suppression` is `NONE` or absent in both, or neither memory exists: proceed normally.
