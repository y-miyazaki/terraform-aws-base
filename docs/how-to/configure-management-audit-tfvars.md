# Management Audit Terraform Configuration Guide

## Overview

Configuration for the **Audit account** in an AWS Control Tower landing zone. This account serves as the delegated administrator for organization-wide security services.

**Stack:** `terraform/management/audit/`
**Example file:** [terraform.example.tfvars](https://github.com/y-miyazaki/terraform-aws-base/blob/main/terraform/management/audit/terraform.example.tfvars)
**Initial setup:** See [Initial Setup (Common)](./initial-setup.md)

**Customization markers:** In `terraform.example.tfvars` (and env copies), search for `CUSTOMIZE` comments — they mark values that require environment-specific changes.

**What it configures:**

| Service         | Purpose                                     |
| --------------- | ------------------------------------------- |
| Security Hub    | Centralized compliance dashboard            |
| GuardDuty       | Organization-wide threat detection          |
| Macie           | Sensitive data discovery across S3          |
| Access Analyzer | Organization-level external access analysis |
| Inspector2      | Vulnerability scanning (EC2, ECR, Lambda)   |
| AWS Chatbot     | Slack notifications for security findings   |

**Relationship to other stacks:**

- Member accounts (`base`) should set `control_tower.managed_services.*` to disable services managed here
- Management root handles organizational policies and budgets, not security delegation

## Required Settings

| Variable (tfvars path)      | Description                              | Example            |
| --------------------------- | ---------------------------------------- | ------------------ |
| `region`                    | Primary AWS region                       | `"ap-northeast-1"` |
| `security.slack_channel_id` | Slack channel for security notifications | `"C0XXXXXXXXX"`    |
| `security.slack_team_id`    | Slack workspace ID                       | `"xxxxxxxxxxx"`    |

## Optional Settings

### Tags and Naming

| Variable (tfvars path) | Description          | Default            |
| ---------------------- | -------------------- | ------------------ |
| `tags.env`             | Environment name     | `"audit"`          |
| `tags.service`         | Service/project name | `"security-audit"` |
| `name_prefix`          | Resource name prefix | `"audit-"`         |

### KMS

```hcl
kms = {
  description             = "This key used for SNS."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  alias_name              = "audit-sns"
}
```

### CloudWatch Log Groups

Same centralized pattern as other stacks. See [Base Terraform Configuration Guide](./configure-base-tfvars.md#cloudwatch-log-groups) for detailed explanation.

```hcl
cloudwatch_log_group = {
  retention_in_days = 14
  kms_key_id       = null
  override = {}
}
```

### OIDC GitHub

```hcl
oidc_github = {
  is_enabled                      = true
  dangerously_attach_admin_policy = false  # Use false in production!
  iam_role_policy_names           = ["ReadOnlyAccess"]
  create_oidc_provider            = true
  github_subjects                 = ["your-org/security-automation-repo"]
  iam_role_name                   = "oidc-github-audit-role"
  iam_role_path                   = "/"
}
```

### Security Services

#### Security Hub Organization

```hcl
securityhub_organization = {
  is_enabled_finding_aggregator = false
  configuration_policy = {
    service_enabled = true
    name            = "securityhub-configuration-policy"
    enabled_standard_arns = [
      "arn:aws:securityhub:{region}::standards/aws-foundational-security-best-practices/v/1.0.0",
      "arn:aws:securityhub:{region}::standards/cis-aws-foundations-benchmark/v/5.0.0"
    ]
    security_controls_configuration = { disabled_control_identifiers = [] }
  }
  linking_mode = "ALL_REGIONS"
  target_id    = "r-xxxxxx"
}
```

#### GuardDuty Organization

Enables threat detection features across all member accounts.

```hcl
guardduty_organization = {
  auto_enable_organization_members = "ALL"
  features = {
    EBS_MALWARE_PROTECTION = { auto_enable = "ALL" }
    EKS_AUDIT_LOGS         = { auto_enable = "ALL" }
    LAMBDA_NETWORK_LOGS    = { auto_enable = "ALL" }
    RDS_LOGIN_EVENTS       = { auto_enable = "ALL" }
    RUNTIME_MONITORING     = { auto_enable = "ALL", additional_configurations = [...] }
    S3_DATA_EVENTS         = { auto_enable = "ALL" }
  }
}
```

All target regions are configured via a single `guardduty_organization` variable with `for_each = toset(var.region.targets)`.

#### Inspector2 Organization

```hcl
inspector2_organization = {
  is_enabled = false
  enabler = {
    default = {
      account_ids    = ["123456789012"]
      resource_types = ["EC2", "ECR", "LAMBDA", "LAMBDA_CODE", "CODE_REPOSITORY"]
    }
  }
}
```

#### Macie Organization

```hcl
macie_organization = {
  status                       = "ENABLED"
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  classification_jobs          = []
  findings_filters             = []
}
```

#### Access Analyzer Organization

ORGANIZATION-type analyzer for cross-account access analysis.

```hcl
access_analyzer_organization = {
  is_enabled    = true
  analyzer_name = "aws-access-analyzer"
}
```

> **Note:** If an ORGANIZATION-type analyzer already exists (e.g., from Control Tower), Terraform skips creation to avoid conflicts. Multi-region deployment is automatic via `for_each = toset(var.region.targets)`.

#### Security Notifications (Chatbot)

```hcl
security_notification = {
  slack_channel_id = "C0XXXXXXXXX"
  slack_team_id    = "xxxxxxxxxxx"
  guardduty    = { is_enabled = true }
  securityhub  = { is_enabled = true }
}
```

### Delegated Administrator Verification

Run from the audit account to confirm delegation status:

```bash
aws organizations list-delegated-services-for-account --account-id <AUDIT_ACCOUNT_ID>
```

## Validation Checklist

| Category   | Check                                                                      |
| ---------- | -------------------------------------------------------------------------- |
| Security   | Slack channel and team IDs correctly set                                   |
| Security   | Security Hub enabled for compliance                                        |
| Security   | GuardDuty enabled for threat detection                                     |
| Security   | Access Analyzer Organization enabled                                       |
| Delegation | Account is delegated admin for required services                           |
| Delegation | Base accounts have `control_tower.managed_services.access_analyzer = true` |
| GitHub     | OIDC settings correct, repositories listed                                 |
| GitHub     | Admin policy disabled for production                                       |
| KMS        | Key rotation enabled                                                       |
| Chatbot    | Slack workspace integration configured in AWS Chatbot                      |

## Related Documents

- [Initial Setup (Common)](./initial-setup.md) — S3 state bucket, IAM user creation
- [Management Root Terraform Configuration Guide](./configure-management-root-tfvars.md) — Root account
- [Base Terraform Configuration Guide](./configure-base-tfvars.md) — Member accounts
- [AWS Chatbot Documentation](https://docs.aws.amazon.com/chatbot/latest/adminguide/slack-setup.html) — Slack setup
- [Troubleshooting](./troubleshooting.md) — Common issues and resolution
