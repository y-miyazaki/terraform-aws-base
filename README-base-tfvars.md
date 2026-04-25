<!-- omit in toc -->
# Base Terraform Configuration Guide

The example is [terraform.example.tfvars](terraform/base/terraform.example.tfvars). The following is a list of things that must be modified and things that should be modified when doing terraform apply for the first time.
If you need to adjust the parameters, you can do so by yourself by searching TODO.

<!-- omit in toc -->
## Table of Contents

- [Initial setting](#initial-setting)
- [Requirements](#requirements)
  - [region](#region)
  - [cloudwatch\_log\_group](#cloudwatch_log_group)
    - [Centralized Configuration Pattern](#centralized-configuration-pattern)
    - [Available Services for Override](#available-services-for-override)
    - [Benefits of Centralized Configuration](#benefits-of-centralized-configuration)
    - [Example Configuration](#example-configuration)
  - [support\_iam\_role\_principal\_arns](#support_iam_role_principal_arns)
  - [subscriber\_email\_addresses](#subscriber_email_addresses)
- [Not Requirements](#not-requirements)
  - [tags](#tags)
  - [name\_prefix](#name_prefix)
  - [oidc\_github](#oidc_github)
  - [resourcegroups\_group](#resourcegroups_group)
  - [iam](#iam)
  - [common\_lambda](#common_lambda)
  - [Slack](#slack)
    - [Centralized Slack Configuration](#centralized-slack-configuration)
    - [How Slack Configuration Works](#how-slack-configuration-works)
    - [Available Override Functions](#available-override-functions)
    - [Benefits of Centralized Configuration](#benefits-of-centralized-configuration-1)
  - [is\_enabled](#is_enabled)
  - [control\_tower](#control_tower)
  - [Environment-Specific Configuration Examples](#environment-specific-configuration-examples)
    - [Development Environment](#development-environment)
    - [Production Environment](#production-environment)
    - [Staging Environment](#staging-environment)
- [Configuration Validation](#configuration-validation)
- [Related Documents](#related-documents)

## Initial setting

This section describes the initial settings for running [Base's Terraform](./terraform/base/). If an item has already been addressed, please skip to the next section.

- **Remove the access key from the root account**

  Since this is a security issue, let's remove the access key from the root account from the management console.

- **Manual creation of IAM user and IAM group to run Terraform**

  Create an IAM user and an IAM group from the management console in order to run Terraform.
  
  Create an IAM group (pseudonym: deploy). Attach AdministratorAccess as the policy.
  
  Create an IAM user (pseudonym: terraform), giving it only Programmatic access for Access Type, and add it to the IAM group (pseudonym: deploy).

- **Create an S3 to store the Terraform State**

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
~
~
~
~
~
~
~
~
~
~
--------------------------------------------------------------
bucket_name: base-terraform-state-xxxxxxxxxx
region: ap-northeast-1
--------------------------------------------------------------
```

- **terraform.{environment}.tfvars file to configure for each environment**

  You need to rename the linked file [terraform.example.tfvars](terraform/base/terraform.example.tfvars) and change each variable for your environment. The variables that need to be changed are marked with TODO comments; search for them in TODO.

- **Running Terraform**

  Run the terraform command: terraform init followed by terraform apply.
  
  You may find that terraform apply fails due to conflicts or other problems, so run it again and it will succeed.

```sh
bash-5.1# terraform init
There are some problems with the CLI configuration:

Error: The specified plugin cache dir /root/.terraform.d/plugin-cache cannot be opened: stat /root/.terraform.d/plugin-cache: no such file or directory


As a result of the above problems, Terraform may not behave as intended.


Initializing modules...

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/template from the dependency lock file
- Installing hashicorp/aws v3.29.1...
- Installed hashicorp/aws v3.29.1 (signed by HashiCorp)
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)
- Installing hashicorp/template v2.2.0...
- Installed hashicorp/template v2.2.0 (signed by HashiCorp)

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```sh
bash-5.1# terraform apply --auto-approve -var-file=terraform.example.tfvars
module.aws_s3_bucket_log_log.random_id.this: Creating...
random_id.this: Creating...
module.aws_s3_bucket_log_*****_id.this: Creation complete after 0s [id=abcde]
random_id.this: Creation complete after 0s [id=uqe0bU7J]
module.aws_security_default_vpc.aws_default_subnet.this[1]: Creating...

...
...
...

Apply complete! resources: x added, x changed, 0 destroyed.
```

## Requirements

The following items must be modified; terraform apply will fail if you run it as an example.

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
    # common_lambda_vpc_flow_log = {
    #   retention_in_days = 7
    # }
    # guardduty = {
    #   retention_in_days = 30
    # }
    # health = {
    #   retention_in_days = 14
    # }
    # health_us_east_1 = {
    #   retention_in_days = 14
    # }
    # iam_password_expired = {
    #   retention_in_days = 14
    # }
    # security_cloudtrail = {
    #   retention_in_days = 90
    # }
    # security_config = {
    #   retention_in_days = 30
    # }
    # security_config_us_east_1 = {
    #   retention_in_days = 30
    # }
    # security_securityhub = {
    #   retention_in_days = 30
    # }
    # trusted_advisor = {
    #   retention_in_days = 14
    # }
  }
}
```

#### Available Services for Override

For the base environment, the following services support CloudWatch Log Group configuration overrides:

| Service Name                 | Description                            | Recommended Retention |
| ---------------------------- | -------------------------------------- | --------------------- |
| `budgets`                    | AWS Budget alerts and notifications    | 7 days                |
| `common_lambda_vpc_flow_log` | VPC Flow Logs processing Lambda        | 7 days                |
| `guardduty`                  | GuardDuty security findings            | 30 days               |
| `health`                     | AWS Health events (regional)           | 14 days               |
| `health_us_east_1`           | AWS Health events (global/us-east-1)   | 14 days               |
| `iam_password_expired`       | IAM password expiration notifications  | 14 days               |
| `security_cloudtrail`        | CloudTrail audit logs                  | 90 days               |
| `security_config`            | AWS Config compliance logs (regional)  | 30 days               |
| `security_config_us_east_1`  | AWS Config compliance logs (us-east-1) | 30 days               |
| `security_securityhub`       | SecurityHub findings and insights      | 30 days               |
| `trusted_advisor`            | Trusted Advisor recommendations        | 14 days               |

#### Benefits of Centralized Configuration

✅ **Single Source of Truth**: Define retention period once, apply everywhere

✅ **Flexible Overrides**: Set different retention for specific services (e.g., CloudTrail 90 days, others 14 days)

✅ **Easy Maintenance**: Update retention policies without modifying multiple configurations

✅ **Cost Optimization**: Easily identify and adjust services with long retention periods

✅ **Consistent Encryption**: Optionally use a common KMS key for all log encryption

#### Example Configuration

```terraform
# Development Environment - Short retention for cost savings
cloudwatch_log_group = {
  retention_in_days = 7
  kms_key_id = null
  override = {
    security_cloudtrail = {
      retention_in_days = 30  # Keep audit logs longer even in dev
    }
  }
}

# Production Environment - Compliance-focused retention
cloudwatch_log_group = {
  retention_in_days = 14
  kms_key_id = "arn:aws:kms:ap-northeast-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  override = {
    security_cloudtrail = {
      retention_in_days = 365  # 1 year for compliance
    }
    security_config = {
      retention_in_days = 90
    }
    guardduty = {
      retention_in_days = 90
    }
  }
}
```

> **Tip:** Global AWS Health events are delivered from the us-east-1 region. Use the `health_us_east_1` override when you need to align log retention for those events with the primary `health` function.

### support_iam_role_principal_arns

The following are the supporting IAM roles. If you are not sure, please specify your AWS Account ID once. For detailed documentation, please see

<https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.20-remediation>

**Important Notes:**
- This is required for Security Hub CIS compliance
- Use your AWS account ID in the format: `arn:aws:iam::{account-id}:root`
- Multiple account IDs can be specified for cross-account access

```terraform
  # TODO: need to set principal role arn for Support IAM Role.
  # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.20-remediation
  support_iam_role_principal_arns = [
    # example)
    # "arn:aws:iam::{account id}:{iam user}"
    "arn:aws:iam::123456789012:root"
  ]
```

### subscriber_email_addresses

The following are the supporting Budgets. If you want to receive Budgets notifications, you must set the email address for Budgets notifications to subscriber_email_addresses.

**Important Notes:**
- At least one email address is required when budgets are enabled
- Multiple email addresses can be specified
- Notifications will be sent when budget thresholds are exceeded

```terraform
#--------------------------------------------------------------
# Budgets
# CRITICAL SETTING: Always configure budget alerts to prevent unexpected costs
# Adjust limit_amount based on your environment:
# - Development: $50-200/month
# - Staging: $200-500/month
# - Production: $500+/month
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
  aws_lambda_function = {
    environment = {
      # TODO: need to change TIMEZONE.
      # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
      TIMEZONE = "Asia/Tokyo"
    }
  }
```

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
  env = "example"
  # TODO: need to change service.
  # Service/project name for resource grouping and identification
  # This should match your project name, job name, or product name
  service = "base"
  # Map Program (optional)
  # Uncomment and set if you have a Migration Acceleration Program (MAP) assessment ID
  # This helps track resources for AWS migration programs
  # map-migrated = "xxxxxxxxxxxxx"
}
```

### name_prefix

Used as a prefix for resource names.

```terraform
#--------------------------------------------------------------
# Name prefix
# It is used as a prefix attached to various resource names.
# This prefix helps identify resources belonging to this project and environment.
# Example: If name_prefix="myproject-", resources will be named "myproject-vpc", "myproject-lambda", etc.
#--------------------------------------------------------------
name_prefix = "base-"
```

### oidc_github

OIDC provider configuration for GitHub Actions.

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
  iam_role_policy_names = []
  # TODO: Flag to enable/disable the creation of the GitHub OIDC provider.
  create_oidc_provider = true
  # TODO: Set the org/repo of the GitHub repository to github_subjects.
  github_subjects = [
    # "your-repository/repository-name",
  ]
  iam_role_name = "oidc-github-role"
  iam_role_path = "/"
}
```

### resourcegroups_group

Resource Groups configuration.

```terraform
#--------------------------------------------------------------
# Resource Group
# AWS Resource Groups allow you to organize and manage AWS resources using tags.
# This creates a resource group that automatically includes all resources matching the specified tags.
# Useful for viewing all resources belonging to a specific environment or service in one place.
#--------------------------------------------------------------
resourcegroups_group = {
  # TODO: need to change is_enabled for settings of resourcegroups_group.
  is_enabled = true
}
```

### iam

IAM users, groups, and Switch Role configuration.

```terraform
#--------------------------------------------------------------
# IAM: Users
# AWS Identity and Access Management (IAM) configuration for users, groups, and policies.
# Manages user access, group memberships, and permission policies.
# Includes MFA enforcement, password policies, and role-based access control.
#--------------------------------------------------------------
iam = {
  # TODO: need to set is_enabled for settings of IAM.
  is_enabled = false
  #--------------------------------------------------------------
  # IAM Users Configuration
  # Define IAM users with console access and/or programmatic access (access keys).
  # Set is_console_access=true for AWS Management Console login.
  # Set is_access_key=true for CLI/API access via access keys.
  #--------------------------------------------------------------
  # TODO: need to change IAM User.
  user = {
    "test" = {
      is_console_access = false
      is_access_key     = false
    }
  }
  #--------------------------------------------------------------
  # IAM Groups Configuration
  #--------------------------------------------------------------
  # TODO: need to change IAM Group.
  # Please specify the user with the same name that has been set in users.
  group = {
    # TODO: need to change IAM Group name.
    # This name will be used as the group name.
    administrator = {
      # TODO: need to set is_enabled_mfa.
      # If true, force MFA settings and login.
      is_enabled_mfa = true
      # TODO: need to set users.
      users = [
        "test1",
      ]
      # TODO: need to set base policy.
      # Please specify the base policy to provide.
      # default null.
      # You need to check this document.
      # https://aws.amazon.com/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy_document = {
        name        = "iam-group-administrator-base-policy"
        path        = "/"
        description = ""
        statement = [
          #--------------------------------------------------------------
          # Admin default rule start
          #--------------------------------------------------------------
          {
            sid    = "DenyCloudTrailWrite"
            effect = "Deny"
            actions = [
              "cloudtrail:DeleteEventDataStore",
              "cloudtrail:PutEventSelectors",
              "cloudtrail:StopLogging",
              "cloudtrail:StartLogging",
              "cloudtrail:UpdateEventDataStore",
              "cloudtrail:UpdateTrail",
              "cloudtrail:RestoreEventDataStore",
              "cloudtrail:CancelQuery",
              "cloudtrail:CreateEventDataStore",
              "cloudtrail:PutInsightSelectors",
              "cloudtrail:AddTags",
              "cloudtrail:DeleteTrail",
              "cloudtrail:CreateTrail",
              "cloudtrail:StartQuery",
              "cloudtrail:RemoveTags",
            ]
            resources = [
              "*"
            ]
          }
          # ...existing code...
        ]
      }
      # TODO: need to add policy arn. group policy limit is 10.
      # You need to check this document.
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy = [
        {
          policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
        }
      ]
    }
    # TODO: need to change IAM Group name.
    # This name will be used as the group name.
    developer = {
      # TODO: need to set is_enabled_mfa.
      # If true, force MFA settings and login.
      is_enabled_mfa = true
      # TODO: need to set users.
      users = [
        "test2",
      ]
      # TODO: need to set base policy.
      # Please specify the base policy to provide.
      # default null.
      # You need to check this document.
      # https://aws.amazon.com/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy_document = {
        name        = "iam-group-developer-base-policy"
        path        = "/"
        description = ""
        statement = [
          #--------------------------------------------------------------
          # Default rule start
          #--------------------------------------------------------------
          {
            sid    = "AllowDefaultWidgetPage"
            effect = "Allow"
            actions = [
              "servicecatalog:ListApplications",
              "ce:GetCostAndUsage",
              "ce:GetCostForecast",
              "support:DescribeTrustedAdvisorChecks",
              "support:DescribeTrustedAdvisorCheckSummaries",
              "ram:ListResources",
              "health:DescribeEventAggregates",
            ]
            resources = [
              "*"
            ]
          }
          # ...existing code...
        ]
      }
      # TODO: need to add policy arn. group policy limit is 10.
      # You need to check this document.
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy = [
      ]
    }
    # TODO: need to change IAM Group name.
    # This name will be used as the group name.
    operator = {
      # TODO: need to set is_enabled_mfa.
      # If true, force MFA settings and login.
      is_enabled_mfa = true
      # TODO: need to set users.
      users = [
      ]
      # TODO: need to set base policy.
      # Please specify the base policy to provide.
      # default null.
      # You need to check this document.
      # https://aws.amazon.com/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy_document = {
        name        = "iam-group-operator-base-policy"
        path        = "/"
        description = ""
        statement = [
          #--------------------------------------------------------------
          # Default rule start
          #--------------------------------------------------------------
          {
            sid    = "AllowDefaultWidgetPage"
            effect = "Allow"
            actions = [
              "servicecatalog:ListApplications",
              "ce:GetCostAndUsage",
              "ce:GetCostForecast",
              "support:DescribeTrustedAdvisorChecks",
              "support:DescribeTrustedAdvisorCheckSummaries",
              "ram:ListResources",
              "health:DescribeEventAggregates",
            ]
            resources = [
              "*"
            ]
          }
          # ...existing code...
        ]
      }
      # TODO: need to add policy arn. group policy limit is 10.
      # You need to check this document.
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy = []
    }
    # TODO: need to change IAM Group name.
    # This name will be used as the group name.
    deploy_infra = {
      # TODO: need to set is_enabled_mfa.
      # If true, force MFA settings and login.
      is_enabled_mfa = false
      # TODO: need to set users.
      users = [
      ]
      # TODO: need to set base policy.
      # Please specify the base policy to provide.
      # default null.
      # You need to check this document.
      # https://aws.amazon.com/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy_document = null
      # TODO: need to add policy arn. group policy limit is 10.
      # You need to check this document.
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy = [
        {
          policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
        }
      ]
    }
    # TODO: need to change IAM Group name.
    # This name will be used as the group name.
    deploy_code = {
      # TODO: need to set is_enabled_mfa.
      # If true, force MFA settings and login.
      is_enabled_mfa = false
      # TODO: need to set users.
      users = [
        "deploy-static-contents",
      ]
      # TODO: need to set base policy.
      # Please specify the base policy to provide.
      # default null.
      # You need to check this document.
      # https://aws.amazon.com/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy_document = {
        name        = "iam-group-deploy-code-base-policy"
        path        = "/"
        description = ""
        statement = [
          {
            sid    = "AllowS3"
            effect = "Allow"
            actions = [
              "s3:Get*",
              "s3:List*",
              "s3:HeadBucket",
              "s3:PutObject",
              "s3:DeleteObject",
            ]
            resources = [
              "arn:aws:s3:::dev-*",
              "arn:aws:s3:::dev-*/*",
              "arn:aws:s3:::base-*/*/Athena/*",
            ]
          }
          # ...existing code...
        ]
      }
      # TODO: need to add policy arn. group policy limit is 10.
      # You need to check this document.
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy = []
    }
  }
  #--------------------------------------------------------------
  # Variable settings for SwitchRole.
  # This role is used when switching from another AWS environment and not registering an IAM user.
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html
  #--------------------------------------------------------------
  switch_role = {
    # These are the settings for the original AWS account that will use SwitchRole.
    from = {
      # TODO: need to set is_enabled for switch role(from).
      is_enabled = false
      group = {
        # TODO: need to change IAM Group name.
        # An IAM policy for the SwitchRole will be attached to the group with the specified name.
        administrator = {
          aws_iam_policy = {
            name        = "iam-switch-from-administrator-policy"
            path        = "/"
            description = ""
            statement = [
              {
                sid    = "AllowSwitchFromAccountAdministrator"
                effect = "Allow"
                actions = [
                  "sts:AssumeRole",
                ]
                resources = [
                  # TODO: need to change AWS account ID(123456789012) and role name
                  # Specify the original AWS account ID(123456789012) that will use the IAM Switch role.
                  # Specify the AWS Account ID(123456789012) of the switch destination.
                  "arn:aws:iam::123456789012:role/base-iam-switch-to-administrator-role",
                ]
              },
            ]
          }
        }
        # ...existing code...
      }
    }
    # These are the settings for the AWS account to which the SwitchRole is to be used.
    to = {
      # TODO: need to set is_enabled for switch role(to).
      is_enabled = false
      role = {
        # TODO: need to change IAM switch role name.
        # Part of this name will be used as the switch role name.
        administrator = {
          # TODO: need to change IAM switch role.
          aws_iam_role = {
            name        = "iam-switch-to-administrator-role"
            path        = "/"
            description = ""
            # TODO: need to change AWS account ID(123456789012)
            # Specify the original AWS account ID(123456789012) that will use the IAM Switch role.
            # Specify the AWS Account ID(123456789012) of the switch source.
            account_id         = "123456789012"
            assume_role_policy = null
          }
          # TODO: need to set base policy.
          # Please specify the base policy to provide.
          # default null.
          # You need to check this document.
          # https://aws.amazon.com/premiumsupport/knowledge-center/iam-increase-policy-size/
          aws_iam_policy = {
            name        = "iam-group-administrator-base-policy"
            path        = "/"
            description = ""
            statement = [
              #--------------------------------------------------------------
              # Admin default rule start
              #--------------------------------------------------------------
              {
                sid    = "DenyCloudTrailWrite"
                effect = "Deny"
                actions = [
                  "cloudtrail:DeleteEventDataStore",
                  "cloudtrail:PutEventSelectors",
                  "cloudtrail:StopLogging",
                  "cloudtrail:StartLogging",
                  "cloudtrail:UpdateEventDataStore",
                  "cloudtrail:UpdateTrail",
                  "cloudtrail:RestoreEventDataStore",
                  "cloudtrail:CancelQuery",
                  "cloudtrail:CreateEventDataStore",
                  "cloudtrail:PutInsightSelectors",
                  "cloudtrail:AddTags",
                  "cloudtrail:DeleteTrail",
                  "cloudtrail:CreateTrail",
                  "cloudtrail:StartQuery",
                  "cloudtrail:RemoveTags",
                ]
                resources = [
                  "*"
                ]
              }
              # ...existing code...
            ]
          }
          # TODO: need to add policy arn. group policy limit is 10.
          # You need to check this document.
          # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
          policy = [
            {
              policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
            }
          ]
        }
        # ...existing code...
      }
    }
  }
}
```

### common_lambda

Common Lambda function configuration.

```terraform
#--------------------------------------------------------------
# Common:Lambda
# Common configuration for Lambda functions used across security and monitoring features.
# Optionally run Lambda functions inside VPC for access to private resources.
# Configure VPC settings, IAM roles, and policies for Lambda execution.
#--------------------------------------------------------------
common_lambda = {
  vpc = {
    # TODO: If you want to run LambdaFunctions inside a VPC, set to true. However,
    # VPC requires more cost since you need to configure NAT Gateway and other settings.
    is_enabled = false
    # TODO: If a VPC has already been established, specify false; if a new VPC is to be created, specify true.
    create_vpc = true

    # TODO: To specify a VPC that already exists, configure the following settings for Lambda.
    # If var.common_lambda.vpc.is_enabled = true and var.common_lambda.vpc.create_vpc = false,
    # the Lambda will be built in an existing VPC by referencing the parameters here.
    exists = {
      private_subnets = [
        "subnet-xxxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxxx",
      ]
      security_group_id = "sg-xxxxxxxxxxxxxxxxx"
      private_subnets_us_east_1 = [
        "subnet-xxxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxxx",
      ]
      security_group_id_us_east_1 = "sg-xxxxxxxxxxxxxxxxx"
    }
    # TODO: To specify a new VPC to be set up for Lambda, please set the following information.
    # If var.common_lambda.vpc.is_enabled = true and var.common_lambda.vpc.create_vpc = true,
    # a new VPC is built by referencing the parameters here.
    new = {
      name = "vpc-lambda"
      cidr = "10.0.0.0/16"
      azs = [
        "ap-northeast-1a",
        "ap-northeast-1c",
        "ap-northeast-1d",
      ]
      azs_us_east_1 = [
        "us-east-1a",
        "us-east-1b",
        "us-east-1c",
      ]
      private_subnets = [
        "10.0.1.0/24",
        "10.0.2.0/24",
        "10.0.3.0/24"
      ]
      public_subnets = [
        "10.0.101.0/24",
        "10.0.102.0/24",
        "10.0.103.0/24"
      ]
      enable_dns_support   = true
      enable_dns_hostnames = true

      # No NAT Gateway(private subnet can't access internet.)
      #   enable_nat_gateway     = false
      #   single_nat_gateway     = false
      #   one_nat_gateway_per_az = false

      # One NAT Gateway per subnet (default behavior)
      enable_nat_gateway     = true
      single_nat_gateway     = false
      one_nat_gateway_per_az = false

      # VPN Gateway
      enable_vpn_gateway = false

      # Flow Log(plain-text or parquet)
      enable_flow_log                                 = true
      create_flow_log_cloudwatch_log_group            = true
      create_flow_log_cloudwatch_iam_role             = true
      flow_log_cloudwatch_log_group_retention_in_days = 7
      flow_log_file_format                            = "plain-text"
    }
  }
  aws_iam_role = {
    description = ""
    name        = "security-lambda-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = ""
    name        = "security-lambda-policy"
    path        = "/"
  }
}
```

### Slack

**IMPORTANT: Slack configuration has been significantly improved with centralized management.**

Instead of configuring Slack credentials for each Lambda function individually, you can now manage them centrally with function-specific overrides when needed.

#### Centralized Slack Configuration

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
  
  # TODO: need to change SLACK_CHANNEL_ID (default channel for all notifications)
  # Right-click on your Slack channel and select "Copy link" to find the channel ID
  channel_id = "C0XXXXXXXXX"

  # Optional: Override slack settings for specific Lambda functions
  # Use this to send specific alerts to different channels
  override = {
    # Example: Send GuardDuty alerts to security team channel
    # guardduty = {
    #   channel_id = "C-SECURITY-CHANNEL"
    # }
    
    # Example: Send Health alerts to operations channel
    # health = {
    #   channel_id = "C-OPS-CHANNEL"
    # }
    
    # Example: Send CloudTrail alerts to audit channel
    # security_cloudtrail = {
    #   channel_id = "C-AUDIT-CHANNEL"
    # }
  }
}
```

#### How Slack Configuration Works

**Priority System:**

1. **Override (Highest)**: Function-specific channel in `slack.override.<function_name>`
2. **Default (Lowest)**: Common channel in `slack.channel_id`

**Example Configuration:**
```terraform
slack = {
  oauth_access_token = "xoxb-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
  channel_id = "C0XXXXXXXXX"  # Default channel for all notifications
  
  override = {
    # Send security alerts to dedicated channel
    guardduty = { channel_id = "C0XXXXXXXXX" }
    security_cloudtrail = { channel_id = "C0XXXXXXXXX" }
    security_config = { channel_id = "C0XXXXXXXXX" }
    
    # Send cost alerts to finance channel
    budgets = { channel_id = "C0XXXXXXXXX" }
    
    # Operations alerts to ops channel
    health = { channel_id = "C0XXXXXXXXX" }
  }
}
```

#### Available Override Functions

| Function Name               | Description                           |
| --------------------------- | ------------------------------------- |
| `budgets`                   | Budget alerts                         |
| `guardduty`                 | GuardDuty findings                    |
| `health`                    | AWS Health events                     |
| `trusted_advisor`           | Trusted Advisor checks                |
| `iam_password_expired`      | IAM password expiration warnings      |
| `security_cloudtrail`       | CloudTrail security events            |
| `security_config`           | AWS Config compliance changes         |
| `security_config_us_east_1` | AWS Config for CloudFront (us-east-1) |

#### Benefits of Centralized Configuration

✅ **Single Source of Truth**: Manage OAuth token in one place

✅ **Flexible Routing**: Route different alerts to different channels without changing Lambda code

✅ **Easy Maintenance**: Update channel IDs without modifying multiple configurations

✅ **Type Safety**: Terraform validates configuration structure

**Note**: If you don't configure Slack settings, notifications will fail but deployment will succeed.

### is_enabled

The variable for each function has is_enabled. If you do not want to use it as a function, you can disable it by specifying false.

- IAM OIDC for GitHub Actions

```terraform
#--------------------------------------------------------------
# IAM OIDC for GitHub Actions
# Terraform module to configure GitHub Actions as an IAM OIDC identity provider in AWS.
# The target ARN is output(oidc_github_iam_role_arn) for the target ARN.
# ex) oidc_github_iam_role_arn = "arn:aws:iam::{aws_account_id}:role/{iam_role_name}"
#--------------------------------------------------------------
oidc_github = {
  # TODO: need to set is_enabled for settings of IAM OIDC for GitHub Actions.
  is_enabled = true
```

- Budgets

```terraform
#--------------------------------------------------------------
# Budgets
# CRITICAL SETTING: Always configure budget alerts to prevent unexpected costs
# Adjust limit_amount based on your environment:
# - Development: $50-200/month
# - Staging: $200-500/month
# - Production: $500+/month
#--------------------------------------------------------------
budgets = {
  # TODO: need to set is_enabled for settings of budgets.
  is_enabled = true
```

- IAM

```terraform
#--------------------------------------------------------------
# IAM: Users
# AWS Identity and Access Management (IAM) configuration for users, groups, and policies.
# Manages user access, group memberships, and permission policies.
# Includes MFA enforcement, password policies, and role-based access control.
#--------------------------------------------------------------
iam = {
  # TODO: need to set is_enabled for settings of IAM.
  is_enabled = false
```

- Compute Optimizer

```terraform
#--------------------------------------------------------------
# Compute Optimizer
# AWS Compute Optimizer recommends optimal AWS resources for your workloads to reduce
# costs and improve performance by using machine learning to analyze historical utilization metrics.
# Over-provisioning resources can lead to unnecessary infrastructure cost, and under-provisioning resources
# can lead to poor application performance. Compute Optimizer helps you choose optimal configurations
# for three types of AWS resources: Amazon EC2 instances, Amazon EBS volumes, and AWS Lambda functions,
# based on your utilization data.
#--------------------------------------------------------------
compute_optimizer = {
  # TODO: need to set is_enabled for settings of Compute Optimizer.
  is_enabled = true
```

- GuardDuty

```terraform
#--------------------------------------------------------------
# GuardDuty
# Amazon GuardDuty is a threat detection service that continuously monitors your AWS accounts and workloads for malicious activity and
# delivers detailed security findings for visibility and remediation.
# Notice: This option is automatically disabled if control_tower.managed_services.guardduty=true.
# COST CONSIDERATION: ~$1.00 per GB of logs analyzed
#--------------------------------------------------------------
guardduty = {
  # TODO: need to set is_enabled for settings of AWS GuardDuty.
  is_enabled = false
}
```

- Health

```terraform
#--------------------------------------------------------------
# Health
# AWS Health provides personalized information about events that can affect your AWS infrastructure.
# This monitors AWS Health events and sends notifications to Slack when issues occur.
# Monitors both regional (ap-northeast-1) and global (us-east-1) health events.
#--------------------------------------------------------------
health = {
  # TODO: need to set is_enabled for settings of AWS Health.
  is_enabled = true
```

- Trusted Advisor

```terraform
#--------------------------------------------------------------
# Trusted Advisor
# AWS Trusted Advisor provides real-time guidance to help you provision resources following AWS best practices.
# Checks cost optimization, performance, security, fault tolerance, and service limits.
# NOTE: Full Trusted Advisor checks require Business or Enterprise support plan.
#--------------------------------------------------------------
trusted_advisor = {
  # TODO: need to set is_enabled for settings of Trusted Advisor.
  // If you are not in a business or enterprise plan with a support plan, set is_enable to false as notifications will fail. If not, set it to true.
  is_enabled = false
```

- IAM password expired

```terraform
#--------------------------------------------------------------
# IAM password expired
# A list of target users will be automatically notified in Slack 10 days before the IAM password expires.
#--------------------------------------------------------------
iam_password_expired = {
  # TODO: need to set is_enabled for settings of IAM password expired.
  is_enabled = false
```

- Security:Access Analyzer

```terraform
#--------------------------------------------------------------
# Security:Access Analyzer
# AWS IAM Access Analyzer helps identify resources in your organization and accounts that are shared with external entities.
# Analyzes resource-based policies and generates findings for resources with public or cross-account access.
# Helps ensure that only intended access to resources is allowed.
# Notice: This option is automatically disabled if control_tower.managed_services.access_analyzer=true.
#--------------------------------------------------------------
security_access_analyzer = {
  # TODO: need to set is_enabled for settings of Access Analyzer.
  is_enabled = true
```

- Security:Athena

```terraform
#--------------------------------------------------------------
# Security:Athena
# AWS Athena security configuration for query results encryption.
# Changes the EncryptionConfiguration setting of Athena's Workgroup(primary) to SSE_S3.
# Ensures that all query results are encrypted at rest using S3 server-side encryption.
#--------------------------------------------------------------
security_athena = {
  # TODO: need to set is_enabled for settings of Athena.
  is_enabled = true
```

- Security:CloudTrail

```terraform
#--------------------------------------------------------------
# Security:CloudTrail
# Notice: This option is automatically disabled if control_tower.managed_services.cloudtrail=true.
#--------------------------------------------------------------
security_cloudtrail = {
  # TODO: need to set is_enabled for settings of CloudTrail.
  is_enabled = false
```

- Security:AWS Config

```terraform
#--------------------------------------------------------------
# Security:AWS Config
# Notice: This option is automatically disabled if control_tower.managed_services.config=true.
#--------------------------------------------------------------
security_config = {
  # TODO: need to set is_enabled for settings of AWS Config.
  is_enabled = false
```

- Security:AWS Config(us-east-1(CloudFront))

```terraform
#--------------------------------------------------------------
# Security:AWS Config(us-east-1(CloudFront))
# Notice: This option is automatically disabled if control_tower.managed_services.config=true.
#--------------------------------------------------------------
security_config_us_east_1 = {
  # TODO: need to set is_enabled for settings of AWS Config.
  is_enabled = false
```

- Security: Default VPC

```terraform
#--------------------------------------------------------------
# Security:Default VPC
# Security configuration for the default VPC in each region.
# Enables VPC Flow Logs for network traffic monitoring and analysis.
# Optionally creates VPC Endpoints to resolve Security Hub EC2.10 finding (costs ~$10/month per VPC).
#--------------------------------------------------------------
security_default_vpc = {
  # TODO: need to set is_enabled for settings of default VPC security.
  is_enabled           = true
```

- Security: EBS

```terraform
#--------------------------------------------------------------
# Security:EBS
# Manage EBS account-level security defaults: EBS Encryption by Default
# and public snapshot access blocking. See `modules/aws/security/ebs` for
# implementation details.
#--------------------------------------------------------------
security_ebs = {
  # TODO: need to set is_enabled for EBS security controls
  is_enabled = true

  # TODO: need to set is_enabled for enabling EBS encryption by default
  is_enabled_ebs_encryption_by_default = true
  # TODO: need to set is_enabled for blocking public access to EBS snapshots
  is_enabled_ebs_public_snapshot_block_access = true
}
```

- Security:EC2 Instance Metadata Defaults

Enforces IMDSv2 as the default for all new EC2 instances at the account level. This addresses Security Hub control EC2.8.

```terraform
security_ec2_metadata = {
  is_enabled = true
}
```

- Security:ECR Account Settings

Enforces ECR basic scan type to use AWS native scanning technology at the account level.

```terraform
security_ecr = {
  is_enabled = true
}
```

- Security:GuardDuty

```terraform
#--------------------------------------------------------------
# Security:GuardDuty
# Amazon GuardDuty provides intelligent threat detection for your AWS environment.
# Continuously monitors for malicious activity and unauthorized behavior using machine learning.
# Detects reconnaissance, instance compromise, account compromise, and bucket compromise.
# Notice: This option is automatically disabled if control_tower.managed_services.guardduty=true.
#--------------------------------------------------------------
security_guardduty = {
  # TODO: need to set is_enabled for settings of GuardDuty.
  is_enabled = false
```

- Security:IAM

```terraform
#--------------------------------------------------------------
# Security:IAM
# IAM security settings including password policy and support role configuration.
# Configures account-wide password requirements (length, complexity, expiration, reuse prevention).
# Creates IAM role for AWS Support access as required by CIS benchmark 1.20.
#--------------------------------------------------------------
security_iam = {
  # TODO: need to set is_enabled for settings of IAM security.
  is_enabled = true
```

- Security:S3

```terraform
#--------------------------------------------------------------
# Security:S3
# S3 account-level public access block configuration.
# Prevents accidental public exposure of S3 buckets and objects across the entire AWS account.
# These settings apply to all buckets in the account unless explicitly overridden.
#--------------------------------------------------------------
security_s3 = {
  # TODO: need to set is_enabled for settings of S3 security.
  is_enabled = true
```

- Security:SecurityHub

```terraform
#--------------------------------------------------------------
# Security:SecurityHub
# AWS Security Hub provides a comprehensive view of security alerts and compliance status.
# Aggregates findings from GuardDuty, Inspector, Macie, IAM Access Analyzer, and AWS Config.
# Enables security standards compliance checks (CIS AWS Foundations, PCI DSS, AWS Foundational Security Best Practices).
# Notice: This option is automatically disabled if control_tower.managed_services.securityhub=true.
#--------------------------------------------------------------
security_securityhub = {
  # TODO: need to set is_enabled for settings of SecurityHub.
  is_enabled = false
```

- Security:SSM Automation

```terraform
#--------------------------------------------------------------
# Security:SSM Automation
# SSM.6 and SSM.7 compliance settings for AWS Systems Manager Automation.
# Enables CloudWatch logging for SSM Automation to meet SSM.6 control requirements.
# Disables public sharing of SSM Automation documents to comply with SSM.7 control.
#--------------------------------------------------------------
security_ssm_automation = {
  # TODO: need to set is_enabled for settings of SSM Automation.
  is_enabled = true
```

### control_tower

Use this object when AWS Control Tower and organization-managed security services are part of your environment design.

`control_tower.is_enabled` describes whether Control Tower is enabled in the environment.
`control_tower.managed_services` controls which services are treated as centrally managed outside this base stack. When a service flag is omitted, it falls back to `control_tower.is_enabled`.

```terraform
#--------------------------------------------------------------
# Control Tower and organization-managed security services
# Use this object to define whether Control Tower is enabled and which
# services are centrally managed outside this base stack.
# If managed_services.<service> is omitted, it falls back to is_enabled.
#
# Verification: Run the following AWS CLI commands from the management (root) account
# to check whether each service is centrally managed by Control Tower or Organizations.
#
# Control Tower landing zone:
#   aws controltower list-landing-zones
#
# Delegated administrators per service (run from root account).
# If DelegatedAdministrators[] is non-empty, the service is delegated
# to another account (typically the audit account) and the corresponding
# managed_services flag should be set to true.
#   aws organizations list-delegated-administrators --service-principal access-analyzer.amazonaws.com
#   aws organizations list-delegated-administrators --service-principal config.amazonaws.com
#   aws organizations list-delegated-administrators --service-principal guardduty.amazonaws.com
#   aws organizations list-delegated-administrators --service-principal securityhub.amazonaws.com
#
# CloudTrail is managed directly by Control Tower on the root account (not via delegated admin).
# Verify with (run from root account):
#   aws cloudtrail describe-trails --query 'trailList[?IsOrganizationTrail==`true`].Name'
#--------------------------------------------------------------
# TODO: need to change Control Tower settings.
control_tower = {
  # aws controltower list-landing-zones (run from root account)
  is_enabled = false
  managed_services = {
    # aws organizations list-delegated-administrators --service-principal access-analyzer.amazonaws.com
    access_analyzer = false
    # aws cloudtrail describe-trails --query 'trailList[?IsOrganizationTrail==`true`].Name' (run from root account)
    cloudtrail = false
    # aws organizations list-delegated-administrators --service-principal config.amazonaws.com
    config = false
    # aws organizations list-delegated-administrators --service-principal guardduty.amazonaws.com
    guardduty = false
    # aws organizations list-delegated-administrators --service-principal securityhub.amazonaws.com
    securityhub = false
  }
}
```

By default, setting `control_tower.is_enabled = true` will treat the following services as organization-managed unless you override them individually:

- Access Analyzer
- CloudTrail
- GuardDuty
- SecurityHub
- AWS Config (both regional and us-east-1)

This helps prevent duplicate configurations and potential conflicts between Terraform-managed resources and centrally managed services, while still allowing service-by-service overrides during migration.

### Environment-Specific Configuration Examples

#### Development Environment
```terraform
# Development environment - minimal security, cost-effective settings
control_tower = {
  is_enabled = false
}

# Enable only essential services
guardduty = {
  is_enabled = false  # Disable for cost savings in dev
}

security_config = {
  is_enabled = false  # Disable Config for dev
}

security_cloudtrail = {
  is_enabled = false  # Use default CloudTrail if available
}

# Minimal monitoring
budgets = {
  is_enabled = true
  aws_budgets_budget = {
    limit_amount = "50.0"  # Lower budget for dev
    time_unit    = "MONTHLY"
  }
}
```

#### Production Environment
```terraform
# Production environment - full security and compliance
control_tower = {
  is_enabled = true
}  # If using Control Tower

# Enable all security services
guardduty = {
  is_enabled = true
}

security_config = {
  is_enabled = true
}

security_cloudtrail = {
  is_enabled = true
}

# Comprehensive monitoring
budgets = {
  is_enabled = true
  aws_budgets_budget = {
    limit_amount = "500.0"  # Higher budget for prod
    time_unit    = "MONTHLY"
  }
}
```

#### Staging Environment
```terraform
# Staging environment - moderate security, testing-focused
control_tower = {
  is_enabled = false
}

# Selective security services
guardduty = {
  is_enabled = true
}

security_config = {
  is_enabled = false  # Disable for cost, enable if required
}

security_cloudtrail = {
  is_enabled = true
}

# Moderate monitoring
budgets = {
  is_enabled = true
  aws_budgets_budget = {
    limit_amount = "200.0"
    time_unit    = "MONTHLY"
  }
}
```

## Configuration Validation

| Category                        | Item                                                                                                    | Status |
| ------------------------------- | ------------------------------------------------------------------------------------------------------- | ------ |
| Security Services Validation    | If `control_tower.is_enabled = true`, verify that centrally managed services are configured as intended | [ ]    |
| Security Services Validation    | `security_access_analyzer.is_enabled = false` (when using Control Tower)                                | [ ]    |
| Security Services Validation    | `security_config.is_enabled = false` (when using Control Tower)                                         | [ ]    |
| Security Services Validation    | `security_cloudtrail.is_enabled = false` (when using Control Tower)                                     | [ ]    |
| Security Services Validation    | `guardduty.is_enabled = false` (when using Control Tower)                                               | [ ]    |
| Security Services Validation    | `security_securityhub.is_enabled = false` (when using Control Tower)                                    | [ ]    |
| Security Services Validation    | If `control_tower.is_enabled = false`, consider enabling security services based on your needs          | [ ]    |
| Security Services Validation    | Verify IAM roles and policies are correctly configured for enabled services                             | [ ]    |
| Budget Validation               | Set appropriate `limit_amount` based on your environment                                                | [ ]    |
| Budget Validation               | Development: $50-200/month                                                                              | [ ]    |
| Budget Validation               | Staging: $200-500/month                                                                                 | [ ]    |
| Budget Validation               | Production: $500+/month                                                                                 | [ ]    |
| Budget Validation               | Configure at least one email address for budget notifications                                           | [ ]    |
| Budget Validation               | Test budget alerts with a low threshold first                                                           | [ ]    |
| Environment-Specific Validation | Development: Minimal services enabled, cost-optimized settings                                          | [ ]    |
| Environment-Specific Validation | Staging: Moderate security, testing-friendly configuration                                              | [ ]    |
| Environment-Specific Validation | Production: Full security, comprehensive monitoring, strict thresholds                                  | [ ]    |
| Cost Optimization Validation    | Disable unused services to reduce costs                                                                 | [ ]    |
| Cost Optimization Validation    | Set appropriate retention periods for logs                                                              | [ ]    |
| Cost Optimization Validation    | Configure monitoring intervals based on criticality                                                     | [ ]    |
| Cost Optimization Validation    | Review KMS key rotation settings                                                                        | [ ]    |
| Slack Integration Validation    | Verify Slack OAuth token is valid and has required permissions                                          | [ ]    |
| Slack Integration Validation    | Confirm channel ID is correct and bot has access                                                        | [ ]    |
| Slack Integration Validation    | Test notifications with a simple alert first                                                            | [ ]    |

## Related Documents

- [README-monitor-tfvars.md](./README-monitor-tfvars.md) - Monitor configuration documentation
- [README-management-root-tfvars.md](./README-management-root-tfvars.md) - Management root environment configuration
- [README-management-audit-tfvars.md](./README-management-audit-tfvars.md) - Management audit environment configuration
- [README.md](./README.md) - Main project documentation
- [AWS Control Tower User Guide](https://docs.aws.amazon.com/controltower/latest/userguide/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)
- [AWS Organizations User Guide](https://docs.aws.amazon.com/organizations/latest/userguide/)
- [AWS Config Developer Guide](https://docs.aws.amazon.com/config/latest/developerguide/)
- [AWS Security Hub User Guide](https://docs.aws.amazon.com/securityhub/latest/userguide/)
