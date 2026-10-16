<!--
Notion page template for notion-issue-draft-pr.
Load ONLY when creating or updating the page.

LANGUAGE (CHK-01): Write ALL prose in the same language as the user request that
triggered this investigation. Do NOT default to English. Section headings, field
labels, fixed keys (confirmed, suspected, Draft, none, etc.), code, identifiers,
resource names, ARNs, and log excerpts stay as-is regardless of language.

Title: [<environment>] <resource>: <problem>
Properties (when the database has them): Status = Open, Severity, Environment, Resource, Investigation ID, tag devops-agent.

INCIDENT: The Incident appears only as the `incident:` line in the Meta block. Do NOT add an
`## Incident` section or any other line containing `incidentId=`. When the Incident value
would be `unknown`, omit the `incident:` line; never write `incidentId=unknown`.
-->

## Repository

<!--
  Name the repository by its full name, as a link (link format in references/common-output-format.md, row Repository).
  Several repositories can be associated with the Agent Space, so a file name alone does not show which code is meant.
  In every section below, write each file as a link labeled `<owner>/<repo>:<path>` (row File); no backticks around it.
  Link a file only after its path is verified on that branch; when you create the page before reading the files, use the plain label and add the links on update.
  When the repository is ambiguous or no associated repository holds the target, write `none (<reason>)` (candidates in the reason when ambiguous). When the base branch cannot be determined, write `base branch: none (<reason>)`.
-->

[<owner>/<repo>](https://github.com/<owner>/<repo>) (base branch: `<base branch>`)

## Overview

<what fired, when, severity>

## Evidence

<alarm state, metric values, log excerpts with timestamps; mask secrets and personal data>

## Root cause

<confirmed | suspected, with the reasoning>

## Impact and scope

<affected resources and what was checked>

## Proposed fix and rollback

<small change, or the manual steps when no PR is created; how to roll back>

## Links

<!-- Exactly one of the two forms. Never leave the placeholder. -->

<PR created: `PR: <full PR URL> (Draft)`>
<PR not created: `PR: none (<reason: root cause unconfirmed | change touches IAM/SCP/KMS/network/encryption/data | no target in a repository | PR not created yet>)`>

<details>
<summary>Meta</summary>
	<!--
	Fixed keys stay in English. One `key: value` per line; keep this section last.
	response_language: the language code of your response (ja, en, ...); the follow-up bot writes its comments in this language.
	incident: the Incident value from the link format; omit this line when it would be `unknown`.
	repository: the <owner>/<repo> full name (plain text, no link inside this block); write `none (<reason>)` (candidates in the reason when ambiguous) when the repository is ambiguous or none holds the target.
	-->

    ```text
    response_language: <language code, e.g. ja>
    incident: <Incident value>
    environment: <dev | qa | stg | prd>
    repository: <owner>/<repo>
    root_cause_status: <confirmed | suspected>
    created_by: devops-agent (<agent name>) at <YYYY-MM-DDTHH:MM:SSZ>
    ```

</details>
