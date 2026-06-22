# Monitor Terraform Configuration Guide

## Overview

Configuration for **monitoring and observability**. Sets up CloudWatch alarms, log filters, EventBridge rules, and Athena queries with Slack notifications.

**Stack:** `terraform/monitor/`
**Example file:** [terraform.example.tfvars](https://github.com/y-miyazaki/terraform-aws-base/blob/main/terraform/monitor/terraform.example.tfvars)
**Initial setup:** See [Initial Setup (Common)](./initial-setup.md)

**Control Tower note:** Set `use_control_tower = true` to avoid conflicts with Control Tower-managed log groups.

## Required Settings

| Variable (tfvars path) | Description | Example |
|----------|-------------|---------|
| `region` | Primary AWS region | `"ap-northeast-1"` |

## Optional Settings

### Tags and Naming

| Variable (tfvars path) | Description | Default |
|----------|-------------|---------|
| `tags.env` | Environment name | `"example"` |
| `tags.service` | Service/project name | `"base"` |
| `name_prefix` | Resource name prefix | `"base-"` |

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

| Service Name | Description | Recommended |
|-------------|-------------|-------------|
| `cloudwatch_event_ec2` | EC2 events via EventBridge | 7 days |
| `common_lambda_log` | CloudWatch alarms to Slack | 7–14 days |
| `common_lambda_log_us_east_1` | Same (us-east-1 failover) | 7–14 days |
| `common_lambda_metric` | Kinesis Data Firehose metrics | 14 days |
| `common_lambda_metric_us_east_1` | Metrics Lambda (us-east-1) | 14 days |
| `common_lambda_ses` | SES alarms to Slack | 7 days |
| `common_lambda_ses_us_east_1` | SES Lambda (us-east-1) | 7 days |
| `common_lambda_step_functions` | Step Functions notifications | 14 days |
| `common_lambda_step_functions_us_east_1` | Step Functions (us-east-1) | 14 days |
| `common_lambda_vpc_flow_log` | VPC Flow Logs processing | 7 days |
| `metric_log_application` | Application errors report | 14 days |
| `metric_log_postgresql_slowquery` | PostgreSQL slow query analyzer | 14–30 days |

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

| Function Name | Description |
|--------------|-------------|
| `apigateway_report_csp` | Content Security Policy violation reports |
| `cloudwatch_event_ec2` | EC2 instance state changes |
| `common_lambda_log` | CloudWatch alarms → SNS → Slack |
| `common_lambda_metric` | Kinesis Data Firehose metrics |
| `common_lambda_ses` | CloudWatch alarms via SES |
| `common_lambda_step_functions` | Step Functions execution logs |
| `metric_log_application` | Application errors report |
| `metric_log_postgresql_slowquery` | PostgreSQL slow query alerts |

</details>

### Feature Toggles

#### Metrics Alarms

CloudWatch alarms that notify when thresholds are exceeded.

| Feature | Variable (tfvars path) | Default | Reference |
|---------|----------|---------|-----------|
| API Gateway | `metric_resource_api_gateway.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-metrics-and-dimensions.html) |
| CloudFront | `metric_resource_cloudfront.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/monitoring-using-cloudwatch.html) |
| EC2 | `metric_resource_ec2.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html) |
| ECS Container Insights | `metric_resource_ecs_container_insights.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html) |
| ElastiCache | `metric_resource_elasticache.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/CacheMetrics.html) |
| ELB (ALB/NLB) | `metric_resource_elb.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html) |
| EventBridge Scheduler | `metric_resource_eventbridge_scheduler.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/scheduler/latest/UserGuide/monitoring-overview.html) |
| Lambda | `metric_resource_lambda.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics.html) |
| NAT Gateway | `metric_resource_nat_gateway.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/vpc/latest/userguide/metrics-dimensions-nat-gateway.html) |
| RDS | `metric_resource_rds_cluster.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/monitoring-cloudwatch.html) |
| Redshift | `metric_resource_redshift.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/redshift/latest/mgmt/metrics-listing.html) |
| SES | `metric_resource_ses.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/ses/latest/dg/event-publishing-retrieving-cloudwatch.html) |
| SNS | `metric_resource_sns.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/sns/latest/dg/sns-monitoring-using-cloudwatch.html) |
| SQS (DLQ) | `metric_resource_sqs_dlq.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-available-cloudwatch-metrics.html) |
| Synthetics Canary | `metric_synthetics_canary.functions.heartbeat.is_enabled` | `false` | [Docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries.html) |

