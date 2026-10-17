# Issue and Draft PR Checklist

Gate IDs are for self-check and for explaining a skipped step. Do not put these IDs in Issues, PRs, or Slack.

## Language

### CHK-01: One language

- [ ] Write everything you produce for people (Issue title/body, PR title/body, commit messages, comments, Slack replies) in the same language as your response in this investigation (the Agent Space response language, or the language of the request when none is set)
- [ ] Do not mix languages in the prose of one Issue, PR, or reply
- [ ] Keep in English, exactly as defined: section headings, field labels and keys of the templates and Slack formats (`Incident`, `Issue`, `PR`, `Outcome`, `Root cause`, `Next`, `Repository`, `base branch`), the Outcome values, `confirmed`/`suspected`, `unknown`, and the `[devops-agent]` prefix. Write all prose (every sentence after a heading or label) in the response language, never in English. Keep code, identifiers, resource names, ARNs, branch names, tool names, and log excerpts as they are
- [ ] End the Issue and PR body with the `Meta` block (a `| Key | Value |` table) of the template and set the `response_language` row to the language code of your response (for example `ja`)
- **PASS** if each artifact uses a single language

## Repository and branches

### CHK-02: Target repository and base branch

- [ ] Repository: the associated repository that contains the failing resource definition (for Terraform resources, the Terraform repository); if ambiguous, create only the Issue and say why
- [ ] Always identify the repository by its full name `<owner>/<repo>` in the Issue body, the PR body, reply B, and the investigation result, because several repositories can be associated with the Agent Space and a file name alone does not show which repository the code belongs to. Reply A never carries it (the repository is not resolved yet) and reply C keeps its fixed format
- [ ] When the repository is ambiguous or no associated repository holds the target, write `none (<reason>)`, with the candidates in the reason when ambiguous (for example `none (ambiguous: <owner>/<repo>, <owner>/<repo>)`), in the same way in the Issue body, the Meta block, and reply B; never pick one by guess
- [ ] Label every file reference `<owner>/<repo>:<path>` (never a bare file name or relative path) and keep the label out of backticks, except inside verbatim log excerpts and code blocks, which stay as they are (CHK-01). Make it a link only where the link format allows it (`common-output-format.md`, rows Repository and File); name a file outside any GitHub repository by its source (host/group/repo or the AWS resource ARN) without a link
- [ ] Link a file only after you verified its path on the branch used in the link (`get_file_contents` with `ref`, or the file you wrote in this run); a `search_code` hit proves the path only on the default branch. When you create the Issue before the files are read, use the plain label and add the links when you update it
- [ ] Base branch: the repository default branch, read from the repository metadata (`search_repositories` with query `repo:<owner>/<repo>`, field `default_branch`); never assume `develop` or `main`, because the default branch differs per repository; resolve it once per repository and use it everywhere, including in file links
- [ ] If the default branch cannot be determined, create only the Issue and say why
- **PASS** if one base branch is used for every step, and every repository and file reference follows the rules above

### CHK-03: Working branch

- [ ] Name: `feature/devops-agent/<short-resource-name>-<yyyymmdd>` created from the base branch (for example `feature/devops-agent/rds-cpu-alarm-threshold-20261011`)
- [ ] Fallback: If `create_branch` is rejected (for example an existing branch named `feature/devops-agent` blocks the `feature/devops-agent/` prefix), create the branch with the closest name the repository accepts, in this order: `feature/devops-agent-<short-resource-name>-<yyyymmdd>`, then any other `feature/*` name; never use `develop`, the default branch, or a non-`feature/` name, and state the branch name actually used in the Issue and PR.
- [ ] Never commit to `develop`, the default branch, or the base branch directly
- **PASS** if every commit is on a `feature/devops-agent/**` branch, or on the fallback `feature/*` branch when the preferred name was rejected

## When to open a PR

### CHK-04: PR criteria (all must hold)

- [ ] The root cause is confirmed (not a guess) and the fix is a small, local change in the repository (alarm threshold or period, missing tag, log retention, timeout, memory size, typo in a variable)
- [ ] The change is reversible and does not affect IAM, SCP, KMS keys, network exposure, encryption, or data deletion
- [ ] The change is NOT any of the following, regardless of how small it appears: environment variables (may contain secrets), S3 bucket policies, VPC security group rules, IAM roles or policies, or data retention settings that affect compliance
- [ ] The PR changes the failing resource definition itself (the actual fix). Never open a PR whose only content is a document, note, report, or markdown file that describes the fix; if the fix cannot be made in code, open no PR and write the proposal in the Issue instead
- [ ] Otherwise create the Issue only and list the manual steps in it
- **PASS** if a PR exists only when every box above holds

<!-- last_verified: 2026-10-14 (checklist items; review quarterly) -->

## Label

### CHK-05: Label `devops-agent`

- [ ] The label `devops-agent` must already exist in the repository, created beforehand by a person with Label creation permission in GitHub: the GitHub MCP server has no tool to create a label and the agent cannot create it
- [ ] Before the first Issue, check the label with `get_label` (name `devops-agent`); if it is missing, still create the Issue, report in the Issue and in reply B that the label is missing, and ask a person with Label creation permission to create it; do not retry
- [ ] Issue: pass `labels: ["devops-agent"]` to `issue_write` when creating it; add the label to a reused Issue that lacks it (`issue_write` update)
- [ ] PR: right after `create_pull_request`, add the label with `issue_write` (`method: update`, `issue_number` = the PR number, `labels: ["devops-agent"]`)
- [ ] Never put the label on an Issue or PR that you did not create or reuse for this root cause
- [ ] The follow-up agent finds your work by this label; an item without it is never followed up
- **PASS** if every Issue and PR created or reused carries the label

## Prohibited actions

### CHK-06: Prohibitions

- [ ] Do not push to `develop` or the default branch, merge a pull request, approve or dismiss reviews, force push, or delete branches
- [ ] Do not mark a pull request ready for review; leave it as Draft
- [ ] Do not open a PR that only adds or changes documents (for example a markdown file describing the fix); a PR must contain the real fix
- [ ] Do not write secrets, tokens, credentials, account-specific sensitive data, or customer data in Issues, PRs, commits, or comments
- [ ] Do not read secrets or credentials (`secretsmanager:GetSecretValue`, SSM SecureString); the role has no access and each denied call raises an alert. Use logs and metrics, and report in the output that the cause could not be confirmed instead of retrying
- [ ] Do not edit generated files or directories: `.agents/`, `.cursor/`, `.claude/`, `.kiro/`, `.vscode/`, `apm_modules/`, `.terraform/`, lock files, and build outputs
- [ ] Do not change IAM policies, SCPs, KMS key policies, or production data to "fix" an alarm; create an Issue instead
- [ ] Do not run or request destructive operations; do not assign Copilot or other coding agents
- [ ] Do not create more than one Issue and one PR per root cause
- [ ] Do not edit, rename, or delete labels
- [ ] Do not post to Slack channels or threads other than the one named by `slack_reply_target`, and do not send more than three replies (A, B, and at most one reply C)
- **PASS** if none of the above occurred
