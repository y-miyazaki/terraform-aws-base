<!--
Linear Issue template for linear-issue-draft-pr.
Load ONLY when creating or updating the Issue.

LANGUAGE (CHK-01): Write ALL prose in the same language as the user request that
triggered this investigation. Do NOT default to English. Section headings, field
labels, fixed keys (confirmed, suspected, Draft, none, etc.), code, identifiers,
resource names, ARNs, and log excerpts stay as-is regardless of language.

Title: [<environment>] <resource>: <problem>
Create with save_issue: team = the configured Linear team, labels = ["devops-agent"], description = this body (Markdown, literal newlines).

INCIDENT: The Incident appears only as the `incident` row in the Meta table. Do NOT add an
`## Incident` section or any other line containing `incidentId=`. When the Incident value
would be `unknown`, omit the `incident` row; never write `incidentId=unknown`.
-->

## Repository

<!--
  Name the repository by its full name, as a link (link format in references/common-output-format.md, row Repository).
  Several repositories can be associated with the Agent Space, so a file name alone does not show which code is meant.
  In every section below, write each file as a link labeled `<owner>/<repo>:<path>` (row File); no backticks around it.
  Link a file only after its path is verified on that branch; when you create the Linear Issue before reading the files, use the plain label and add the links on update.
  When the repository is ambiguous or no associated repository holds the target, write `none (<reason>)` (candidates in the reason when ambiguous). When the base branch cannot be determined, write `base branch: none (<reason>)`.
-->

[<owner>/<repo>](https://github.com/<owner>/<repo>) (base branch: `<base branch>`)

## Overview

<what fired, when, severity>

## Evidence

<alarm state, metric values, log excerpts with timestamps; mask secrets and personal data>

## Root cause

<confirmed | suspected, with the reasoning>

## Impact and scope checked

<affected resources and what was checked; do not include environment variables, secrets, or credentials>

## Proposed fix and rollback

<small change, or the manual steps when no PR is created; how to roll back>

## Pull request

<!-- Exactly one of the two forms. Never leave the placeholder. -->

<PR created: `PR: <full PR URL> (Draft)`>
<PR not created: `PR: none (<reason: root cause unconfirmed | change touches IAM/SCP/KMS/network/encryption/data | no target in a repository | PR not created yet>)`>

---

## Auto-close rules

The DevOps Agent follow-up bot applies these rules on every scheduled run.

**The linked PR is closed automatically when any of the following holds:**

| Condition                           | Trigger                                                                                                                                               |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| AUTO-C1: This Issue is closed       | The PR is closed as `not_planned`                                                                                                                     |
| AUTO-C2: Fix applied outside the PR | A comment or review states the fix was committed or merged elsewhere (e.g. "already fixed in #N", "別途対処済み") — the PR is closed as `not_planned` |
| AUTO-C3: No fix needed              | A comment or review states no change is required (e.g. "won't fix", "false positive", "修正不要") — the PR is closed as `not_planned`                 |
| AUTO-C4: Explicit close instruction | A comment explicitly says to close the PR — the PR is closed as `not_planned` (or `completed` when the problem is resolved)                           |

**This Issue is closed automatically when:**

- A comment explicitly instructs closing it (canceled state, or completed when resolved).
- The linked PR is merged (completed state).

**Conflict rule:** when instructions conflict (e.g. one comment says keep open, another says close), **close takes precedence**. The bot posts a comment explaining the conflict before closing.

+++ Meta

<!--
Fixed keys stay in English. One row per key in the `| Key | Value |` table; write the key and the value as plain text (no backticks), and escape `|` inside a value as `\|`; keep this section last.
response_language: the language code of your response (ja, en, ...); the follow-up bot writes its comments in this language.
incident: the Incident value from the link format; omit this row when it would be `unknown`.
repository: the <owner>/<repo> full name (plain text, no link inside this table); write `none (<reason>)` (candidates in the reason when ambiguous) when the repository is ambiguous or none holds the target.
-->

| Key               | Value                                                 |
| ----------------- | ----------------------------------------------------- |
| response_language | <language code, e.g. ja>                              |
| incident          | <Incident value>                                      |
| environment       | <dev \| qa \| stg \| prd>                             |
| repository        | <owner>/<repo>                                        |
| root_cause_status | <confirmed \| suspected>                              |
| created_by        | devops-agent (<agent name>) at <YYYY-MM-DDTHH:MM:SSZ> |
| last_followup     | none                                                  |

+++
