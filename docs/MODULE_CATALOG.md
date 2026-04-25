# Module Catalog

All reusable Terraform modules under `modules/aws/`. This document helps AI assistants locate the correct module for a given task.

## Security Modules

| Module | Path | Used by | Purpose |
| --- | --- | --- | --- |
| access_analyzer | security/access_analyzer | management/audit | IAM Access Analyzer (ORGANIZATION/ACCOUNT type) |
| guardduty | security/guardduty | base | GuardDuty detector per-account |
| guardduty_organization | security/guardduty_organization | management/audit | GuardDuty organization configuration |
| securityhub | security/securityhub | base | Security Hub per-account |
| securityhub_organization | security/securityhub_organization | management/audit | Security Hub organization config + policy |
| inspector2_organization | security/inspector2_organization | management/audit | Inspector2 organization enablement |
| config | security/config | base | AWS Config rules and recorder |
| cloudtrail | security/cloudtrail | management/root | Organization CloudTrail |
| iam | security/iam | base | IAM password policy, account alias |
| default_vpc | security/default_vpc | base | Default VPC hardening |
| ebs | security/ebs | base | EBS default encryption, snapshot public access block |
| ec2_metadata | security/ec2_metadata | base | IMDSv2 enforcement (account-level default) |
| ecr | security/ecr | base | ECR basic scan type (AWS native) |
| ssm_automation | security/ssm_automation | base | SSM automation documents |
| athena | security/athena | base | Athena workgroup for security queries |

## Monitoring Modules

### Metric Modules (modules/aws/metric/)

Each metric module creates CloudWatch alarms + SNS notification for a specific AWS service.

| Module | Monitored Service |
| --- | --- |
| ec2 | EC2 instances (CPU, status checks, disk) |
| rds_cluster | RDS Aurora clusters |
| elb | ALB/NLB (5xx, latency, unhealthy targets) |
| lambda | Lambda (errors, duration, throttles) |
| nat_gateway | NAT Gateway (bandwidth, packets, errors) |
| elasticache | ElastiCache (CPU, memory, connections) |
| cloudfront | CloudFront (error rate, requests) |
| api_gateway | API Gateway (4xx, 5xx, latency) |
| ses | SES (bounce, complaint rates) |
| synthetics_canary | Synthetics Canary (success rate) |
| sqs | SQS (queue depth, age of oldest message) |
| sns | SNS (delivery failures) |
| redshift | Redshift (CPU, disk, connections) |
| ecs_container_insights | ECS Container Insights metrics |
| eventbridge_scheduler | EventBridge Scheduler (invocations, failures) |

### EventBridge Modules (modules/aws/eventbridge/)

| Module | Purpose |
| --- | --- |
| ec2 | EC2 spot interruption, rebalance events |
| ecs_scheduled_task | ECS scheduled task events |
| ecs_service | ECS service events |
| batch | AWS Batch job events |
| redshift | Redshift cluster events |
| rds_cluster | RDS cluster events |

### CloudWatch Modules (modules/aws/cloudwatch/)

| Module | Purpose |
| --- | --- |
| alarm | CloudWatch alarm creation |
| event | CloudWatch event rules |
| events | CloudWatch events (legacy) |
| subscription | Log subscription filters |
| delivery | CloudWatch log delivery to S3 |

## Infrastructure Modules

| Module | Path | Purpose |
| --- | --- | --- |
| vpc/subnet | vpc/subnet | Subnet creation |
| vpc/endpoint | vpc/endpoint | VPC endpoints |
| iam/user_group | iam/user_group | IAM user and group management |
| iam/group | iam/group | IAM group creation |
| iam/role | iam/role | IAM role creation |
| iam/policy | iam/policy | IAM policy creation |
| iam/switch_role | iam/switch_role | Cross-account switch role |
| budgets/create-v4 | budgets/create-v4 | AWS Budgets with Slack notification |
| lambda/vpc | lambda/vpc | Lambda in VPC with ENI management |
| chatbot/create | chatbot/create | AWS Chatbot Slack integration |
| chatbot/security | chatbot/security | Security event to Chatbot routing |
| organizations/delegated_services | organizations/delegated_services | Check delegated admin status |
| sns/subscription | sns/subscription | SNS subscription management |
| s3/bucket_policy | s3/bucket_policy | S3 bucket policy management |
| kinesis/firehose | kinesis/firehose | Kinesis Firehose delivery stream |
| synthetics_canary | synthetics_canary | CloudWatch Synthetics canary |
| compute_optimizer | compute_optimizer | Compute Optimizer enrollment |
| resource_groups | resource_groups | Resource group by tags |
| athena | athena | Athena named queries (CloudFront, SES logs) |
| api_gateway/create | api_gateway/create | API Gateway creation |
| api_gateway/report_csp | api_gateway/report_csp | CSP violation report endpoint |

## Internal Modules (modules/aws/_internal/)

Shared helpers not intended for direct use:

| Module | Purpose |
| --- | --- |
| metric_helper | Common metric alarm creation logic |
| eventbridge_scheduler_helper | EventBridge Scheduler common patterns |
| auto_discovery_filter | Auto-discovery filter for metric targets |