#### Log Filters

CloudWatch Logs metric filters with Lambda → Slack notification.

| Feature | Variable (tfvars path) | Default | Daily Report |
|---------|----------|---------|--------------|
| Application | `metric_log_application.is_enabled` | `false` | `metric_log_application_report` |
| MySQL slow query | `metric_log_mysql_slowquery.is_enabled` | `false` | — |
| PostgreSQL | `metric_log_postgresql.is_enabled` | `false` | — |
| PostgreSQL slow query | `metric_log_postgresql_slowquery.is_enabled` | `false` | `metric_log_postgresql_slowquery_report` |
| Step Functions | `metric_log_step_functions.is_enabled` | `false` | — |
| WAF | `metric_log_waf.is_enabled` | `false` | — |

#### EventBridge Events

| Feature | Variable (tfvars path) | Default |
|---------|----------|---------|
| EC2 (Spot/Rebalance) | `cloudwatch_event_ec2.is_enabled` | `false` |

#### EventBridge Scheduler (Start/Stop)

Automatic resource scheduling (stop at night, start in morning).

| Feature | Variable | Default |
|---------|----------|---------|
| Batch Job Queue | `eventbridge.batch.is_enabled` | `false` |
| EC2 Instance | `eventbridge.ec2.is_enabled` | `false` |
| ECS Service | `eventbridge.ecs_service.is_enabled` | `false` |
| ECS Scheduled Task | `eventbridge.ecs_scheduled_task.is_enabled` | `false` |
| RDS Cluster | `eventbridge.rds_cluster.is_enabled` | `false` |
| Redshift | `eventbridge.redshift.is_enabled` | `false` |

#### Other

| Feature | Variable | Default |
|---------|----------|---------|
| Athena (CloudFront/SES) | `athena.is_enabled` | `false` |
| Delivery Log (S3) | `delivery_log.is_enabled` | `false` |
| Report CSP | `report_csp.is_enabled` | `false` |

### use_control_tower

Set to `true` to disable services conflicting with Control Tower. Automatically disables: CloudTrail, GuardDuty, Security Hub, Config, IAM password notifications.

## Environment Examples

| Setting (tfvars path) | Development | Staging | Production |
|---------|-------------|---------|------------|
| `metric_resource_lambda.is_enabled` | `false` | `true` (errors ≤ 1) | `true` (errors = 0) |
| `metric_resource_rds_cluster.is_enabled` | `false` | `true` (CPU ≤ 80%) | `true` (CPU ≤ 70%) |
| `metric_log_application.is_enabled` | `true` | `true` | `true` |
| `athena.is_enabled` | `false` | `false` | `true` |
| `cloudwatch_log_group.retention_in_days` | `7` | `14` | `14` |
| Monitoring intervals (per-alarm `period`) | Relaxed | Standard | Strict |

## Validation Checklist

| Category | Check |
|----------|-------|
| Monitoring | Enable appropriate services for your environment |
| Resources | Lambda/RDS/ALB thresholds match workload patterns |
| Logs | Log group names configured or auto-discovery enabled |
| Logs | Exclusion patterns reduce noise |
| Analytics | Athena S3 bucket paths are correct |
| Cost | Unused services disabled |
| Cost | Synthetics Canary schedules cost-efficient |
| Slack | Test notifications with a simple alert first |
| Integration | S3 permissions for log delivery confirmed |
| Integration | IAM permissions for all monitoring services validated |

## Related Documents

- [Initial Setup (Common)](./initial-setup.md) — S3 state bucket, IAM user creation
- [Base Terraform Configuration Guide](./configure-base-tfvars.md) — Base stack
- [Management Root Terraform Configuration Guide](./configure-management-root-tfvars.md) — Root account
- [Management Audit Terraform Configuration Guide](./configure-management-audit-tfvars.md) — Audit account
- [Monitoring](../reference/monitoring.md) — Alert architecture and runbooks
- [Troubleshooting](./troubleshooting.md) — Common issues and resolution
