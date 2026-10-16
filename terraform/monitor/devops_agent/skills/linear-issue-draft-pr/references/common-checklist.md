# Linear Issue and Draft PR Checklist

Gate IDs are for self-check and for explaining a skipped step. Do not put these IDs in Linear Issues, PRs, or Slack.

## Language

### CHK-01: One language

- [ ] Write everything you produce for people (Issue title/body, PR title/body, commit messages, comments, Slack replies) in the same language as your response in this investigation (the Agent Space response language, or the language of the request when none is set)
- [ ] Do not mix languages in the prose of one Issue, PR, or reply
- [ ] Keep in English, exactly as defined: section headings, field labels and keys of the templates and Slack formats (`Incident`, `Issue`, `PR`, `Outcome`, `Root cause`, `Next`, `Repository`, `base branch`), the Outcome values, `confirmed`/`suspected`, `unknown`, and the `[devops-agent]` prefix. Write all prose (every sentence after a heading or label) in the response language, never in English. Keep code, identifiers, resource names, ARNs, branch names, tool names, and log excerpts as they are
- [ ] End the Linear Issue and PR body with the `Meta` block of the template and set `response_language` to the language code of your response (for example `ja`)
- [ ] Linear does not render HTML: never write `<details>` or `<summary>` in a Linear Issue or comment (they appear as raw text). Make a section collapsible only with Linear's `+++ <title>` … `+++` syntax. GitHub PR bodies keep `<details>`
- **PASS** if each artifact uses a single language

## Linear team

### CHK-02: Target team

- [ ] Read the line `Linear team: <team>` in `AGENTS.md` (Terraform appends it from the tfvars `agent_spaces.<name>.linear.team`); that is the only team you may use
- [ ] Confirm the team exists with `list_teams` (`query` = the value) before the first write to Linear
- [ ] If the line is missing or the team does not exist, create nothing in Linear, never guess or fall back to another team, and report it in reply B (`Failed`) and the investigation result
- [ ] Pass the same team value as `team` to every `list_issues`, `list_issue_labels`, and `save_issue` (create) call
- **PASS** if every Issue was created in the configured team, or none was created

## Repository and branches

### CHK-03: Target repository and base branch

- [ ] Repository: the associated repository that contains the failing resource definition (for Terraform resources, the Terraform repository); if ambiguous, record only the Linear Issue and say why
- [ ] Always identify the repository by its full name `<owner>/<repo>` in the Linear Issue description, the PR body, reply B, and the investigation result, because several repositories can be associated with the Agent Space and a file name alone does not show which repository the code belongs to. Reply A never carries it (the repository is not resolved yet) and reply C keeps its fixed format
- [ ] When the repository is ambiguous or no associated repository holds the target, write `none (<reason>)`, with the candidates in the reason when ambiguous (for example `none (ambiguous: <owner>/<repo>, <owner>/<repo>)`), in the same way in the Linear Issue description, the Meta block, and reply B; never pick one by guess
- [ ] Label every file reference `<owner>/<repo>:<path>` (never a bare file name or relative path) and keep the label out of backticks, except inside verbatim log excerpts and code blocks, which stay as they are (CHK-01). Make it a link only where the link format allows it (`common-output-format.md`, rows Repository and File); name a file outside any GitHub repository by its source (host/group/repo or the AWS resource ARN) without a link
- [ ] Link a file only after you verified its path on the branch used in the link (`get_file_contents` with `ref`, or the file you wrote in this run); a `search_code` hit proves the path only on the default branch. When you create the Linear Issue before the files are read, use the plain label and add the links when you update it
- [ ] Base branch: the repository default branch, read from the repository metadata (`search_repositories` with query `repo:<owner>/<repo>`, field `default_branch`); never assume `develop` or `main`, because the default branch differs per repository; resolve it once per repository and use it everywhere, including in file links
- [ ] If the default branch cannot be determined, record only the Linear Issue and say why
- **PASS** if one base branch is used for every step, and every repository and file reference follows the rules above

### CHK-04: Working branch and PR criteria

Working branch:

- [ ] Name: `feature/devops-agent/<short-resource-name>-<yyyymmdd>` created from the base branch (for example `feature/devops-agent/rds-cpu-alarm-threshold-20261011`)
- [ ] Fallback: If `create_branch` is rejected (for example an existing branch named `feature/devops-agent` blocks the `feature/devops-agent/` prefix), create the branch with the closest name the repository accepts, in this order: `feature/devops-agent-<short-resource-name>-<yyyymmdd>`, then any other `feature/*` name; never use `develop`, the default branch, or a non-`feature/` name, and state the branch name actually used in the Issue and PR
- [ ] Never commit to `develop`, the default branch, or the base branch directly

