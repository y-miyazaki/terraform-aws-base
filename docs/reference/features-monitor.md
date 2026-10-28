# Monitor Features Detail

Detailed descriptions for features managed by `terraform/monitor/`. For configuration, see [Monitor Terraform Configuration Guide](../how-to/configure-monitor-tfvars.md).

## Log Monitoring

CloudWatch Logs metric filters detect patterns in log streams and trigger Slack notifications via Lambda.

Reference: [What is Amazon CloudWatch Logs?](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html)

### Application

The filter function of CloudWatch Logs checks specified logs with specified filter patterns. Those that hit the filter pattern will be notified by Slack via Lambda.

A daily report function is also available that aggregates application error logs and sends a summary to Slack via EventBridge Scheduler.

### MySQL

The filter function of CloudWatch Logs checks MySQL slow query logs with specified filter patterns. Those that hit the filter pattern will be notified by Slack via Lambda.

### PostgreSQL

The filter function of CloudWatch Logs checks specified logs with specified filter patterns. Those that hit the filter pattern will be notified by Slack via Lambda.

A daily report function is also available that aggregates PostgreSQL slow query logs and sends a summary to Slack via EventBridge Scheduler.

### Step Functions

The filter function of CloudWatch Logs checks Step Functions execution logs with specified filter patterns. Those that hit the filter pattern will be notified by Slack via Lambda.

### WAF

The filter function of CloudWatch Logs checks AWS WAF logs with specified filter patterns. Those that hit the filter pattern will be notified by Slack via Lambda.

## Metrics Monitoring

CloudWatch alarms monitor service-specific metrics and notify via SNS → Lambda → Slack when thresholds are exceeded.

Reference: [Using Amazon CloudWatch metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/working_with_metrics.html)

## CloudWatch Events (EventBridge)

EventBridge rules monitor AWS service state changes and send notifications to Slack.

Reference: [What Is Amazon EventBridge?](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html)

### Batch

AWS Batch job events are monitored via EventBridge. This includes job state changes (SUBMITTED, PENDING, RUNNABLE, STARTING, RUNNING, SUCCEEDED, FAILED).

### EC2

The following events are monitored:

- [EC2 Instance Rebalance Recommendation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/rebalance-recommendations.html)
- [EC2 Spot Instance Interruption Warning](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-instance-termination-notices.html)

### ECS Scheduled Task

ECS scheduled task events are monitored via EventBridge. This tracks scheduled task execution status and failures.

### ECS Service

ECS service events are monitored via EventBridge. This includes service deployment state changes, task placement failures, and service steady state notifications.

### RDS Cluster

RDS Aurora cluster events are monitored via EventBridge. This includes failover events, maintenance notifications, and configuration changes.

### Redshift

Redshift cluster events are monitored via EventBridge. This includes cluster maintenance events, snapshot events, and configuration changes.

## Athena

Amazon Athena enables SQL-based ad-hoc analysis of logs stored in S3.

