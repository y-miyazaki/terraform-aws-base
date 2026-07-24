# Monitoring

Alert configuration, dashboards, and operational runbooks for the `terraform/monitor/` stack.

## Overview

The monitoring stack provides CloudWatch-based observability for AWS workloads. It covers three pillars:

- **Log monitoring** — CloudWatch Logs metric filters with Slack notifications via Lambda
- **Metric monitoring** — CloudWatch alarms on service-specific metrics with SNS routing
- **Event monitoring** — EventBridge rules for service state changes with Slack notifications

All monitoring resources are toggled via `is_enabled` flags in `terraform/monitor/terraform.example.tfvars`.

## Prerequisites

- Slack workspace with an app configured (OAuthToken + ChannelID)
- SNS topics for alarm routing (created by the monitor stack)
- Lambda functions deployed from `nodejs/` and `lambda/` directories
- CloudWatch Log Groups for target services must exist before enabling log filters

## Alerts

### Metric Alarms

| Service                | Metrics Monitored                      | Notification |
| ---------------------- | -------------------------------------- | ------------ |
| EC2                    | CPU, status checks, disk               | SNS → Slack  |
| RDS                    | CPU, connections, free storage         | SNS → Slack  |
| ELB (ALB/NLB)          | 5xx errors, latency, unhealthy targets | SNS → Slack  |
| Lambda                 | Errors, duration, throttles            | SNS → Slack  |
| NAT Gateway            | Bandwidth, packets, errors             | SNS → Slack  |
| ElastiCache            | CPU, memory, connections               | SNS → Slack  |
| CloudFront             | Error rate, requests                   | SNS → Slack  |
| API Gateway            | 4xx, 5xx, latency                      | SNS → Slack  |
| SES                    | Bounce rate, complaint rate            | SNS → Slack  |
| SQS                    | Queue depth, age of oldest message     | SNS → Slack  |
| SNS                    | Delivery failures                      | SNS → Slack  |
| Redshift               | CPU, disk, connections                 | SNS → Slack  |
| ECS Container Insights | CPU utilization, memory, running tasks | SNS → Slack  |
| EventBridge Scheduler  | Invocations, failures, throttles       | SNS → Slack  |
| Synthetics Canary      | Success rate                           | SNS → Slack  |

### Log Filter Alarms

| Log Source     | Filter Pattern                 | Notification   |
| -------------- | ------------------------------ | -------------- |
| Application    | Custom filter patterns per app | Lambda → Slack |
| MySQL          | Slow query patterns            | Lambda → Slack |
| PostgreSQL     | Error and slow query patterns  | Lambda → Slack |
| Step Functions | Execution failure patterns     | Lambda → Slack |
| WAF            | Blocked request patterns       | Lambda → Slack |

### EventBridge Events

| Event Source  | Events Monitored                             | Notification   |
| ------------- | -------------------------------------------- | -------------- |
| EC2           | Spot interruption, rebalance recommendation  | Lambda → Slack |
| ECS Service   | Deployment state, task placement failures    | Lambda → Slack |
| ECS Scheduled | Scheduled task execution status              | Lambda → Slack |
| Batch         | Job state changes (FAILED, SUCCEEDED)        | Lambda → Slack |
| RDS Cluster   | Failover, maintenance, configuration changes | Lambda → Slack |
| Redshift      | Maintenance, snapshot, configuration changes | Lambda → Slack |

## Architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                    terraform/monitor/                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  CloudWatch Metrics ──► CloudWatch Alarm ──► SNS ──► Lambda     │
│                                                      ↓          │
│  CloudWatch Logs ──► Metric Filter ──► Lambda ──► Slack         │
│                                                                 │
│  EventBridge ──► Rule/Scheduler ──► Lambda ──► Slack            │
│                                                                 │
│  Athena ──► Named Queries (CloudFront, SES log analysis)        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Implementation Details

### Multi-Region Support

Monitoring resources use AWS Provider v6's `region` attribute for explicit region placement:

- Regional monitors: `for_each = toset(var.region.targets)` with `region = each.value`
- Global monitors (e.g., CloudFront metrics): `region = var.region.global`

No provider aliases or dual-file patterns are used. See [ADR-0001: Multi-Region Terraform Architecture Using AWS Provider v6 Region Attribute](../adr/0001-multi-region-terraform-architecture.md) for the architecture decision.

### Lambda Notification Functions

Lambda functions handle Slack message formatting and delivery:

- **Standard Lambda** — Direct invocation from CloudWatch/EventBridge
- **VPC Lambda** — For functions requiring VPC access (e.g., internal endpoint checks)

Lambda configurations are placed based on the service they support:

- Global service Lambda: `main_central_*.tf` with `region = var.region.global`
- Regional service Lambda: `main_regional_*.tf` with `region = each.value`
- Lambda VPC: `main_central_lambda_vpc.tf` with `region = var.region.global`

### Daily Report Functions

Scheduled aggregation reports via EventBridge Scheduler:

- **Application error report** — Daily summary of application log errors
- **PostgreSQL slow query report** — Daily summary of slow queries

### Athena Integration

Named queries for ad-hoc log analysis:

- CloudFront access log queries
- SES event log queries

## Configuration

Enable monitoring features in `terraform/monitor/terraform.example.tfvars`:

```hcl
# Metric alarms
metric_resource_ec2 = {
  is_enabled = true
  resources = [
    {
      name       = "web-server"
      instance_id = "i-0123456789abcdef0"
    }
  ]
}

# Log filters
metric_log_application = {
  is_enabled = true
  log_groups = [
    {
      name           = "/app/web"
      filter_pattern = "ERROR"
    }
  ]
}

# EventBridge events
eventbridge_scheduler_ecs_service = {
  is_enabled = true
}
```

## Runbooks

### High CPU Alarm (EC2/RDS/ECS)

1. Check CloudWatch metrics for the resource to confirm sustained high CPU.
2. Review recent deployments or traffic changes.
3. Scale up (instance type change) or scale out (add instances/tasks).
4. If caused by a specific process, investigate application logs.

### Lambda Error Alarm

1. Check Lambda CloudWatch Logs for error details:

```sh
aws logs filter-log-events \
  --log-group-name "/aws/lambda/<function-name>" \
  --filter-pattern "ERROR" \
  --start-time $(date -d '1 hour ago' +%s000)
```

2. Check for timeout issues (increase `timeout` in tfvars if needed).
3. Check for permission issues (IAM role policy).
4. Redeploy if code change is needed.

### Slack Notification Failure

1. Verify Lambda execution in CloudWatch Logs.
2. Check Slack app token validity.
3. Confirm the Slack channel still exists and the app is a member.
4. See [Troubleshooting](../how-to/troubleshooting.md) for detailed resolution steps.

## Cross-References

- [Terraform Specification](./specification.md) — Module contracts for metric modules
- [Module Catalog](./module-catalog.md) — Full list of monitoring modules
- [Architecture Overview](../explanation/architecture.md) — Overall system structure
- [Troubleshooting](../how-to/troubleshooting.md) — Common issues and resolutions