Open a PR only when all of these hold:

- [ ] The root cause is confirmed (not a guess) and the fix is a small, local change in the repository (alarm threshold or period, missing tag, log retention, timeout, memory size, typo in a variable)
- [ ] The change is reversible and does not affect IAM, SCP, KMS keys, network exposure, encryption, or data deletion
- [ ] The change is NOT any of the following, regardless of how small it appears: environment variables (may contain secrets), S3 bucket policies, VPC security group rules, IAM roles or policies, or data retention settings that affect compliance
- [ ] The PR changes the failing resource definition itself (the actual fix). Never open a PR whose only content is a document, note, report, or markdown file that describes the fix; if the fix cannot be made in code, open no PR and write the proposal in the Linear Issue instead
- [ ] Otherwise record the Linear Issue only and list the manual steps in it
- **PASS** if every commit is on a `feature/devops-agent/**` branch (or the fallback `feature/*` branch), and a PR exists only when every box above holds

<!-- last_verified: 2026-10-14 (checklist items; review quarterly) -->

## Label

### CHK-05: Label `devops-agent` (Linear and GitHub)

Linear (the follow-up agent finds Issues by this label):

- [ ] Before the first Issue, check the label with `list_issue_labels` (`name: devops-agent`, `team` = the configured team)
- [ ] If it does not exist in the team or the workspace, create it with `save_issue_label` (`name: devops-agent`; a workspace label when `teamId` is omitted, or pass the team UUID from `list_teams`); never edit, rename, or retire other labels
- [ ] If the label cannot be found or created (for example the Linear token has no permission to create labels), create no Issue, because the follow-up agent would never find it; report the missing permission in reply B (`Failed`) and put the Issue text in the result
- [ ] Issue: pass `labels: ["devops-agent"]` to `save_issue` when creating it; add the label to a reused Issue that lacks it (`save_issue` with `addLabels`; never `labels`, which replaces the label set)

GitHub (the follow-up agent finds PRs by this label):

- [ ] The label `devops-agent` must already exist in the repository, created beforehand by a person with Label creation permission in GitHub: the GitHub MCP server has no tool to create a label and the agent cannot create it
- [ ] Before the first PR, check it with `get_label` (name `devops-agent`); if it is missing, report that in the PR description and reply B and ask a person with the permission to create it; do not retry
- [ ] PR: right after `create_pull_request`, add the label with `issue_write` (`method: update`, `issue_number` = the PR number, `labels: ["devops-agent"]`)

Both:

- [ ] Never put the label on an Issue or PR that you did not create or reuse for this root cause
- **PASS** if every Linear Issue created or reused carries the label, and every PR created or reused carries the label or the missing GitHub label was reported

## Prohibited actions

### CHK-06: Prohibitions

- [ ] Do not push to `develop` or the default branch, merge a pull request, approve or dismiss reviews, force push, or delete branches
- [ ] Do not mark a pull request ready for review; leave it as Draft
- [ ] Do not open a PR that only adds or changes documents (for example a markdown file describing the fix); a PR must contain the real fix
- [ ] Do not write secrets, tokens, credentials, account-specific sensitive data, or customer data in Linear Issues, PRs, commits, or comments
- [ ] Do not read secrets or credentials (`secretsmanager:GetSecretValue`, SSM SecureString); the role has no access and each denied call raises an alert. Use logs and metrics, and report in the output that the cause could not be confirmed instead of retrying
- [ ] Do not edit generated files or directories: `.agents/`, `.cursor/`, `.claude/`, `.vscode/`, `apm_modules/`, `.terraform/`, lock files, and build outputs
- [ ] Do not change IAM policies, SCPs, KMS key policies, or production data to "fix" an alarm; record it in the Linear Issue only
- [ ] Do not run or request destructive operations; do not assign Copilot or other coding agents; do not delegate the Linear Issue to an agent
- [ ] Do not create more than one Issue and one PR per root cause
- [ ] Do not create an Issue in a team other than the configured one; do not delete, archive, or move Linear Issues, projects, or documents; do not change assignees, priority, or workflow state of Issues you did not create
- [ ] Do not edit, rename, retire, or delete labels other than creating `devops-agent` when it is missing
- [ ] Do not post to Slack channels or threads other than the one named by `slack_reply_target`, and do not send more than three replies (A, B, and at most one reply C)
- **PASS** if none of the above occurred
