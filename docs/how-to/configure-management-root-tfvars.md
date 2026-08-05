# Management Root Terraform Configuration Guide

## Overview

Configuration for the **Management (Root) account** — the top-level account that owns the AWS Organization.

**Stack:** `terraform/management/root/`
**Example file:** [terraform.example.tfvars](https://github.com/y-miyazaki/terraform-aws-base/blob/main/terraform/management/root/terraform.example.tfvars)
**Initial setup:** See [Initial Setup (Common)](./initial-setup.md)

**Customization markers:** In `terraform.example.tfvars` (and env copies), search for `CUSTOMIZE` comments — they mark values that require environment-specific changes.

**What it configures:**

| Service                | Purpose                                  |
| ---------------------- | ---------------------------------------- |
| Budgets                | Cost monitoring and alerting             |
| Organizations Policies | SCPs and tag policies                    |
| CloudTrail             | Organization-level audit trail           |
| OIDC GitHub            | CI/CD integration                        |
| JIT Access             | Just-In-Time privileged access via Slack |
| Lambda                 | Automation utilities                     |

**Relationship to other stacks:**

- Audit account (`management/audit`) handles delegated security administration
- Member accounts (`base`) are governed by organizational policies defined here
- Control Tower manages CloudTrail directly; `security_cloudtrail` is for non-CT environments

## Required Settings

| Variable (tfvars path)       | Description                       | Example                 |
| ---------------------------- | --------------------------------- | ----------------------- |
| `region`                     | Primary AWS region                | `"ap-northeast-1"`      |
| `subscriber_email_addresses` | Email(s) for budget notifications | `["admin@example.com"]` |

## Optional Settings

### Tags and Naming

| Variable (tfvars path) | Description          | Default        |
| ---------------------- | -------------------- | -------------- |
| `tags.env`             | Environment name     | `"root"`       |
| `tags.service`         | Service/project name | `"management"` |
| `name_prefix`          | Resource name prefix | `"root-"`      |

### CloudWatch Log Groups

Same centralized pattern as other stacks. See [Base Terraform Configuration Guide](./configure-base-tfvars.md#cloudwatch-log-groups) for detailed explanation.

<details markdown>
<summary>Available override services</summary>

| Service Name                 | Description                | Recommended |
| ---------------------------- | -------------------------- | ----------- |
| `budgets`                    | Budget alerts Lambda logs  | 7 days      |
| `security_cloudtrail`        | CloudTrail security events | 90 days     |
| `common_lambda_vpc_flow_log` | VPC Flow Logs processing   | 7 days      |

</details>

### Slack Notifications

```hcl
slack = {
  oauth_access_token = "xoxb-..."
  channel_id         = "C0XXXXXXXXX"
  override = {
    budgets             = { channel_id = "C-FINANCE" }
    security_cloudtrail = { channel_id = "C-SECURITY" }
  }
}
```

### KMS

```hcl
kms = {
  description             = "This key used for SNS."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  alias_name              = "root-sns"
}
```

### OIDC GitHub

```hcl
oidc_github = {
  is_enabled                      = true
  dangerously_attach_admin_policy = false  # Use false in production!
  iam_role_policy_names           = ["ReadOnlyAccess"]
  create_oidc_provider            = true
  github_subjects                 = ["your-org/infrastructure-repo"]
  iam_role_name                   = "oidc-github-root-role"
  iam_role_path                   = "/"
}
```

### Budgets

```hcl
budgets = {
  is_enabled = true
  aws_budgets_budget = {
    name         = "budgets-monthly"
    limit_amount = "1000.0"     # Adjust per environment
    time_unit    = "MONTHLY"
    notification = [{
      comparison_operator        = "GREATER_THAN"
      threshold                  = "80"
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = ["admin@example.com"]
      subscriber_sns_topic_arns  = null
    }]
  }
}
```

| Environment | Recommended `limit_amount` |
| ----------- | -------------------------- |
| Development | $50–200                    |
| Staging     | $200–500                   |
| Production  | $500+                      |

### Organizations Policy (SCP)

Restricts which AWS services and regions can be used across all accounts.

```hcl
organizations_policy = {
  policy = {
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSpecificRegions"
      Effect    = "Deny"
      NotAction = ["budgets:*", "cloudfront:*", "iam:*", "organizations:*", "route53:*", "support:*"]
      Resource  = ["*"]
      Condition = {
        StringNotEquals = {
          "aws:RequestedRegion" = ["ap-northeast-1", "us-east-1"]
        }
      }
    }]
  }
}
```

> **Caution:** Test SCPs in non-production first. Incorrect SCPs can block administrative access.

### CloudTrail

Monitors and alerts on specific CloudTrail events (e.g., EC2 termination, IAM changes).

```hcl
security_cloudtrail = {
  is_enabled = false
  aws_cloudwatch_log = {
    cloudtrail_logs_terminate = {
      aws_cloudwatch_log_metric_filter = {
        name    = "cloudtrail-logs-terminate"
        pattern = "{ $.eventName = \"Terminate*\" }"
        ...
      }
    }
  }
}
```

### Lambda VPC Configuration

Same pattern as other stacks. See [Base Terraform Configuration Guide](./configure-base-tfvars.md#lambda-vpc-configuration).

### JIT Access

Just-In-Time privileged access via Slack with automatic revocation.

**Prerequisites:**

1. Slack App with required scopes (`chat:write`, `commands`, `users:read`, `users:read.email`)
2. Lambda zip at `lambda/outputs/go_jit_access.zip`
3. IAM Identity Center enabled

**Full specification:** [JIT Access System Specification](../reference/jit-access-specification.md)

```hcl
jit_access = {
  cleanup_schedule_expression = "rate(15 minutes)"
  profiles = {
    Production-AWSAdministratorAccess = {
      account_id           = "123456789012"
      permission_set_arn   = "arn:aws:sso:::permissionSet/ssoins-xxx/ps-xxx"
      max_duration_minutes = 60
      approvers            = ["UXXXXXXXXXX"]
      description          = "production administrator access"
    }
  }
  approver_channel_id = "CXXXXXXXXXX"
  bot_token           = "xoxb-..."
  signing_secret      = "..."
  user_mappings       = {}
  workflow_secret     = null  # Set to enable Workflow Builder integration
}
```

<details markdown>
<summary>How to get required values</summary>

| Value                        | How to Get                                                                                                      |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `account_id`                 | AWS Console → Organizations → Accounts                                                                          |
| `permission_set_arn`         | IAM Identity Center → Permission sets → copy ARN                                                                |
| `approvers` (Slack User IDs) | Slack profile → "..." → "Copy member ID"                                                                        |
| `approver_channel_id`        | Channel details → "Channel ID" at bottom                                                                        |
| `bot_token`                  | api.slack.com → Your App → OAuth & Permissions                                                                  |
| `signing_secret`             | api.slack.com → Your App → Basic Information → App Credentials                                                  |
| Identity Center User ID      | `aws identitystore list-users --identity-store-id <id> --filters AttributePath=UserName,AttributeValue=<email>` |
| `workflow_secret`            | `openssl rand -base64 32`                                                                                       |

</details>

## Validation Checklist

| Category      | Check                                              |
| ------------- | -------------------------------------------------- |
| Slack         | OAuth token valid, default channel set             |
| Budget        | `limit_amount` appropriate for account spend       |
| Budget        | At least one subscriber email configured           |
| CloudTrail    | Metric filters configured for critical events      |
| GitHub        | OIDC repositories listed, admin policy disabled    |
| Organizations | SCP regions and services match requirements        |
| Organizations | SCP tested in non-production first                 |
| KMS           | Key rotation enabled, deletion window set          |
| JIT Access    | `bot_token` and `signing_secret` set               |
| JIT Access    | `approver_channel_id` correct                      |
| JIT Access    | At least one profile with valid Permission Set ARN |
| JIT Access    | Lambda zip exists at expected path                 |

## Related Documents

- [Initial Setup (Common)](./initial-setup.md) — S3 state bucket, IAM user creation
- [Management Audit Terraform Configuration Guide](./configure-management-audit-tfvars.md) — Audit account
- [Base Terraform Configuration Guide](./configure-base-tfvars.md) — Member accounts
- [JIT Access System Specification](../reference/jit-access-specification.md) — Full system specification
- [Troubleshooting](./troubleshooting.md) — Common issues and resolution
