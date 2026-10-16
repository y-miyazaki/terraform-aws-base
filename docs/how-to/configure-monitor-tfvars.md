# Monitor Terraform Configuration Guide

## Overview

Configuration for **monitoring and observability**. Sets up CloudWatch alarms, log filters, EventBridge rules, and Athena queries with Slack notifications.

**Stack:** `terraform/monitor/`
**Example file:** [terraform.example.tfvars](https://github.com/y-miyazaki/terraform-aws-base/blob/main/terraform/monitor/terraform.example.tfvars)
**Initial setup:** See [Initial Setup (Common)](./initial-setup.md)

**Customization markers:** In `terraform.example.tfvars` (and env copies), search for `CUSTOMIZE` comments — they mark values that require environment-specific changes.

**Control Tower note:** Set `use_control_tower = true` to avoid conflicts with Control Tower-managed log groups.

## Required Settings

| Variable (tfvars path) | Description        | Example            |
| ---------------------- | ------------------ | ------------------ |
| `region`               | Primary AWS region | `"ap-northeast-1"` |

## Optional Settings

### Tags and Naming

| Variable (tfvars path) | Description          | Default     |
| ---------------------- | -------------------- | ----------- |
| `tags.env`             | Environment name     | `"example"` |
| `tags.service`         | Service/project name | `"base"`    |
| `name_prefix`          | Resource name prefix | `"base-"`   |

### CloudWatch Log Groups

Centralized retention management with per-service overrides.

```hcl
cloudwatch_log_group = {
  retention_in_days = 14
  kms_key_id       = null
  override = {
    metric_log_postgresql_slowquery = { retention_in_days = 30 }
    common_lambda_log              = { retention_in_days = 30 }
  }
}
```

<details markdown>
<summary>Available override services</summary>

| Service Name                             | Description                    | Recommended |
| ---------------------------------------- | ------------------------------ | ----------- |
| `cloudwatch_event_ec2`                   | EC2 events via EventBridge     | 7 days      |
| `common_lambda_log`                      | CloudWatch alarms to Slack     | 7–14 days   |
| `common_lambda_log_us_east_1`            | Same (us-east-1 failover)      | 7–14 days   |
| `common_lambda_metric`                   | Kinesis Data Firehose metrics  | 14 days     |
| `common_lambda_metric_us_east_1`         | Metrics Lambda (us-east-1)     | 14 days     |
| `common_lambda_ses`                      | SES alarms to Slack            | 7 days      |
| `common_lambda_ses_us_east_1`            | SES Lambda (us-east-1)         | 7 days      |
| `common_lambda_step_functions`           | Step Functions notifications   | 14 days     |
| `common_lambda_step_functions_us_east_1` | Step Functions (us-east-1)     | 14 days     |
| `common_lambda_vpc_flow_log`             | VPC Flow Logs processing       | 7 days      |
| `metric_log_application`                 | Application errors report      | 14 days     |
| `metric_log_postgresql_slowquery`        | PostgreSQL slow query analyzer | 14–30 days  |

</details>

### Slack Notifications

```hcl
slack = {
  oauth_access_token = "xoxb-..."
  channel_id         = "C0XXXXXXXXX"
  override = {
    common_lambda_log          = { channel_id = "C-ALERTS" }
    common_lambda_ses          = { channel_id = "C-EMAIL" }
    cloudwatch_event_ec2       = { channel_id = "C-INFRA" }
    common_lambda_step_functions = { channel_id = "C-DEVOPS" }
  }
}
```

<details markdown>
<summary>Available override functions</summary>

| Function Name                     | Description                               |
| --------------------------------- | ----------------------------------------- |
| `apigateway_report_csp`           | Content Security Policy violation reports |
| `cloudwatch_event_ec2`            | EC2 instance state changes                |
| `common_lambda_log`               | CloudWatch alarms → SNS → Slack           |
| `common_lambda_metric`            | Kinesis Data Firehose metrics             |
| `common_lambda_ses`               | CloudWatch alarms via SES                 |
| `common_lambda_step_functions`    | Step Functions execution logs             |
| `metric_log_application`          | Application errors report                 |
| `metric_log_postgresql_slowquery` | PostgreSQL slow query alerts              |

</details>

### Feature Toggles

#### Metrics Alarms

CloudWatch alarms that notify when thresholds are exceeded.

| Feature                | Variable (tfvars path)                                    | Default | Reference                                                                                                                |
| ---------------------- | --------------------------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------ |
| API Gateway            | `metric_resource_api_gateway.is_enabled`                  | `false` | [Docs](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-metrics-and-dimensions.html)             |
| CloudFront             | `metric_resource_cloudfront.is_enabled`                   | `false` | [Docs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/monitoring-using-cloudwatch.html)              |
| EC2                    | `metric_resource_ec2.is_enabled`                          | `false` | [Docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html)                         |
| ECS Container Insights | `metric_resource_ecs_container_insights.is_enabled`       | `false` | [Docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html)                            |
| ElastiCache            | `metric_resource_elasticache.is_enabled`                  | `false` | [Docs](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/CacheMetrics.html)                                    |
| ELB (ALB/NLB)          | `metric_resource_elb.is_enabled`                          | `false` | [Docs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html)        |
| EventBridge Scheduler  | `metric_resource_eventbridge_scheduler.is_enabled`        | `false` | [Docs](https://docs.aws.amazon.com/scheduler/latest/UserGuide/monitoring-overview.html)                                  |
| Lambda                 | `metric_resource_lambda.is_enabled`                       | `false` | [Docs](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics.html)                                             |
| NAT Gateway            | `metric_resource_nat_gateway.is_enabled`                  | `false` | [Docs](https://docs.aws.amazon.com/vpc/latest/userguide/metrics-dimensions-nat-gateway.html)                             |
| RDS                    | `metric_resource_rds_cluster.is_enabled`                  | `false` | [Docs](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/monitoring-cloudwatch.html)                                |
| Redshift               | `metric_resource_redshift.is_enabled`                     | `false` | [Docs](https://docs.aws.amazon.com/redshift/latest/mgmt/metrics-listing.html)                                            |
| SES                    | `metric_resource_ses.is_enabled`                          | `false` | [Docs](https://docs.aws.amazon.com/ses/latest/dg/event-publishing-retrieving-cloudwatch.html)                            |
| SNS                    | `metric_resource_sns.is_enabled`                          | `false` | [Docs](https://docs.aws.amazon.com/sns/latest/dg/sns-monitoring-using-cloudwatch.html)                                   |
| SQS (DLQ)              | `metric_resource_sqs_dlq.is_enabled`                      | `false` | [Docs](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-available-cloudwatch-metrics.html) |
| Synthetics Canary      | `metric_synthetics_canary.functions.heartbeat.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries.html)               |

#### Log Filters

CloudWatch Logs metric filters with Lambda → Slack notification.

| Feature               | Variable (tfvars path)                       | Default | Daily Report                             |
| --------------------- | -------------------------------------------- | ------- | ---------------------------------------- |
| Application           | `metric_log_application.is_enabled`          | `false` | `metric_log_application_report`          |
| MySQL slow query      | `metric_log_mysql_slowquery.is_enabled`      | `false` | —                                        |
| PostgreSQL            | `metric_log_postgresql.is_enabled`           | `false` | —                                        |
| PostgreSQL slow query | `metric_log_postgresql_slowquery.is_enabled` | `false` | `metric_log_postgresql_slowquery_report` |
| Step Functions        | `metric_log_step_functions.is_enabled`       | `false` | —                                        |
| WAF                   | `metric_log_waf.is_enabled`                  | `false` | —                                        |

To change the filter pattern or alarm settings of specific log groups, set `metric_log_application.log_group_override` (key: exact log group name). Each entry can set `enabled`, `pattern`, `threshold`, `evaluation_periods`, `datapoints_to_alarm`, and `period`; unspecified values fall back to the common `aws_cloudwatch_log_metric_filter` and `aws_cloudwatch_metric_alarm`. `pattern` replaces the whole filter pattern, so copy the common pattern and add the exclusions. `enabled = false` creates neither the metric filter nor the alarm for that log group.

#### EventBridge Events

| Feature              | Variable (tfvars path)            | Default |
| -------------------- | --------------------------------- | ------- |
| EC2 (Spot/Rebalance) | `cloudwatch_event_ec2.is_enabled` | `false` |

#### EventBridge Scheduler (Start/Stop)

Automatic resource scheduling (stop at night, start in morning).

| Feature            | Variable                                    | Default |
| ------------------ | ------------------------------------------- | ------- |
| Batch Job Queue    | `eventbridge.batch.is_enabled`              | `false` |
| EC2 Instance       | `eventbridge.ec2.is_enabled`                | `false` |
| ECS Service        | `eventbridge.ecs_service.is_enabled`        | `false` |
| ECS Scheduled Task | `eventbridge.ecs_scheduled_task.is_enabled` | `false` |
| RDS Cluster        | `eventbridge.rds_cluster.is_enabled`        | `false` |
| Redshift           | `eventbridge.redshift.is_enabled`           | `false` |

#### Other

| Feature                 | Variable                  | Default |
| ----------------------- | ------------------------- | ------- |
| Athena (CloudFront/SES) | `athena.is_enabled`       | `false` |
| Delivery Log (S3)       | `delivery_log.is_enabled` | `false` |
| Report CSP              | `report_csp.is_enabled`   | `false` |

### AWS DevOps Agent

| Setting                                                                           | Default | Description                                                                                                                                                                                                                                                                                                                              |
| --------------------------------------------------------------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `devops_agent.primary.is_enabled`                                                 | `false` | Host the Agent Spaces in this account. Independent of `devops_agent.secondary`; both can be enabled. See [Primary and Secondary Accounts](../reference/features-monitor.md#primary-and-secondary-accounts)                                                                                                                               |
| `devops_agent.primary.secondary_accounts`                                         | `{}`    | Map of secondary accounts the Agent Space investigates: `account_id` (12 digits). Add an account after its role exists                                                                                                                                                                                                                   |
| `devops_agent.secondary.is_enabled`                                               | `false` | Create only the read-only cross-account role `DevOpsAgentRole-SecondaryAccount` so that the Agent Space of the primary account can investigate this account                                                                                                                                                                              |
| `devops_agent.secondary.primary_account_id`                                       | `null`  | Required when `secondary.is_enabled`. Account ID of the primary account                                                                                                                                                                                                                                                                  |
| `devops_agent.secondary.primary_agent_space_arn`                                  | `null`  | Required when `secondary.is_enabled`. ARN of the Agent Space in the primary account (`terraform output -json devops_agent_agent_space_arns` in the primary account)                                                                                                                                                                      |
| `devops_agent.secondary.additional_policy_statements`                             | `[]`    | Extra IAM statements for the cross-account role on top of `AIDevOpsAgentAccessPolicy` (never allow `secretsmanager:GetSecretValue`)                                                                                                                                                                                                      |
| `kms.monitor_devops_agent.is_enabled`                                             | `false` | One KMS key shared by all Agent Spaces (and the webhook secrets), declared in the `kms` variable next to `kms.monitor`; immutable after an Agent Space is created                                                                                                                                                                        |
| `devops_agent.primary.github_registrations`                                       | `{}`    | Map of GitHub registrations (account level, one per GitHub user / organization / GitHub Enterprise Server instance, registered in the console first): `service_id`, `owner`, `owner_type`                                                                                                                                                |
| `devops_agent.primary.mcp_slack_reply`                                            | `{}`    | Slack reply MCP server (Lambda function URL + dedicated IAM role): `is_enabled` (`false`), `memory_size` (`128`), `timeout` (`30`). Terraform also registers it in AWS DevOps Agent and attaches it to every Agent Space with the tool `slack_reply_to_thread` (no entry in `mcp_servers` needed; the key `mcp_slack_reply` is reserved) |
| `devops_agent.primary.mcp_server_registrations`                                   | `{}`    | Map of MCP server registrations (account level; e.g. GitHub MCP server for Issue / Draft PR, Notion / Linear MCP server): `service_id`, `name`, `endpoint`, `description`. Register with `aws devops-agent register-service --service mcpserver` first (credential never enters the state)                                               |
| `devops_agent.primary.agent_spaces`                                               | `{}`    | Map keyed by the Agent Space name (`name_prefix` prepended); `module.devops_agent` is called with `for_each`                                                                                                                                                                                                                             |
| `devops_agent.primary.agent_spaces.<name>.is_enabled`                             | `true`  | Create this Agent Space (also requires `devops_agent.primary.is_enabled`)                                                                                                                                                                                                                                                                |
| `devops_agent.primary.agent_spaces.<name>.github_repositories`                    | `{}`    | GitHub repositories associated with this Agent Space; `github_registration` refers to a key of `devops_agent.primary.github_registrations`                                                                                                                                                                                               |
| `devops_agent.primary.agent_spaces.<name>.mcp_servers`                            | `{}`    | MCP servers associated with the Agent Space (tool allowlist); `mcp_server_registration` refers to a key of `devops_agent.primary.mcp_server_registrations`, `tools` is the allowed tool names                                                                                                                                            |
| `devops_agent.primary.agent_spaces.<name>.agents_md`                              | `{}`    | Agent instructions (AGENTS.md) injected into every session. Key: agent type (`GENERIC` = all agents; at most one per agent type); `content_file` and `content_files` are relative to `terraform/monitor` and concatenated in order (one file per rule category, e.g. `devops_agent/agents_md/incident-suppression/scheduled-stop.md` for alarms that must not be listed as incidents); Markdown only, max 25 KB in total                                                                                 |
| `devops_agent.primary.agent_spaces.<name>.linear.team`                            | `null`  | Linear team (name or key) for Issues created with the Linear MCP server. When set, Terraform appends a `## Linear` section to the GENERIC AGENTS.md (created when `agents_md` has none); `generic.md` is not edited                                                                                                                      |
| `devops_agent.primary.agent_spaces.<name>.skills`                                 | `{}`    | Skills (`content_file` is the `SKILL.md` of a skill directory, relative to `terraform/monitor`, e.g. `devops_agent/skills/github-issue-draft-pr/SKILL.md`; text files under `references/` and `assets/` in that directory are attached automatically)                                                                                    |
| `devops_agent.primary.agent_spaces.<name>.custom_agents`                          | `{}`    | Custom agents with schedule triggers                                                                                                                                                                                                                                                                                                     |
| `devops_agent.primary.agent_spaces.<name>.webhook.is_enabled`                     | `false` | Generic webhook (HMAC)                                                                                                                                                                                                                                                                                                                   |
| `devops_agent.primary.agent_spaces.<name>.webhook.secret.recovery_window_in_days` | `7`     | Days before the secret is deleted after destroy (`0` or `7`-`30`)                                                                                                                                                                                                                                                                        |

Names derived from the Agent Space name (map key):

| Resource                             | Name                                                                            |
| ------------------------------------ | ------------------------------------------------------------------------------- |
| Agent Space                          | `<name_prefix><name>` (e.g. `base-devops-agent`)                                |
| IAM roles                            | `<name_prefix><name>-agent-space-role`, `<name_prefix><name>-operator-app-role` |
| Event channel registration (webhook) | `<name_prefix><name>-webhook`                                                   |
| Webhook secret (Secrets Manager)     | `<name_prefix without "-">/<name>/webhook` (e.g. `base/devops-agent/webhook`)   |

Renaming a key recreates the Agent Space and everything in it (the investigation history is lost).

The webhook secret is returned only once when the webhook is created. Terraform creates the webhook with the AWS CLI and writes the credentials directly to the Secrets Manager secret, so the secret never enters the Terraform state or tfvars. After apply, use the outputs `devops_agent_webhook_urls` and `devops_agent_webhook_secret_arns` (maps keyed by the Agent Space name). The AWS CLI v2 and `jq` must be installed where Terraform runs. See [AWS DevOps Agent](../reference/features-monitor.md#aws-devops-agent) for the flow, lifecycle, and required permissions.

### use_control_tower

Set to `true` to disable services conflicting with Control Tower. Automatically disables: CloudTrail, GuardDuty, Security Hub, Config, IAM password notifications.

## Environment Examples

| Setting (tfvars path)                     | Development | Staging             | Production          |
| ----------------------------------------- | ----------- | ------------------- | ------------------- |
| `metric_resource_lambda.is_enabled`       | `false`     | `true` (errors ≤ 1) | `true` (errors = 0) |
| `metric_resource_rds_cluster.is_enabled`  | `false`     | `true` (CPU ≤ 80%)  | `true` (CPU ≤ 70%)  |
| `metric_log_application.is_enabled`       | `true`      | `true`              | `true`              |
| `athena.is_enabled`                       | `false`     | `false`             | `true`              |
| `cloudwatch_log_group.retention_in_days`  | `7`         | `14`                | `14`                |
| Monitoring intervals (per-alarm `period`) | Relaxed     | Standard            | Strict              |

## Validation Checklist

| Category    | Check                                                                   |
| ----------- | ----------------------------------------------------------------------- |
| Monitoring  | Enable appropriate services for your environment                        |
| Resources   | Lambda/RDS/ALB thresholds match workload patterns                       |
| Logs        | Log group names configured or auto-discovery enabled                    |
| Logs        | Exclusion patterns reduce noise                                         |
| Analytics   | Athena S3 bucket paths are correct                                      |
| Cost        | Unused services disabled                                                |
| Cost        | Synthetics Canary schedules cost-efficient                              |
| Slack       | Test notifications with a simple alert first                            |
| Integration | S3 permissions for log delivery confirmed                               |
| Integration | IAM permissions for all monitoring services validated                   |
| Integration | AWS CLI v2 and jq installed where Terraform runs (DevOps Agent webhook) |
| Security    | DevOps Agent webhook secret read from Secrets Manager, not tfvars       |

## Related Documents

- [Initial Setup (Common)](./initial-setup.md) — S3 state bucket, IAM user creation
- [Base Terraform Configuration Guide](./configure-base-tfvars.md) — Base stack
- [Management Root Terraform Configuration Guide](./configure-management-root-tfvars.md) — Root account
- [Management Audit Terraform Configuration Guide](./configure-management-audit-tfvars.md) — Audit account
- [Monitoring](../reference/monitoring.md) — Alert architecture and runbooks
- [Troubleshooting](./troubleshooting.md) — Common issues and resolution
