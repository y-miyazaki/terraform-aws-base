# Base Terraform Configuration Guide

## Overview

Configuration for **member accounts** (individual AWS accounts where workloads run). Manages account-level security baselines, IAM, and optional integrations.

**Stack:** `terraform/base/`
**Example file:** [terraform.example.tfvars](../../terraform/base/terraform.example.tfvars)
**Initial setup:** See [initial-setup.md](./initial-setup.md)

**Control Tower integration:** Set `control_tower.is_enabled = true` to disable security services that are centrally managed by the management/audit account.

## Required Settings

These must be changed before `terraform apply` — the example values will cause failures.

| Variable (tfvars path) | Description | Example |
|------------------------|-------------|---------|
| `region` | Primary AWS region for resources | `"ap-northeast-1"` |
| `security_iam.support_iam_role_principal_arns` | IAM principals for Support role (CIS 1.20) | `["arn:aws:iam::123456789012:root"]` |
| `budgets.aws_budgets_budget.notification[].subscriber_email_addresses` | Email for budget threshold notifications | `["you@example.com"]` |

## Optional Settings

These have sensible defaults but should be customized per environment.

### Tags and Naming

| Variable (tfvars path) | Description | Default |
|----------|-------------|---------|
| `tags.env` | Environment name for cost allocation | `"example"` |
| `tags.service` | Service/project name | `"base"` |
| `name_prefix` | Prefix for all resource names | `"base-"` |

### CloudWatch Log Groups

Centralized retention management with per-service overrides.

```hcl
cloudwatch_log_group = {
  retention_in_days = 14      # Default for all services
  kms_key_id       = null     # null = AWS managed key
  override = {
    security_cloudtrail = { retention_in_days = 90 }
    guardduty           = { retention_in_days = 30 }
  }
}
```

**Priority order:** `override.<service>` > `retention_in_days` (default)

<details>
<summary>Available override services</summary>

| Service Name | Description | Recommended Retention |
|-------------|-------------|----------------------|
| `budgets` | Budget alerts | 7 days |
| `common_lambda_vpc_flow_log` | VPC Flow Logs processing | 7 days |
| `guardduty` | GuardDuty findings | 30 days |
| `health` | AWS Health events (regional) | 14 days |
| `health_us_east_1` | AWS Health events (global) | 14 days |
| `iam_password_expired` | Password expiration notifications | 14 days |
| `security_cloudtrail` | CloudTrail audit logs | 90 days |
| `security_config` | Config compliance (regional) | 30 days |
| `security_config_us_east_1` | Config compliance (us-east-1) | 30 days |
| `security_securityhub` | Security Hub findings | 30 days |
| `trusted_advisor` | Trusted Advisor recommendations | 14 days |

</details>

### Slack Notifications

Centralized Slack configuration with per-function channel overrides.

```hcl
slack = {
  oauth_access_token = "xoxb-..."    # Bot token from Slack app
  channel_id         = "C0XXXXXXXXX" # Default notification channel
  override = {
    guardduty           = { channel_id = "C-SECURITY" }
    security_cloudtrail = { channel_id = "C-AUDIT" }
    budgets             = { channel_id = "C-FINANCE" }
  }
}
```

**Priority order:** `override.<function>` > `channel_id` (default)

<details>
<summary>Available override functions</summary>

| Function Name | Description |
|--------------|-------------|
| `budgets` | Budget alerts |
| `guardduty` | GuardDuty findings |
| `health` | AWS Health events |
| `iam_password_expired` | Password expiration warnings |
| `security_cloudtrail` | CloudTrail security events |
| `security_config` | Config compliance changes |
| `security_config_us_east_1` | Config for CloudFront (us-east-1) |
| `trusted_advisor` | Trusted Advisor checks |

</details>

### Feature Toggles

Each feature has an `is_enabled` flag. Set to `false` to disable.

