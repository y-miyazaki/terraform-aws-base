<!-- omit in toc -->
# Management Root Environment Terraform Configuration Guide

This guide covers the Terraform configuration for the **Management Root** environment. The example configuration file is [terraform.example.tfvars for root](terraform/management/root/terraform.example.tfvars).

This environment focuses on organizational governance including budgets, policies, and CloudTrail audit logging.

<!-- omit in toc -->
## Table of Contents

- [Initial Setting](#initial-setting)
- [Requirements](#requirements)
  - [region](#region)
  - [cloudwatch\_log\_group](#cloudwatch_log_group)
    - [Centralized Configuration Pattern](#centralized-configuration-pattern)
    - [Available Services for Override](#available-services-for-override)
    - [Benefits of Centralized Configuration](#benefits-of-centralized-configuration)
    - [Example Configuration](#example-configuration)
  - [subscriber\_email\_addresses](#subscriber_email_addresses)
- [Not Requirements](#not-requirements)
  - [Slack](#slack)
  - [tags](#tags)
  - [name\_prefix](#name_prefix)
  - [kms](#kms)
  - [oidc\_github](#oidc_github)
  - [budgets](#budgets)
  - [common\_lambda](#common_lambda)
  - [organizations\_policy](#organizations_policy)
  - [security\_cloudtrail](#security_cloudtrail)
- [Configuration Validation Checklist](#configuration-validation-checklist)
- [Related Documents](#related-documents)

## Initial Setting

This section describes the initial settings for running [management root Terraform](./terraform/management/root/). If an item has already been addressed, please skip to the next section.

**Remove the access key from the root account**

Since this is a security issue, remove the access key from the root account from the management console.

**Manual creation of IAM user and IAM group to run Terraform**

Create an IAM user and an IAM group from the management console in order to run Terraform.

Create an IAM group (pseudonym: deploy). Attach AdministratorAccess as the policy.

Create an IAM user (pseudonym: terraform), giving it only Programmatic access for Access Type, and add it to the IAM group (pseudonym: deploy).

**Create an S3 to store the Terraform State**

Create an S3 from the management console to manage the Terraform State.

However, if you have an environment where you can run the aws command and profile already configured, you can create an S3 by running the following command.

```sh
$ ./scripts/terraform/aws_init_state.sh -h

This command creates a S3 Bucket for Terraform State.
You can also add random hash to bucket name suffix.

Usage:
    aws_init_state.sh -r {region} -b {bucket name} -p {profile}[<options>]
    aws_init_state.sh -r ap-northeast-1 -b terraform-state
    aws_init_state.sh -r ap-northeast-1 -b terraform-state -p default -s

Options:
    -b {bucket name}          S3 bucket name
    -p {aws profile name}     Name of AWS profile
    -r {region}               S3 region
    -s                        If set, a random hash will suffix bucket name.
    -h                        Usage aws_init_state.sh

$ ./scripts/terraform/aws_init_state.sh -r ap-northeast-1 -b base-terraform-state- -p default -s
~
~
~
--------------------------------------------------------------
bucket_name: base-terraform-state-xxxxxxxxxx
region: ap-northeast-1
--------------------------------------------------------------
```

**terraform.{environment}.tfvars file to configure for each environment**

You need to rename the linked file [terraform.example.tfvars for root](terraform/management/root/terraform.example.tfvars) and change each variable for your environment.

The variables that need to be changed are marked with TODO comments; search for them in TODO.

**Running Terraform**

Run the terraform command: terraform init followed by terraform apply.

You may find that terraform apply fails due to conflicts or other problems, so run it again and it will succeed.

```sh
bash-5.1# terraform init
There are some problems with the CLI configuration:

Error: The specified plugin cache dir /root/.terraform.d/plugin-cache cannot be opened: stat /root/.terraform.d/plugin-cache: no such file or directory
```

## Requirements

The following items must be modified; terraform apply may fail if you run it as an example.

### region

Select the region where you want to create the resource.

```terraform
#--------------------------------------------------------------
# Default Region for Resources
# Specifies the primary AWS region where most resources will be deployed.
# Some services like CloudFront require resources in us-east-1 regardless of this setting.
# Common regions: ap-northeast-1 (Tokyo), us-east-1 (N. Virginia), eu-west-1 (Ireland)
#--------------------------------------------------------------
# TODO: need to change region.
region = "ap-northeast-1"
```

### cloudwatch_log_group

**IMPORTANT: CloudWatch Log Group configuration has been centralized for easier management.**

Instead of configuring retention periods for each Lambda function individually, you can now manage them centrally with service-specific overrides when needed.

#### Centralized Configuration Pattern

```terraform
#--------------------------------------------------------------
# CloudWatch Log Group Configuration
# Common CloudWatch Log Group settings for all services.
# This configuration is applied globally but can be overridden per service.
#
# Priority order (higher priority overrides lower):
# 1. cloudwatch_log_group.override.<service_name>.retention_in_days (highest priority)
# 2. cloudwatch_log_group.retention_in_days (lowest priority - common default)
#
# retention_in_days: How long logs are kept before automatic deletion
# Common values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
# COST CONSIDERATION: Longer retention = higher CloudWatch Logs storage costs
#
# Use cloudwatch_log_group.override for centralized management.
#--------------------------------------------------------------
# TODO: need to change cloudwatch_log_group settings.
cloudwatch_log_group = {
  # Default retention period for all services (in days)
  retention_in_days = 14
  # Default KMS key ID for log encryption (null = use AWS managed key)
  kms_key_id = null

  # Optional: Override settings for specific services
  # Uncomment and configure as needed
  override = {
    # budgets = {
    #   retention_in_days = 7
    # }
    # security_cloudtrail = {
    #   retention_in_days = 90
    # }
    # common_lambda_vpc_flow_log = {
    #   retention_in_days = 7
    # }
  }
}
```

#### Available Services for Override

For the root environment, the following services support CloudWatch Log Group configuration overrides:

| Service Name                 | Description                        | Recommended Retention |
| ---------------------------- | ---------------------------------- | --------------------- |
| `budgets`                    | Budget alerts Lambda logs          | 7 days                |
| `security_cloudtrail`        | CloudTrail security events logs    | 90 days               |
| `common_lambda_vpc_flow_log` | VPC Flow Logs processing (if used) | 7 days                |

#### Benefits of Centralized Configuration

✅ **Single Source of Truth**: Define retention period once, apply everywhere

✅ **Flexible Overrides**: Set different retention for specific services (e.g., CloudTrail 90 days, budgets 7 days)

✅ **Easy Maintenance**: Update retention policies without modifying multiple configurations

✅ **Cost Optimization**: Easily identify and adjust services with long retention periods

✅ **Consistent Encryption**: Optionally use a common KMS key for all log encryption

#### Example Configuration

```terraform
# Root Environment - Governance-focused
cloudwatch_log_group = {
  retention_in_days = 14  # Default: 14 days
  kms_key_id = null
  override = {
    security_cloudtrail = {
      retention_in_days = 90  # Audit logs: 90 days for compliance
    }
    budgets = {
      retention_in_days = 7  # Budget alerts: 7 days is sufficient
    }
  }
}
```

### subscriber_email_addresses

Email addresses for budget notifications. At least one email must be provided to receive budget alerts.

```terraform
budgets = {
  aws_budgets_budget = {
    # TODO: need to set subscriber_email_addresses for Budgets notifications.
    subscriber_email_addresses = [
      "admin@example.com",
      "finance@example.com"
    ]
  }
}
```

## Not Requirements

Although terraform apply will succeed without fixing the following items, the following is a list of things that should be changed for each environment.

### Slack

**Centralized Configuration Pattern**

This project uses a **centralized Slack configuration** approach. Slack settings are defined once and inherited by all Lambda functions, with the ability to override specific values when needed.

**Available Override Functions**

For the root environment, the following functions support Slack configuration overrides:

- `budgets` - AWS Budgets notifications
- `security_cloudtrail` - CloudTrail security event notifications

**Configuration Structure**

```terraform
#--------------------------------------------------------------
# Slack Configuration
# Common Slack settings for Lambda function notifications.
#
# Priority order (higher priority overrides lower):
# 1. slack.override.<function_name> (highest priority)
# 2. slack (lowest priority - common defaults)
#
# Use slack.override for centralized management.
#--------------------------------------------------------------
slack = {
  # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN (bot token xoxb-xxxxxx....)
  # Get this from your Slack app's OAuth & Permissions page
  # Format: xoxb-XXXXXXXXX-XXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX
  oauth_access_token = "xoxb-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
  # TODO: need to change SLACK_CHANNEL_ID
  # Right-click on your Slack channel and select "Copy link" to find the channel ID
  channel_id = "C0XXXXXXXXX"

  # -----------------------------------------------------------
  # Override Configuration (Optional)
  # Override Slack settings for specific Lambda functions.
  # Priority order: override (highest) > defaults (lowest)
  #
  # Available function overrides:
  # - budgets: AWS Budgets Alerts to Slack
  # - security_cloudtrail: CloudTrail Security Events to Slack
  # -----------------------------------------------------------
  override = {
    # budgets = {
    #   channel_id = "C0XXXXXXXXX"
    # }
    # security_cloudtrail = {
    #   channel_id = "C0XXXXXXXXX"
    # }
  }
}
```

**Benefits**

✅ **Simplifies configuration**: Set OAuth token once, inherit everywhere

✅ **Flexible routing**: Override channels for specific notification types

✅ **Easy maintenance**: Update default channel in one place

✅ **Clear priority**: Override values always take precedence over defaults

**Before Setting Slack Configuration**

Before using Slack functionality, you must create a Slack app and configure AWS Chatbot:

1. Create a Slack app in your workspace
2. Obtain OAuth access token (starts with `xoxb-`)
3. Get your Slack channel ID (format: `C0XXXXXXXXX`)
4. Configure AWS Chatbot with your Slack workspace

For detailed setup instructions, refer to [AWS Chatbot Documentation](https://docs.aws.amazon.com/chatbot/latest/adminguide/slack-setup.html).

### tags

You can leave the following as it is without any problem. However, if you want to add TAGs to the resources according to your environment, please modify the following.

These tags are automatically applied to all resources created by this Terraform configuration. Common tags help with cost allocation, resource organization, and compliance tracking.

```terraform
#--------------------------------------------------------------
# Default Tags for Resources
# A tag that is set globally for the resources used.
# These tags are automatically applied to all resources created by this Terraform configuration.
# Common tags help with cost allocation, resource organization, and compliance tracking.
#--------------------------------------------------------------
# TODO: need to change tags.
tags = {
  # TODO: need to change env.
  # Environment name for resource identification and cost allocation
  # Examples: "dev", "stg", "prd", "audit", "root"
  env = "root"
  # TODO: need to change service.
  # Service/project name for resource grouping and identification
  # This should match your project name, job name, or product name
  service = "management"
  # Map Program (optional)
  # Uncomment and set if you have a Migration Acceleration Program (MAP) assessment ID
  # This helps track resources for AWS migration programs
  # map-migrated = "xxxxxxxxxxxxx"
}
```

### name_prefix

Used as a prefix for resource names. This prefix helps identify resources belonging to this project and environment.

Example: If `name_prefix="root-"`, resources will be named `"root-sns"`, `"root-lambda"`, etc.

```terraform
#--------------------------------------------------------------
# Name prefix
# It is used as a prefix attached to various resource names.
# This prefix helps identify resources belonging to this project and environment.
# Example: If name_prefix="myproject-", resources will be named "myproject-vpc", "myproject-lambda", etc.
#--------------------------------------------------------------
name_prefix = "root-"
```

### kms

KMS key configuration for SNS encryption in root environment.

AWS Key Management Service for encrypting SNS topics and other sensitive data. Key rotation is enabled by default for enhanced security. Deletion window allows recovery if key is accidentally deleted.

```terraform
#--------------------------------------------------------------
# KMS
# AWS Key Management Service for encrypting SNS topics and other sensitive data.
# Key rotation is enabled by default for enhanced security.
# Deletion window allows recovery if key is accidentally deleted.
#--------------------------------------------------------------
kms = {
  sns = {
    description             = "This key used for SNS."
    deletion_window_in_days = 7
    is_enabled              = true
    enable_key_rotation     = true
    alias_name              = "root-sns"
  }
}
```

### oidc_github

Configuration for GitHub Actions OIDC provider integration. Allows GitHub Actions workflows to authenticate with AWS without storing long-lived credentials.

**SECURITY WARNING**: `dangerously_attach_admin_policy` should be `false` in production! Use least privilege principles and attach only necessary policies.

```terraform
#--------------------------------------------------------------
# OpenID Connect for AWS and GitHub Actions
# Terraform module to configure GitHub Actions as an IAM OIDC identity provider in AWS.
# Allows GitHub Actions workflows to authenticate with AWS without storing long-lived credentials.
# The target ARN is output(oidc_github_iam_role_arn) for the target ARN.
# ex) oidc_github_iam_role_arn = "arn:aws:iam::{aws_account_id}:role/{iam_role_name}"
#
# SECURITY WARNING: dangerously_attach_admin_policy should be false in production!
# Use least privilege principles and attach only necessary policies.
#--------------------------------------------------------------
oidc_github = {
  # TODO: need to set is_enabled for settings of IAM OIDC for GitHub Actions.
  is_enabled = true
  # TODO: Flag to enable/disable the attachment of the AdministratorAccess policy.
  dangerously_attach_admin_policy = true
  # TODO: Flag to enable/disable the attachment of the ReadOnly policy.
  attach_read_only_policy = false
  # TODO: Flag to enable/disable the creation of the GitHub OIDC provider.
  create_oidc_provider = true
  # TODO: Set the org/repo of the GitHub repository to github_repositories.
  github_repositories = [
    # "your-org/your-repo",
  ]
  iam_role_name = "oidc-github-role"
  iam_role_path = "/"
}
```

### budgets

AWS Budgets configuration for cost monitoring and alerts. This helps track spending and prevent unexpected charges across your AWS organization.

**CRITICAL SETTING**: Always configure budget alerts to prevent unexpected costs.

Adjust `limit_amount` based on your environment:
- Development: $50-200/month
- Staging: $200-500/month
- Production: $500+/month (adjust based on expected usage)

**Cost Consideration:** The first two budgets are free. Additional budgets cost $0.02 per day per budget (~$0.60/month).

```terraform
#--------------------------------------------------------------
# Budgets
# AWS Budgets configuration for cost monitoring and alerts.
# Helps track spending and prevent unexpected charges across your AWS organization.
#
# CRITICAL SETTING: Always configure budget alerts to prevent unexpected costs
# Adjust limit_amount based on your environment:
# - Development: $50-200/month
# - Staging: $200-500/month
# - Production: $500+/month (adjust based on expected usage)
#
# COST CONSIDERATION: The first two budgets are free. Additional budgets cost $0.02 per day (~$0.60/month).
#--------------------------------------------------------------
budgets = {
  # TODO: need to set is_enabled for settings of budgets.
  is_enabled = true
  # Provides a budgets budget resource. Budgets use the cost visualisation provided
  # by Cost Explorer to show you the status of your budgets, to provide forecasts of
  # your estimated costs, and to track your AWS usage, including your free tier usage.
  aws_budgets_budget = {
    name = "budgets-monthly"
    # TODO: need to change limit_amount for Service
    limit_amount = "100.0"
    time_unit    = "MONTHLY"
    notification = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = "80"
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
        # TODO: need to change subscriber_email_addresses.
        # If the threshold is exceeded, you will be notified to the email address provided.
        # At least one must set an email address.
        subscriber_email_addresses = [
          # example)
          # "youremail@yourtest.test.hogehoge.com"
        ]
        subscriber_sns_topic_arns = null
      }
    ]
  }
  aws_eventbridge_schedule = {
    name                = "budgets-eventbridge-scheduler"
    schedule_expression = "cron(0 9 * * ? *)"
    description         = "This eventbridge scheduler called budgets lambda function."
  }
  aws_lambda_function = {
    environment = {
      ENV = "root"
      # TODO: need to change TIMEZONE.
      # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
      TIMEZONE = "Asia/Tokyo"
    }
  }
}
```

### common_lambda

Common Lambda function settings including VPC configuration. Use this when Lambda functions need to access resources in a VPC (e.g., RDS, ElastiCache).

**VPC CONFIGURATION:**
- `is_enabled = false`: Lambda runs in AWS-managed VPC (no additional cost)
- `is_enabled = true`: Lambda runs in your VPC (requires NAT Gateway, adds ~$32/month per AZ)

**Cost Consideration:**
- NAT Gateway: ~$32/month per AZ + data transfer costs
- VPC Flow Logs: Storage costs based on retention and traffic volume

```terraform
#--------------------------------------------------------------
# Common Lambda
# Common Lambda function settings including VPC configuration.
# Use this when Lambda functions need to access resources in a VPC (e.g., RDS, ElastiCache).
#
# VPC CONFIGURATION:
# - is_enabled = false: Lambda runs in AWS-managed VPC (no additional cost)
# - is_enabled = true: Lambda runs in your VPC (requires NAT Gateway, adds ~$32/month per AZ)
#
# COST CONSIDERATION:
# - NAT Gateway: ~$32/month per AZ + data transfer costs
# - VPC Flow Logs: Storage costs based on retention and traffic volume
#--------------------------------------------------------------
common_lambda = {
  vpc = {
    # TODO: If you want to run LambdaFunctions inside a VPC, set to true. However,
    # VPC requires more cost since you need to configure NAT Gateway and other settings.
    is_enabled = false
    # TODO: If a VPC has already been established, specify false; if a new VPC is to be created, specify true.
    create_vpc = false
    cidr        = "10.0.0.0/16"
    azs         = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
    private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
    enable_nat_gateway = true
    single_nat_gateway = false
    # TODO: Set VPC ID if using existing VPC (when create_vpc = false)
    vpc_id             = null
    # TODO: Set subnet IDs if using existing VPC (when create_vpc = false)
    subnet_ids         = []
  }
  aws_iam_role = {
    description = null
    name        = "monitor-lambda-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = null
    name        = "monitor-lambda-policy"
    path        = "/"
  }
}
```

### organizations_policy

AWS Organizations service control policy (SCP) configuration. This policy restricts which AWS services and regions can be used across all accounts in the organization.

**IMPORTANT**: Service Control Policies (SCPs) are the maximum available permissions. They do not grant permissions but set boundaries on what can be done.

**DEFAULT POLICY:**
- Denies access to services outside specified regions (ap-northeast-1, us-east-1)
- Allows global services (IAM, CloudFront, Route53, etc.) regardless of region

**CAUTION**: Test SCPs carefully in non-production environments first! Incorrectly configured SCPs can block critical operations, including administrative access.

```terraform
#--------------------------------------------------------------
# Organizations Policy
# AWS Organizations service control policy (SCP) configuration.
# This policy restricts which AWS services and regions can be used across all accounts in the organization.
#
# IMPORTANT: Service Control Policies (SCPs) are the maximum available permissions.
# They do not grant permissions but set boundaries on what can be done.
#
# DEFAULT POLICY:
# - Denies access to services outside specified regions (ap-northeast-1, us-east-1)
# - Allows global services (IAM, CloudFront, Route53, etc.) regardless of region
#
# CAUTION: Test SCPs carefully in non-production environments first!
# Incorrectly configured SCPs can block critical operations, including administrative access.
#--------------------------------------------------------------
# TODO: Review and adjust allowed services and regions based on organizational requirements.
organizations_policy = {
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSpecificRegions"
        Effect = "Deny"
        NotAction = [
          "budgets:*",
          "cloudfront:*",
          "iam:*",
          "organizations:*",
          "route53:*",
          "support:*",
          # Add other global services as needed
        ]
        Resource = [
          "*",
        ]
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "ap-northeast-1",
              "us-east-1",
            ]
          }
        }
      }
    ]
  }
}
```

### security_cloudtrail

CloudTrail configuration for audit logging and security event alerts. Monitors and alerts on specific CloudTrail events (e.g., EC2 termination, IAM changes).

**KEY FEATURES:**
- Metric Filters: Define patterns to detect specific events in CloudTrail logs
- CloudWatch Alarms: Trigger alerts when patterns match
- SNS Integration: Send notifications via SNS
- Lambda Integration: Process alerts and send to Slack

**COMMON USE CASES:**
- Detect resource termination (EC2, RDS, etc.)
- Monitor IAM policy changes
- Alert on security group modifications
- Track API call patterns

**COST CONSIDERATION:**
- CloudWatch Logs: Storage costs based on retention and log volume
- CloudWatch Metrics: $0.30 per custom metric per month
- SNS: First 1,000 notifications free, then $0.50 per 1M notifications

```terraform
#--------------------------------------------------------------
# Security:CloudTrail
# CloudTrail configuration for audit logging and security event alerts.
# Monitors and alerts on specific CloudTrail events (e.g., EC2 termination, IAM changes).
#
# KEY FEATURES:
# - Metric Filters: Define patterns to detect specific events in CloudTrail logs
# - CloudWatch Alarms: Trigger alerts when patterns match
# - SNS Integration: Send notifications via SNS
# - Lambda Integration: Process alerts and send to Slack
#
# COMMON USE CASES:
# - Detect resource termination (EC2, RDS, etc.)
# - Monitor IAM policy changes
# - Alert on security group modifications
# - Track API call patterns
#
# COST CONSIDERATION:
# - CloudWatch Logs: Storage costs based on retention and log volume
# - CloudWatch Metrics: $0.30 per custom metric per month
# - SNS: First 1,000 notifications free, then $0.50 per 1M notifications
#--------------------------------------------------------------
security_cloudtrail = {
  # TODO: need to set is_enabled for settings of CloudTrail.
  is_enabled = false
  aws_cloudwatch_log = {
    cloudtrail_logs_terminate = {
      aws_cloudwatch_log_metric_filter = {
        name    = "cloudtrail-logs-terminate"
        pattern = "{ $.eventName = \"Terminate*\" }"
        metric_transformation = [
          {
            name      = "cloudtrail-logs-terminate"
            namespace = "CloudTrail"
            value     = "1"
          }
        ]
      }
      aws_cloudwatch_metric_alarm = {
        alarm_name          = "cloudtrail-logs-terminate"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = 1
        period              = 300
        statistic           = "Sum"
        threshold           = 1
      }
    }
  }
  aws_sns_topic = {
    name = "aws-cloudtrail-logs"
  }
}
```
```

## Environment-Specific Configuration Examples

For root environments, focus on organizational governance and budgets:

```hcl
# Tags for root environment
tags = {
  env     = "root"
  service = "management"
}

# Centralized Slack configuration with overrides
slack = {
  oauth_access_token = "xoxb-YOUR-ACTUAL-TOKEN"
  channel_id         = "C0XXXXXXXXX"  # Default channel
  override = {
    budgets = {
      channel_id = "C1111111111"  # Budget alerts channel
    }
    security_cloudtrail = {
      channel_id = "C2222222222"  # Security events channel
    }
  }
}

# Budget configuration
budgets = {
  is_enabled = true
  aws_budgets_budget = {
    limit_amount               = "1000.0"
    limit_unit                 = "USD"
    time_unit                  = "MONTHLY"
    time_period_start          = "2024-01-01_00:00"
    subscriber_email_addresses = ["admin@example.com", "finance@example.com"]
    threshold_percentage       = [80, 100]
    ENV                        = "root"
  }
}

# KMS configuration for root environment
kms = {
  sns = {
    description             = "This key used for SNS."
    deletion_window_in_days = 7
    is_enabled              = true
    enable_key_rotation     = true
    alias_name              = "root-sns"
  }
}

# GitHub Actions OIDC configuration
oidc_github = {
  is_enabled                      = true
  dangerously_attach_admin_policy = false  # Use least privilege in production
  attach_read_only_policy         = true
  create_oidc_provider            = true
  github_repositories = [
    "your-org/infrastructure-repo",
  ]
  iam_role_name = "oidc-github-root-role"
  iam_role_path = "/"
}

# CloudTrail monitoring
security_cloudtrail = {
  is_enabled = true
}

# Organizations policy (adjust services and regions as needed)
organizations_policy = {
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSpecificRegions"
        Effect = "Deny"
        NotAction = [
          "budgets:*",
          "cloudfront:*",
          "iam:*",
          "organizations:*",
          "route53:*",
          "support:*",
          # Add other global services as needed
        ]
        Resource = [
"*",
]
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "ap-northeast-1",
              "us-east-1",
            ]
          }
        }
      }
    ]
  }
}
```

## Configuration Validation Checklist

| Category                        | Item                                                      | Status |
| ------------------------------- | --------------------------------------------------------- | ------ |
| Slack Configuration Validation  | OAuth access token is correctly set                       | [ ]    |
| Slack Configuration Validation  | Default channel ID is set                                 | [ ]    |
| Slack Configuration Validation  | Override channels are configured for budgets if needed    | [ ]    |
| Slack Configuration Validation  | Override channels are configured for CloudTrail if needed | [ ]    |
| Budget Validation               | Budget limits are set appropriately for the environment   | [ ]    |
| Budget Validation               | Email addresses are configured for notifications          | [ ]    |
| Budget Validation               | Threshold percentages are reasonable (e.g., 80, 100)      | [ ]    |
| Budget Validation               | Budget start date is correct                              | [ ]    |
| CloudTrail Validation           | CloudTrail monitoring is enabled                          | [ ]    |
| CloudTrail Validation           | Metric filters are configured for critical events         | [ ]    |
| CloudTrail Validation           | CloudWatch alarms are properly configured                 | [ ]    |
| GitHub Integration Validation   | OIDC provider settings are correct                        | [ ]    |
| GitHub Integration Validation   | GitHub repositories list is populated                     | [ ]    |
| GitHub Integration Validation   | IAM policies follow least privilege principle             | [ ]    |
| GitHub Integration Validation   | Admin policy is disabled for production environments      | [ ]    |
| Organizations Policy Validation | Allowed services match organizational requirements        | [ ]    |
| Organizations Policy Validation | Allowed regions are correctly specified                   | [ ]    |
| Organizations Policy Validation | Policy does not inadvertently block critical services     | [ ]    |
| Environment-Specific Validation | Tags reflect the root environment                         | [ ]    |
| Environment-Specific Validation | Resource names use appropriate prefixes (e.g., "root-")   | [ ]    |
| Environment-Specific Validation | Region settings match deployment requirements             | [ ]    |
| KMS Configuration Validation    | KMS key rotation is enabled                               | [ ]    |
| KMS Configuration Validation    | Deletion window is set appropriately                      | [ ]    |
| AWS Chatbot Prerequisites       | Slack workspace integration is configured in AWS Chatbot  | [ ]    |
| AWS Chatbot Prerequisites       | OAuth tokens are obtained from Slack                      | [ ]    |

## Related Documents

- [README-management-audit-tfvars.md](./README-management-audit-tfvars.md) - Audit environment configuration documentation
- [README-base-tfvars.md](./README-base-tfvars.md) - Base configuration documentation
- [README-monitor-tfvars.md](./README-monitor-tfvars.md) - Monitor configuration documentation
- [README.md](./README.md) - Main project documentation
- [AWS Chatbot Documentation](https://docs.aws.amazon.com/chatbot/latest/adminguide/slack-setup.html) - Slack setup for AWS Chatbot
