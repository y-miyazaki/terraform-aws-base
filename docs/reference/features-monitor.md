# Monitor Features Detail

Detailed descriptions for features managed by `terraform/monitor/`. For configuration, see [configure-monitor-tfvars.md](../how-to/configure-monitor-tfvars.md).

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

![Named Query](../../image/athena_named_query.png)

### CloudFront

If you are using CloudFront to store your standard logs in S3, you can retrieve the logs from Athena using SQL. When the Athena function is enabled, a table is created for CloudFront and a named query is created for easy searching.

Reference: [Configuring and using standard logs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html)

![CloudFront](../../image/athena_cloudfront.png)

### SES

If you are using SES to store your standard logs in S3, you can retrieve the logs from Athena using SQL. When the Athena function is enabled, a table is created for SES and a named query is created for easy searching.

![SES](../../image/athena_ses.png)