Reference: [What is Amazon Athena?](https://docs.aws.amazon.com/athena/latest/ug/what-is.html)

### Named Query

Named Query is an Amazon Athena feature that allows you to name and save SQL queries and call them from the console.

![Named Query](../image/athena_named_query.png)

### CloudFront

If you are using CloudFront to store your standard logs in S3, you can retrieve the logs from Athena using SQL. When the Athena function is enabled, a table is created for CloudFront and a named query is created for easy searching.

Reference: [Configuring and using standard logs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html)

![CloudFront](../image/athena_cloudfront.png)

### SES

If you are using SES to store your standard logs in S3, you can retrieve the logs from Athena using SQL. When the Athena function is enabled, a table is created for SES and a named query is created for easy searching.

![SES](../image/athena_ses.png)

## AWS DevOps Agent

AWS DevOps Agent investigates incidents across AWS resources and connected tools (for example GitHub, and MCP servers such as GitHub / Linear) and proposes root causes and mitigations. Managed by `main_central_devops_agent.tf` and the `devops_agent` module. `devops_agent.primary.agent_spaces` is a map keyed by the Agent Space name, and the module is called once per Agent Space with `for_each`. The KMS key and the GitHub registrations (`devops_agent.primary.github_registrations`, a map) are shared at the account level.

The asset metadata (skills, `agents_md`, custom agents) that Terraform sends includes `status = "ACTIVE"` (and `skill_type = "USER"` for skills), the values the service adds and returns in the metadata, so they do not appear as a plan difference. An asset whose `metadata` differs only by these fields on the first plan after an upgrade is updated in place once.

Reference: [What is AWS DevOps Agent?](https://docs.aws.amazon.com/devopsagent/latest/userguide/about-aws-devops-agent.html)

| Component                    | Managed by                                       | Notes                                                                                                                                                                                    |
| ---------------------------- | ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Agent Space + IAM roles      | Terraform (awscc / aws)                          | Created in `region.primary`; operator web app enabled                                                                                                                                    |
| KMS customer managed key     | Terraform (`module.kms_key_devops_agent`)        | Cannot be changed after the Agent Space is created                                                                                                                                       |
| GitHub repositories          | Terraform (association)                          | GitHub must be registered at the account level in the console first (one registration per user / organization / GitHub Enterprise Server instance; multiple registrations are supported) |
| MCP servers (tool allowlist) | Terraform (association) + AWS CLI (registration) | Server registered account level with `aws devops-agent register-service --service mcpserver` (credential never enters the state); Terraform manages the per-Agent-Space tool allowlist   |
| Custom agents and triggers   | Terraform (awscc assets / triggers)              | Schedule triggers only (`TIME_BASED`, UTC)                                                                                                                                               |
| Generic webhook (HMAC)       | Terraform + AWS CLI (`terraform_data`)           | See [Generic Webhook](#generic-webhook)                                                                                                                                                  |

### Primary and Secondary Accounts

One Agent Space in the primary account can investigate other AWS accounts. An account takes part through `devops_agent.primary` and `devops_agent.secondary`, each switched on with its own `is_enabled`.

| Block                    | Creates                                                                                                        | Used in                                      |
| ------------------------ | -------------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| `devops_agent.primary`   | Agent Spaces and, for every `devops_agent.primary.secondary_accounts` entry, a source association              | The account that hosts the Agent Space (prd) |
| `devops_agent.secondary` | Only the read-only cross-account IAM role `DevOpsAgentRole-SecondaryAccount` (module `devops_agent_secondary`) | Every other account (dev, qa, stg)           |

The two blocks are independent. If you enable both in one account, the account hosts Agent Spaces that investigate itself and is also investigated by the Agent Space of another primary account.

The role trusts `aidevops.amazonaws.com` only when `aws:SourceAccount` is `devops_agent.secondary.primary_account_id` and `aws:SourceArn` is exactly `devops_agent.secondary.primary_agent_space_arn` (no wildcard), and has the AWS managed policy `AIDevOpsAgentAccessPolicy` plus a baseline of read-only metadata actions (module variable `default_policy_statements`; set `[]` to drop it) merged with `devops_agent.secondary.additional_policy_statements`. Secret-returning actions (`secretsmanager:GetSecretValue`, API Gateway API key reads) are intentionally not allowed. The role name is fixed so that the primary account can build the assumable role ARN from the account ID.

If `devops_agent.secondary.is_enabled` is `true`, `primary_account_id` and `primary_agent_space_arn` are required (validation error otherwise).

Rollout order (the secondary trust policy needs the Agent Space ARN, and the association needs the role):

1. Apply the primary account with `primary.agent_spaces.<name>.webhook.is_enabled = true`. Read the Agent Space ARN with `terraform output -json devops_agent_agent_space_arns`, the webhook URL with `devops_agent_webhook_urls`, and the HMAC secret from the secret (see [Generic Webhook](#generic-webhook)).
2. In each secondary account, set `secondary.is_enabled = true`, `secondary.primary_account_id` and `secondary.primary_agent_space_arn`, then apply.
3. In the primary account, add the accounts to `primary.secondary_accounts`, then apply.
4. In every account (primary and secondary), set `DEVOPS_AGENT_WEBHOOK_URL` and `DEVOPS_AGENT_WEBHOOK_HMAC_SECRET` in `metric.aws_lambda_function.environment` and `log.aws_lambda_function.environment`, then apply.

Re-creating the Agent Space (for example renaming its key or changing `kms.monitor_devops_agent.is_enabled`) changes the ARN: update `secondary.primary_agent_space_arn` in every secondary account and apply again.

Reference: [Getting started with AWS DevOps Agent using Terraform](https://docs.aws.amazon.com/devopsagent/latest/userguide/getting-started-with-aws-devops-agent-getting-started-with-aws-devops-agent-using-terraform.html)

### Issue and Draft PR from Alarms (GitHub / Linear)

The agent records an alarm investigation as a GitHub Issue (or a Linear Issue) and proposes a fix as a Draft pull request (PR) to `develop` (or the repository default branch when `develop` does not exist) from a `feature/devops-agent/**` branch. A human reviews and merges. A PR is opened only when it contains the real fix in code; when the fix cannot be made in code, the agent opens no PR and writes the proposal in the Issue (or page) instead. Use only one tracker skill (GitHub or Linear) per Agent Space; a PR is always a GitHub PR. A PR that only adds a document describing the fix is never opened.

Prerequisites:

- The GitHub registration and repository association are configured (`devops_agent.primary.github_registrations`, `primary.agent_spaces.<name>.github_repositories`).
- A fine-grained GitHub personal access token (PAT) limited to the target repositories, with Issues, Contents, and Pull requests set to read and write. Do not put it in tfvars or the Terraform state.
- AWS CLI v2 and permission to run `aws devops-agent register-service`.

The native GitHub integration is read-only, so Issue and PR creation needs the GitHub Model Context Protocol (MCP) server:

1. Register the MCP server at the account level with the AWS CLI (endpoint `https://api.githubcopilot.com/mcp/`, authorization header `Authorization: Bearer <PAT>`). The command example is in `terraform.example.tfvars` (`mcp_server_registrations`).
2. Set the returned service ID in `devops_agent.primary.mcp_server_registrations.<name>.service_id`.
3. Allowlist only the needed tools in `agent_spaces.<name>.mcp_servers`: `add_issue_comment`, `issue_write`, `issue_read`, `search_issues`, `get_label`, `create_branch`, `create_or_update_file`, `push_files`, `create_pull_request`, `pull_request_read`, `update_pull_request` (the full list is in `terraform.example.tfvars`). The current GitHub MCP server has no `create_issue`. Do not allowlist merge or delete tools.
4. Attach the skills (`agent_spaces.<name>.skills`) and, optionally, the custom agents (`agent_spaces.<name>.custom_agents`).

| Item                                                                                                       | Location                                                                                                                                                                                                                                                                                           |
| ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GitHub skill (Issue + Draft PR to `develop` or the default branch from a `feature/devops-agent/**` branch) | `terraform/monitor/devops_agent/skills/github-issue-draft-pr/`                                                                                                                                                                                                                                     |
| Linear skill (Linear Issue + Draft PR)                                                                     | `terraform/monitor/devops_agent/skills/linear-issue-draft-pr/`                                                                                                                                                                                                                                     |
| Custom agents using the skills                                                                             | `terraform/monitor/devops_agent/agents/github_issue_pr_agent.md`, `terraform/monitor/devops_agent/agents/linear_issue_pr_agent.md`                                                                                                                                                                 |
| Follow-up skill and agent (scheduled)                                                                      | `terraform/monitor/devops_agent/skills/github-issue-pr-followup/`, `terraform/monitor/devops_agent/agents/github_issue_pr_followup_agent.md`; Linear: `terraform/monitor/devops_agent/skills/linear-issue-pr-followup/`, `terraform/monitor/devops_agent/agents/linear_issue_pr_followup_agent.md` |
| Example configuration                                                                                      | `terraform.example.tfvars`; `terraform.dev.tfvars` enables the skills only. The MCP registration, `mcp_servers`, and custom agents stay commented out until the `service_id` is available.                                                                                                         |

#### Skill directory layout

Each skill is a directory named after the skill (kebab-case), following the layout of `.agents/skills/*`:

```text
devops_agent/skills/<skill-name>/
├── SKILL.md                      # Input, Output Specification, Execution Scope, Reference Files Guide, Workflow, Error Handling
├── references/                   # common-checklist.md, common-output-format.md
└── assets/                       # Issue / page / PR / comment templates
```

`content_file` points to `SKILL.md`. Terraform attaches the text files (`csv`, `json`, `md`, `txt`, `yaml`, `yml`) under `references/` and `assets/` in the same directory to the skill automatically. `SKILL.md` has no frontmatter because the name and description are passed as metadata. Scripts are not supported by AWS DevOps Agent.

#### Per-alarm suppression

To suppress future investigations of one alarm, comment on its `devops-agent` Issue. The follow-up skill records the decision in the memory `monitors-<alarm-name>` of the custom memory store `suppressions`, with `## Suppression: ACTIVE`.

- Custom agents can write only to the custom stores attached to them; the managed `directives` and `monitors` stores are read-only for them. Create the store with `memory_stores` and attach it to the follow-up agent with `custom_agents[*].memory_stores` (`terraform.prd.tfvars` sets both). Without them, the follow-up agent saves nothing and reports `memory write unavailable: suppressions`.
- A human can also record the same memory in the `directives` store with Chat. The investigation reads both stores.
- Write the reason in the comment, for example 「magaseek 解約済みのため今後チェック不要」. To lift the suppression, comment 「監視再開して」.
- On the next firing, the investigation reads the memory (rule in `devops_agent/agents_md/generic.md`) and stops early. It sends one Slack reply, creates no Issue, PR, or memory, and investigates further only when you ask in that investigation.
- Triage does not read this memory, so the investigation still starts and its short run is billed. The comment examples the follow-up skill classifies are in `devops_agent/skills/linear-issue-pr-followup/SKILL.md` (Human comment examples).

#### Issue and PR templates

- The Issue has a `Pull request` section. It holds the full PR URL with its state (`Draft`) when a PR was created, and `none (<reason>)` when none was created. The agent creates the Issue first with `none (PR not created yet)` and updates the section after the PR step, so the placeholder never remains.
- The PR body follows the sections of `.github/PULL_REQUEST_TEMPLATE.md` (Overview, Related Issues, Changes, Testing, Type of Change, Checklist, Additional Notes). `Related Issues` holds `Closes #<issue>` (a merge closes the Issue). The agent checks only the Checklist items it actually did.
- Section headings stay in English and the prose is written in the response language.

#### Label `devops-agent`

Every Issue and PR that the agent creates carries the label `devops-agent`. The follow-up agent handles only items with this label, and people can tell agent-created items by it.

- **GitHub: a person must create the label beforehand.** Creating a label needs Label creation permission in GitHub (write access to the repository), and the GitHub MCP server exposes no label-creation tool, so the agent cannot create it. Create it once in every target repository (color `1D76DB`) before the first investigation. When the label is missing, the agent still creates the Issue and PR, reports the missing label in the Issue/PR and in Slack reply B, and the follow-up agent never picks the item up. Adding the label to a PR uses `issue_write` with the PR number; this is not documented in the GitHub MCP server README, so verify it on the first run (when it fails, the agent reports the missing label).
- **Linear: the agent creates it.** The Linear skill checks the label with `list_issue_labels` and creates it with `save_issue_label` when it is missing. When the Linear credential has no permission to create labels, the agent creates no Issue (it would never be followed up) and reports the missing permission in reply B (`Failed`); create the label in Linear beforehand in that case.

#### Slack reply format

When the incident `description` has `slack_reply_target`, the agent replies to the alert thread. Reply A is sent by the investigation lead when the investigation starts, and reply B is sent by the agent that creates the Issue and PR once they are confirmed (also when none is created). Reply C (human escalation) is optional, at most once, and only when a person must decide or act. The lead copies the `slack_reply_target` line verbatim into the prompt of any sub-agent it delegates the record to, because a sub-agent does not see the incident description, and it checks that reply B was sent.

```text
[devops-agent] Investigation started
Incident: <Incident>
```

```text
[devops-agent] <New | Already tracked | No action | Failed>
Incident: <Incident>
Issue: <Issue URL | none (reason)>
PR: <PR URL | none (reason)> (<Draft | open | merged | closed>)
Root cause (<confirmed | suspected>): <one or two sentences>
Next: <next step for a human>
```

Issue and PR URLs are the full `html_url` returned by the tools (never only `#123`). `<Incident>` is the investigation URL when the agent can read it from its context, otherwise `incidentId=<id>`, otherwise `unknown`. The investigation URL format is not documented, so the agent does not build it.

#### Follow-up on replies (scheduled)

The generic webhook does not deliver Issue or PR comments, so the custom agent `github_issue_pr_followup_agent` runs on a schedule trigger (dev: hourly on weekdays 09:00-19:00 JST). It handles only open Issues and PRs with the label `devops-agent`:

- It finds human comments newer than its own latest comment (the footer line `-- devops-agent`), answers them in one comment per item, re-checks the incident read-only when needed, and updates the Issue or PR text.
- It commits only to the head branch (`feature/devops-agent/**`) of an open Draft PR, and only for a small change of the same kind as the original fix.
- It closes an Issue when a human explicitly asks for it or when the linked PR is merged. It closes a PR only on an explicit human request.
- It never merges, approves, marks a PR ready, force pushes, deletes branches, creates Issues/PRs/labels, or posts to Slack.

Cost note: each scheduled run consumes agent usage even when there are no unanswered comments. Adjust `schedule_expression` or set `status = "Inactive"` to stop it.

Behavior not verified in this repository:

- Webhook-started investigations use `GENERIC` skills, so the skills apply to them. Custom agents run from chat or schedule triggers only.
- Whether MCP tools that change data run without operator approval in webhook-started investigations. If they require approval (directed actions), create the Issue from the alarm Lambda (SNS → Lambda) and use the agent only for the Draft PR.
- The tool name format in the custom agent `tools` list (the examples assume `<MCP server name>_<tool name>`).

References: [Connecting MCP Servers](https://docs.aws.amazon.com/devopsagent/latest/userguide/configuring-integrations-and-knowledge-connecting-mcp-servers.html), [Working with directed actions](https://docs.aws.amazon.com/devopsagent/latest/userguide/working-with-devops-agent-working-with-directed-actions.html)

#### Linear (Linear MCP server)

The Linear skill records the Issue in Linear instead of GitHub. The PR is still a GitHub Draft PR, so the GitHub MCP server is also needed (its prerequisites above apply). The GitHub Draft PR links to the Issue by the Linear identifier (for example `ENG-123`) and the agent attaches the PR URL to the Issue.

1. Register the Linear MCP server (endpoint `https://mcp.linear.app/mcp`). It accepts OAuth, or an API key / token sent as `Authorization: Bearer <token>`. Register it like the GitHub MCP server or in the console (Capability Providers), and set the returned service ID in `devops_agent.primary.mcp_server_registrations.<name>.service_id`. Never put the credential in tfvars or the Terraform state.
2. Allowlist only the needed tools in `agent_spaces.<name>.mcp_servers`: `list_teams`, `list_issues`, `get_issue`, `save_issue`, `list_comments`, `save_comment`, `list_issue_labels`, `save_issue_label`, `list_issue_statuses`.
3. Set the Linear team in tfvars: `agent_spaces.<name>.linear = { team = "<team name or key>" }`. When it is set, Terraform appends a `## Linear` section (`Linear team: <team>`, and the rule to create Issues only in that team) to the GENERIC AGENTS.md of the Agent Space; `devops_agent/agents_md/generic.md` is not edited, and a GENERIC AGENTS.md is created when `agents_md` has none. The agent checks the team with `list_teams`, and when it does not exist it creates nothing, never uses another team, and reports `Failed`. `null` (the default) adds nothing.
4. Attach the skills `linear-issue-draft-pr` and `linear-issue-pr-followup` and the custom agents `linear_issue_pr_agent` and `linear_issue_pr_followup_agent`. The follow-up agent runs on a schedule trigger, handles only open Linear Issues of the configured team with the label `devops-agent` and the PRs linked from them, answers unanswered human comments with `save_comment` (footer `-- devops-agent`), and closes an Issue only on an explicit human instruction or when its PR is merged.

The `linear` block, the registration, `mcp_servers`, `skills`, and `custom_agents` examples are in `terraform.example.tfvars` (commented out in every environment until the `service_id` is available).

Not verified in this repository: the tool names with the prefix `LinearMcpServer_` in the custom agent `tools` list, whether the AWS DevOps Agent can complete the Linear OAuth flow (use an API key or token when it cannot), and which Linear permission is required to create a label with `save_issue_label`.

### Slack Reply MCP Server

The native Slack integration cannot reply to a specific existing message, and the Slack hosted MCP server posts under the authorizing user's name. A custom MCP server on Lambda replies to the alert thread as the same Bot that posts the alerts.

| Item       | Location                                                                                                                                                                                                 |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Terraform  | `terraform/monitor/main_central_lambda_devops_agent_mcp_slack_reply.tf` (Lambda function URL with IAM authentication) and `main_central_iam_lambda_devops_agent_mcp_slack_reply.tf` (dedicated IAM role) |
| Lambda zip | `lambda/outputs/go_mcp_slack_reply.zip` (request and specification: [Slack Reply MCP Lambda Request](mcp-slack-reply-lambda-request.md))                                                                 |
| Setting    | `devops_agent.primary.mcp_slack_reply` (`is_enabled`, `memory_size`, `timeout`); `terraform.dev.tfvars` enables it                                                                                       |
| Tool       | `slack_reply_to_thread` (`channel_id`, `thread_ts`, `text`); it cannot post a new message to a channel                                                                                                   |

The dedicated IAM role is separate from the Agent Space roles. It trusts the DevOps Agent service (`aws:SourceAccount` and `aws:SourceArn` conditions) and can only invoke this function URL, so the agent's AWS access does not extend to other functions.

The tool receives the channel ID and the thread timestamp as arguments (the agent reads them from the webhook `description`). As a guard against a misdirected reply, the Lambda accepts only the channels the alert Lambda functions post to (`slack.channel_id` and every `slack.override.*.channel_id`); Terraform derives this list, so there is nothing to configure.

Terraform registers the server in AWS DevOps Agent (`awscc_devopsagent_service`, type `mcpserversigv4`, signing service `lambda`, display name `McpSlackReply`) and attaches it to every Agent Space with the single tool `slack_reply_to_thread`, so `mcp_server_registrations` and `mcp_servers` need no entry for it. The registration validates the connection with the dedicated role, so Terraform waits 30 seconds for IAM propagation after the role is created. The output `devops_agent_mcp_slack_reply_service_id` shows the service ID. The key `mcp_slack_reply` is reserved in `agent_spaces.<name>.mcp_servers`.

The tool name in the custom agent `tools` list is assumed to be `McpSlackReply_slack_reply_to_thread` (`<server name>_<tool name>`). Verify it in the console.

The webhook sender Lambda must append `slack_reply_target: channel_id=<id> thread_ts=<ts>` to the incident `description`. The webhook does not pass `data` to the agent, so the value must be in `description`. The skills read this line and reply A and reply B to that thread in every investigation, whatever the outcome (new, already tracked, no action, failed); see [Slack reply format](#slack-reply-format).

The GitHub and Linear MCP servers are not registered by Terraform, because their credentials (a GitHub token, OAuth) would enter the Terraform state.

Not verified:

- Whether AWS DevOps Agent can call a function URL with IAM authentication (SigV4 service `lambda`), including whether its signature carries the `x-amz-content-sha256` header that function URLs may require for POST. If it cannot, use API Gateway (`execute-api`) or an API key.
- Which MCP protocol version AWS DevOps Agent speaks. The Lambda is requested to answer both the `2026-07-28` protocol and the legacy `initialize` handshake; the `info` log records what the agent sends.
- Whether the registration validation (`listTools`) succeeds against the deployed function.

### Generic Webhook

A generic webhook lets external systems start an investigation with an HTTP POST. Requests are signed with HMAC (`x-amzn-event-signature` and `x-amzn-event-timestamp` headers).

Reference: [Invoking DevOps Agent through Webhook](https://docs.aws.amazon.com/devopsagent/latest/userguide/configuring-integrations-and-knowledge-invoking-devops-agent-through-webhook.html)

#### Why the AWS CLI is used

| Step                               | Constraint                                                                                         | Implementation                                                                         |
| ---------------------------------- | -------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Register the event channel service | `AWS::DevOpsAgent::Service` (CloudFormation / awscc) does not support the `eventChannel` type      | `terraform_data.event_channel_service` runs `register-service` / `deregister-service`  |
| Create the webhook (association)   | The webhook secret is returned only once, by `AssociateService`; awscc (Cloud Control) discards it | `terraform_data.webhook_association` runs `associate-service` / `disassociate-service` |
| Read the webhook URL               | awscc does not expose the URL                                                                      | `data "external"` runs `list-associations` / `list-webhooks`                           |

Scripts: `modules/aws/devops_agent/scripts/event_channel_service.sh` and `webhook_association.sh`.

#### Where the secret goes

```text
terraform apply
  ├─ aws_secretsmanager_secret.webhook         (empty secret, e.g. base/devops-agent/webhook, created by Terraform)
  └─ terraform_data.webhook_association
       └─ aws devops-agent associate-service   (response contains the webhook secret)
            └─ aws secretsmanager put-secret-value   (secret written via a 0600 temp file, never argv/stdout)
```

- The secret value never enters the Terraform state, plan, outputs, or logs. Terraform manages the secret container only, not its versions.
- The secret is encrypted with the DevOps Agent KMS key when `kms.monitor_devops_agent.is_enabled` is `true`; otherwise with the AWS managed key `aws/secretsmanager`.
- Secret value (JSON):

  | Key              | Value                                                          |
  | ---------------- | -------------------------------------------------------------- |
  | `webhook_id`     | Webhook ID                                                     |
  | `webhook_secret` | HMAC signing secret (or the API key when the type is `apikey`) |
  | `webhook_type`   | `hmac` or `apikey`                                             |
  | `webhook_url`    | Webhook URL                                                    |

- The API does not let callers choose the authentication type. Check `webhook_type` after the first apply.

#### Outputs

| Output                             | Value                                                                              |
| ---------------------------------- | ---------------------------------------------------------------------------------- |
| `devops_agent_webhook_urls`        | Map: Agent Space name => webhook URL (POST target)                                 |
| `devops_agent_webhook_secret_arns` | Map: Agent Space name => ARN of the secret holding the credentials (not the value) |

Read the credentials:

```bash
aws secretsmanager get-secret-value \
  --secret-id "$(terraform output -json devops_agent_webhook_secret_arns | jq -r '."devops-agent"')" \
  --query SecretString --output text
```

The alert Lambda functions (`metric` and `log`) in every account send to the webhook of the primary account. Set `DEVOPS_AGENT_WEBHOOK_URL` (`devops_agent_webhook_urls` output) and `DEVOPS_AGENT_WEBHOOK_HMAC_SECRET` (`webhook_secret` in the secret) in `metric.aws_lambda_function.environment` and `log.aws_lambda_function.environment`. The HMAC secret is then stored in the tfvars and the Lambda environment, as `SLACK_OAUTH_ACCESS_TOKEN` already is. When the webhook is re-created, update both values in every account.

In the primary account, `DEVOPS_AGENT_LOCALE` (for example `ja-JP`) is injected automatically into the `metric` and `log` Lambda environments from `agent_spaces.<name>.locale` of the Agent Space that has `webhook.is_enabled = true` (the first by name when several; nothing is injected when `locale` is null). The Lambda code can use it to request the answer language in the webhook payload. Values set in `aws_lambda_function.environment` take priority. Secondary accounts have no Agent Space, so set `DEVOPS_AGENT_LOCALE` there in `aws_lambda_function.environment` when needed.

#### Lifecycle

| Operation                                                                                                                                     | Result                                                                                                       |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| First apply                                                                                                                                   | Event channel registered, webhook created, credentials stored in the secret                                  |
| Change of Agent Space / service / secret, or `terraform apply -replace='module.devops_agent["<name>"].terraform_data.webhook_association[0]'` | Webhook recreated: **URL and secret change**; new credentials stored as a new secret version; update senders |
| Rotate in the console                                                                                                                         | URL kept, secret changes, but **the Secrets Manager secret is not updated** (prefer `-replace` instead)      |
| Storing the secret fails                                                                                                                      | Apply fails; run `terraform apply` again (the webhook is recreated with a new secret)                        |
| `webhook.is_enabled = false` or destroy                                                                                                       | Webhook removed, event channel deregistered, secret scheduled for deletion (`recovery_window_in_days`)       |

#### Requirements where Terraform runs

- AWS CLI v2 with the `devops-agent` commands, and `jq`
- `aidevops:RegisterService`, `aidevops:DeregisterService`, `aidevops:ListServices`, `aidevops:AssociateService`, `aidevops:DisassociateService`, `aidevops:ListAssociations`, `aidevops:ListWebhooks`
- `secretsmanager:PutSecretValue` on the secret, and `kms:GenerateDataKey` on the KMS key when a customer managed key is used