| Feature | Variable (tfvars path) | Default | Notes |
|---------|----------|---------|-------|
| OIDC GitHub | `oidc_github.is_enabled` | `true` | GitHub Actions OIDC provider |
| Budgets | `budgets.is_enabled` | `true` | Cost alerts |
| IAM Users/Groups | `iam.is_enabled` | `false` | User and group management |
| Compute Optimizer | `compute_optimizer.is_enabled` | `true` | Resource optimization |
| GuardDuty | `guardduty.is_enabled` | `false` | Threat detection (~$1/GB) |
| Health Events | `health.is_enabled` | `true` | AWS Health notifications |
| Trusted Advisor | `trusted_advisor.is_enabled` | `false` | Requires Business/Enterprise plan |
| IAM Password Expired | `iam_password_expired.is_enabled` | `false` | Password expiry alerts |
| Access Analyzer | `security_access_analyzer.is_enabled` | `true` | External access detection |
| Athena (Security) | `security_athena.is_enabled` | `true` | Security query workgroup |
| CloudTrail | `security_cloudtrail.is_enabled` | `false` | API audit logging |
| Config | `security_config.is_enabled` | `false` | Compliance monitoring |
| Default VPC | `security_default_vpc.is_enabled` | `true` | VPC hardening |
| EBS | `security_ebs.is_enabled` | `true` | Encryption by default |
| EC2 Metadata | `security_ec2_metadata.is_enabled` | `true` | IMDSv2 enforcement |
| ECR | `security_ecr.is_enabled` | `true` | Native image scanning |
| GuardDuty (Security) | `security_guardduty.is_enabled` | `false` | Account-level GuardDuty |
| IAM Security | `security_iam.is_enabled` | `true` | Password policy + Support role |
| S3 | `security_s3.is_enabled` | `true` | Account-level public access block |
| Security Hub | `security_securityhub.is_enabled` | `false` | Security posture dashboard |
| SSM Automation | `security_ssm_automation.is_enabled` | `true` | Automated remediation |
| Inspector2 | `security_inspector2.is_enabled` | `false` | Vulnerability scanning |
| Macie | `security_macie.is_enabled` | varies | Sensitive data discovery |

### Control Tower

```hcl
control_tower = {
  is_enabled = false
  managed_services = {
    access_analyzer = false
    cloudtrail      = false
    config          = false
    guardduty       = false
    securityhub     = false
  }
}
```

When `is_enabled = true`, services not explicitly overridden in `managed_services` are treated as organization-managed and automatically disabled in this stack.

<details>
<summary>Verification commands (run from root account)</summary>

```bash
# Check Control Tower
aws controltower list-landing-zones

# Check delegated administrators per service
aws organizations list-delegated-administrators --service-principal access-analyzer.amazonaws.com
aws organizations list-delegated-administrators --service-principal config.amazonaws.com
aws organizations list-delegated-administrators --service-principal guardduty.amazonaws.com
aws organizations list-delegated-administrators --service-principal securityhub.amazonaws.com

# Check organization-level CloudTrail
aws cloudtrail describe-trails --query 'trailList[?IsOrganizationTrail==`true`].Name'
```

</details>

### Lambda VPC Configuration

Optional VPC for Lambda functions. Increases cost due to NAT Gateway.

```hcl
common_lambda = {
  vpc = {
    is_enabled = false   # Set true to run Lambda in VPC
    create_vpc = true    # false = use existing VPC
  }
}
```

### IAM Users, Groups, and Switch Role

<details>
<summary>IAM configuration structure</summary>

```hcl
iam = {
  is_enabled = false
  user       = { ... }         # IAM users with console/programmatic access
  group      = { ... }         # Groups with policy_document and policy attachments
  switch_role = {
    from = { is_enabled = false, ... }  # Source account SwitchRole policies
    to   = { is_enabled = false, ... }  # Destination account roles
  }
}
```

Key points:
- Groups support custom `policy_document` (inline) and `policy` (managed ARN) attachments
- `is_enabled_mfa = true` enforces MFA for the group
- Switch Role supports both `from` (source account) and `to` (destination account) configurations
- Group policy limit is 10 — see [IAM policy size docs](https://aws.amazon.com/premiumsupport/knowledge-center/iam-increase-policy-size/)

</details>

## Environment Examples

| Setting (tfvars path) | Development | Staging | Production |
|---------|-------------|---------|------------|
| `budgets.aws_budgets_budget.limit_amount` | `"50.0"` | `"200.0"` | `"500.0"` |
| `guardduty.is_enabled` | `false` | `true` | `true` |
| `security_config.is_enabled` | `false` | `false` | `true` |
| `security_cloudtrail.is_enabled` | `false` | `true` | `true` |
| `cloudwatch_log_group.retention_in_days` | `7` | `14` | `14` |
| `cloudwatch_log_group.override.security_cloudtrail.retention_in_days` | `30` | `90` | `365` |
| `control_tower.is_enabled` | `false` | `false` | `true` |

## Validation Checklist

| Category | Check |
|----------|-------|
| Security | If Control Tower enabled: verify managed services are disabled in this stack |
| Security | If Control Tower disabled: enable security services based on needs |
| Budget | `limit_amount` matches environment expectations |
| Budget | At least one `subscriber_email_addresses` configured |
| Slack | OAuth token valid and bot has channel access |
| Slack | Channel ID correct (test with low-severity alert) |
| Cost | Unused services disabled |
| Cost | Log retention periods appropriate (not excessive) |

## Related Documents

- [Initial Setup](./initial-setup.md) — S3 state bucket, IAM user creation
- [Monitor Configuration](./configure-monitor-tfvars.md) — Monitoring stack
- [Management Root Configuration](./configure-management-root-tfvars.md) — Root account
- [Management Audit Configuration](./configure-management-audit-tfvars.md) — Audit account
- [Troubleshooting](./troubleshooting.md) — Common issues and resolution
