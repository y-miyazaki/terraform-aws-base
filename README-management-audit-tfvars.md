<!-- omit in toc -->
# Management Audit Environment Terraform Configuration Guide

This guide covers the Terraform configuration for the **Management Audit** environment. The example configuration file is [terraform.example.tfvars for audit](terraform/management/audit/terraform.example.tfvars).

This environment focuses on security monitoring including Security Hub, GuardDuty, and CloudTrail audit logging.

<!-- omit in toc -->
## Table of Contents

- [Initial Setting](#initial-setting)
- [Requirements](#requirements)
  - [region](#region)
  - [slack\_channel\_id](#slack_channel_id)
  - [slack\_team\_id](#slack_team_id)
- [Not Requirements](#not-requirements)
  - [tags](#tags)
  - [name\_prefix](#name_prefix)
  - [kms](#kms)
  - [cloudwatch\_log\_group](#cloudwatch_log_group)
    - [Centralized Configuration Pattern](#centralized-configuration-pattern)
    - [Benefits of Centralized Configuration](#benefits-of-centralized-configuration)
  - [oidc\_github](#oidc_github)
  - [security](#security)
- [Environment-Specific Configuration Examples](#environment-specific-configuration-examples)
- [Configuration Validation Checklist](#configuration-validation-checklist)
- [Related Documents](#related-documents)

## Initial Setting

This section describes the initial settings for running [management audit Terraform](./terraform/management/audit/). If an item has already been addressed, please skip to the next section.

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

You need to rename the linked file [terraform.example.tfvars for audit](terraform/management/audit/terraform.example.tfvars) and change each variable for your environment.

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

### slack_channel_id

Slack channel ID for security notifications. Required for Security Hub and other alerting features.

```terraform
security = {
  # TODO: need to set slack_channel_id for settings of AWS SecurityHub Notification(Slack).
  slack_channel_id = "C0XXXXXXXXX"
  # TODO: need to set slack_team_id for settings of AWS SecurityHub Notification(Slack).
  slack_team_id = "xxxxxxxxxxx"
}
```

### slack_team_id

Slack team/workspace ID for notifications.

See the `slack_channel_id` configuration above.

## Not Requirements

Although terraform apply will succeed without fixing the following items, the following is a list of things that should be changed for each environment.

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
  env = "audit"
  # TODO: need to change service.
  # Service/project name for resource grouping and identification
  # This should match your project name, job name, or product name
  service = "security-audit"
  # Map Program (optional)
  # Uncomment and set if you have a Migration Acceleration Program (MAP) assessment ID
  # This helps track resources for AWS migration programs
  # map-migrated = "xxxxxxxxxxxxx"
}
```

### name_prefix

Used as a prefix for resource names. This prefix helps identify resources belonging to this project and environment.

Example: If `name_prefix="audit-"`, resources will be named `"audit-sns"`, `"audit-lambda"`, etc.

```terraform
#--------------------------------------------------------------
# Name prefix
# It is used as a prefix attached to various resource names.
# This prefix helps identify resources belonging to this project and environment.
# Example: If name_prefix="myproject-", resources will be named "myproject-vpc", "myproject-lambda", etc.
#--------------------------------------------------------------
name_prefix = "audit-"
```

### kms

KMS key configuration for SNS encryption in audit environment.

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
    alias_name              = "audit-sns"
  }
}
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
    # common_lambda_vpc_flow_log = {
    #   retention_in_days = 7
    # }
  }
}
```

**Note**: The legacy `cloudwatch_log_group_retention_in_days` parameter is still supported for backward compatibility but is deprecated. Please migrate to the new `cloudwatch_log_group` configuration.

#### Benefits of Centralized Configuration

✅ **Single Source of Truth**: Define retention period once, apply everywhere

✅ **Flexible Overrides**: Set different retention for specific services

✅ **Easy Maintenance**: Update retention policies without modifying multiple configurations

✅ **Cost Optimization**: Easily identify and adjust services with long retention periods

✅ **Consistent Encryption**: Optionally use a common KMS key for all log encryption

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
    # "your-org/security-automation-repo",
  ]
  iam_role_name = "oidc-github-role"
  iam_role_path = "/"
}
```

### security

Security-related configurations including Security Hub and GuardDuty.

**AWS SECURITY HUB:**
- Provides centralized security findings from AWS services and partner products
- Continuously monitors your environment for security best practices
- Generates security scores and compliance reports

**AWS GUARDDUTY:**
- Intelligent threat detection for AWS accounts and workloads
- Monitors for malicious activity and unauthorized behavior
- Analyzes CloudTrail events, VPC Flow Logs, and DNS logs

**IMPORTANT:** Before using AWS Chatbot for Slack notifications:
1. Create a Slack app in your workspace
2. Obtain OAuth access token (starts with xoxb-)
3. Get your Slack channel ID (format: C0XXXXXXXXX)
4. Configure AWS Chatbot with your Slack workspace

For detailed setup instructions: [AWS Chatbot Documentation](https://docs.aws.amazon.com/chatbot/latest/adminguide/slack-setup.html)

**Cost Consideration:**
- Security Hub: $0.0010 per security check per region per month
- GuardDuty: ~$1.00 per GB of logs analyzed (VPC Flow Logs, DNS logs, CloudTrail events)

**Notice:** GuardDuty is automatically disabled if `use_control_tower=true`.

```terraform
#--------------------------------------------------------------
# Security
# Security-related configurations including Security Hub and GuardDuty.
#
# AWS SECURITY HUB:
# - Provides centralized security findings from AWS services and partner products
# - Continuously monitors your environment for security best practices
# - Generates security scores and compliance reports
#
# AWS GUARDDUTY:
# - Intelligent threat detection for AWS accounts and workloads
# - Monitors for malicious activity and unauthorized behavior
# - Analyzes CloudTrail events, VPC Flow Logs, and DNS logs
#
# IMPORTANT: Before using AWS Chatbot for Slack notifications:
# 1. Create a Slack app in your workspace
# 2. Obtain OAuth access token (starts with xoxb-)
# 3. Get your Slack channel ID (format: C0XXXXXXXXX)
# 4. Configure AWS Chatbot with your Slack workspace
# For detailed setup instructions: https://docs.aws.amazon.com/chatbot/latest/adminguide/slack-setup.html
#
# COST CONSIDERATIONS:
# - Security Hub: $0.0010 per security check per region per month
# - GuardDuty: ~$1.00 per GB of logs analyzed (VPC Flow Logs, DNS logs, CloudTrail events)
#
# NOTICE: GuardDuty is automatically disabled if use_control_tower=true.
#--------------------------------------------------------------
security = {
  #--------------------------------------------------------------
  # Security:SecurityHub
  #--------------------------------------------------------------
  # NOTE: Before using Chatbot functionality for Slack notifications, you must create a Slack client.
  # This involves setting up a Slack app and obtaining the necessary OAuth tokens and permissions.
  # For detailed setup instructions, refer to AWS Chatbot documentation:
  # https://docs.aws.amazon.com/chatbot/latest/adminguide/slack-setup.html
  # TODO: need to set slack_channel_id for settings of AWS SecurityHub Notification(Slack).
  slack_channel_id = "C0XXXXXXXXX"
  # TODO: need to set slack_team_id for settings of AWS SecurityHub Notification(Slack).
  slack_team_id = "xxxxxxxxxxx"
  securityhub = {
    # TODO: need to set is_enabled for settings of AWS SecurityHub.
    is_enabled = true
  }
  #--------------------------------------------------------------
  # GuardDuty
  # Amazon GuardDuty is a threat detection service that continuously monitors your AWS accounts and workloads for malicious activity and
  # delivers detailed security findings for visibility and remediation.
  # Notice: This option is automatically disabled if use_control_tower=true.
  # COST CONSIDERATION: ~$1.00 per GB of logs analyzed
  #--------------------------------------------------------------
  guardduty = {
    # TODO: need to set is_enabled for settings of AWS GuardDuty.
    is_enabled = true
  }
}
```

## Environment-Specific Configuration Examples

For audit environments, focus on security monitoring and compliance:

```hcl
# Tags for audit environment
tags = {
  env     = "audit"
  service = "security-audit"
}

# Security services configuration
security = {
  slack_channel_id = "C1234567890"  # Your actual Slack channel ID
  slack_team_id    = "T1234567890"  # Your actual Slack team ID
  securityhub = {
    is_enabled = true  # Enable for compliance monitoring
  }
  guardduty = {
    is_enabled = true  # Enable for threat detection
  }
}

# KMS configuration for audit environment
kms = {
  sns = {
    description             = "This key used for SNS."
    deletion_window_in_days = 7
    is_enabled              = true
    enable_key_rotation     = true
    alias_name              = "audit-sns"
  }
}

# GitHub Actions OIDC configuration
oidc_github = {
  is_enabled                      = true
  dangerously_attach_admin_policy = false  # Use least privilege in production
  attach_read_only_policy         = true
  create_oidc_provider            = true
  github_repositories = [
    "your-org/security-automation-repo",
  ]
  iam_role_name = "oidc-github-audit-role"
  iam_role_path = "/"
}
```

## Configuration Validation Checklist

| Category                        | Item                                                     | Status |
| ------------------------------- | -------------------------------------------------------- | ------ |
| Security Services Validation    | Slack channel and team IDs are correctly set             | [ ]    |
| Security Services Validation    | Security Hub is enabled for compliance monitoring        | [ ]    |
| Security Services Validation    | GuardDuty is enabled for threat detection                | [ ]    |
| Security Services Validation    | CloudWatch log retention meets compliance requirements   | [ ]    |
| GitHub Integration Validation   | OIDC provider settings are correct                       | [ ]    |
| GitHub Integration Validation   | GitHub repositories list is populated                    | [ ]    |
| GitHub Integration Validation   | IAM policies follow least privilege principle            | [ ]    |
| GitHub Integration Validation   | Admin policy is disabled for production environments     | [ ]    |
| Environment-Specific Validation | Tags reflect the audit environment                       | [ ]    |
| Environment-Specific Validation | Resource names use appropriate prefixes (e.g., "audit-") | [ ]    |
| Environment-Specific Validation | Region settings match deployment requirements            | [ ]    |
| KMS Configuration Validation    | KMS key rotation is enabled                              | [ ]    |
| KMS Configuration Validation    | Deletion window is set appropriately                     | [ ]    |
| AWS Chatbot Prerequisites       | Slack workspace integration is configured in AWS Chatbot | [ ]    |
| AWS Chatbot Prerequisites       | OAuth tokens are obtained from Slack                     | [ ]    |

## Related Documents

- [README-management-root-tfvars.md](./README-management-root-tfvars.md) - Root environment configuration documentation
- [README-base-tfvars.md](./README-base-tfvars.md) - Base configuration documentation
- [README-monitor-tfvars.md](./README-monitor-tfvars.md) - Monitor configuration documentation
- [README.md](./README.md) - Main project documentation
- [AWS Chatbot Documentation](https://docs.aws.amazon.com/chatbot/latest/adminguide/slack-setup.html) - Slack setup for AWS Chatbot
