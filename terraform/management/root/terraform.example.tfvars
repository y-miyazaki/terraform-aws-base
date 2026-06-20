#--------------------------------------------------------------
# Basically, it is already set so that the setting is completed only by changing tfvars.
# All parameters that need to be changed for each environment are described in TODO comments.
#
# ENVIRONMENT-SPECIFIC CONFIGURATION GUIDE:
# - Root Environment: Organizational governance, budgets, policies, CloudTrail audit
#
# IMPORTANT: Always review and adjust these settings based on your organization's
# governance requirements, compliance needs, and cost constraints.
#--------------------------------------------------------------

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

#--------------------------------------------------------------
# Name prefix
# It is used as a prefix attached to various resource names.
# This prefix helps identify resources belonging to this project and environment.
# Example: If name_prefix="myproject-", resources will be named "myproject-vpc", "myproject-lambda", etc.
#--------------------------------------------------------------
name_prefix = "base-"

#--------------------------------------------------------------
# Region Configuration
# - global:  Global resources (CloudFront, WAF, ACM) — must be us-east-1
# - primary: Development and operations base region (fallback for provider)
# - targets: All regions where resources are deployed
#--------------------------------------------------------------
region = {
  # TODO: Global resources (CloudFront, Route53, WAF, ACM) — must be us-east-1
  global = "us-east-1"
  # TODO: Development and operations base region (fallback for provider)
  primary = "ap-northeast-1"
  # TODO: All regions where resources are deployed
  targets = ["ap-northeast-1", "us-east-1"]
}

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

  # Optional: Override settings for specific services
  # Uncomment and configure as needed
  override = {
    # budgets = {
    #   retention_in_days = 7
    # }
    # common_lambda_vpc_flow_log = {
    #   retention_in_days = 7
    # }
    # security_cloudtrail = {
    #   retention_in_days = 90
    # }
  }
}

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
  # Optional: Override slack settings for specific Lambda functions
  # Uncomment and configure as needed
  override = {
    # budgets = {
    #   channel_id = "C0XXXXXXXXX"
    # }
    # security_cloudtrail = {
    #   channel_id = "C0XXXXXXXXX"
    # }
  }
}

#--------------------------------------------------------------
# KMS
# AWS Key Management Service (KMS) keys for encrypting sensitive data.
# These keys are used to encrypt many services.
# Enable key rotation for enhanced security (rotates keys annually).
#--------------------------------------------------------------
kms = {
  root = {
    description             = "This key used for root default."
    deletion_window_in_days = 7
    is_enabled              = true
  }
}

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
    }
    # TODO: To specify a new VPC to be set up for Lambda, please set the following information.
    # If var.common_lambda.vpc.is_enabled = true and var.common_lambda.vpc.create_vpc = true,
    # a new VPC is built by referencing the parameters here.
    new = {
      name = "vpc-lambda"
      cidr = "10.0.0.0/16"
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
      enable_flow_log                           = true
      create_flow_log_cloudwatch_log_group      = true
      create_flow_log_cloudwatch_iam_role       = true
      flow_log_max_aggregation_interval         = 600
      flow_log_cloudwatch_log_group_name_prefix = "/aws/vpc-flow-log/"
      flow_log_file_format                      = "plain-text"
    }
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
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowSpecificRegions"
        Effect = "Deny"
        NotAction = [
          "a4b:*",
          "acm:*",
          "aws-marketplace-management:*",
          "aws-marketplace:*",
          "batch:*",
          "budgets:*",
          "ce:*",
          "chime:*",
          "cloudfront:*",
          "config:*",
          "cognito-identity:*",
          "cognito-idp:*",
          "cognito-sync:*",
          "cur:*",
          "directconnect:*",
          "ec2:*",
          "ecs:*",
          "fms:*",
          "globalaccelerator:*",
          "glue:*",
          "health:*",
          "iam:*",
          "importexport:*",
          "kinesis:*",
          "kms:*",
          "lambda:*",
          "lightsail:*",
          "logs:*",
          "organizations:*",
          "pricing:*",
          "rds-data:*",
          "route53:*",
          "route53domains:*",
          "s3:*",
          "secretsmanager:*",
          "ses:*",
          "shield:*",
          "sns:*",
          "sqs:*",
          "states:*",
          "sts:*",
          "support:*",
          "trustedadvisor:*",
          "waf-regional:*",
          "waf:*",
          "wafv2:*",
          "wellarchitected:*",
          "xray:*",
        ],
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
  is_enabled = true
  aws_cloudwatch_log = {
    cloudtrail_logs_terminate = {
      aws_cloudwatch_log_metric_filter = {
        name    = "cloudtrail-logs-terminate"
        pattern = <<PATTERN
{ $.eventName = "Terminate*" }
PATTERN
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
        period              = 60
        statistic           = "Sum"
        threshold           = 1
        threshold_metric_id = null
        actions_enabled     = true
        alarm_description   = "Alert Security Notification"
        datapoints_to_alarm = 1
        dimensions          = null
        treat_missing_data  = "notBreaching"
      }
    }
  }
  aws_sns_topic = {
    name                                     = "aws-cloudtrail-logs"
    name_prefix                              = null
    display_name                             = null
    delivery_policy                          = null
    application_success_feedback_role_arn    = null
    application_success_feedback_sample_rate = null
    application_failure_feedback_role_arn    = null
    http_success_feedback_role_arn           = null
    http_success_feedback_sample_rate        = null
    http_failure_feedback_role_arn           = null
    lambda_success_feedback_role_arn         = null
    lambda_success_feedback_sample_rate      = null
    lambda_failure_feedback_role_arn         = null
    sqs_success_feedback_role_arn            = null
    sqs_success_feedback_sample_rate         = null
    sqs_failure_feedback_role_arn            = null
  }
  aws_sns_topic_subscription = {
    protocol                        = "lambda"
    endpoint_auto_confirms          = false
    confirmation_timeout_in_minutes = null
    raw_message_delivery            = null
    filter_policy                   = null
    delivery_policy                 = null
    redrive_policy                  = null
  }
}

#--------------------------------------------------------------
# JIT Access
# Temporary privileged access system with Slack integration.
# Manages time-bound IAM Identity Center Permission Set assignments
# with approval workflow and automatic revocation.
#
# SETUP REQUIREMENTS:
# 1. Create a Slack App (see spec.md for detailed steps)
# 2. Configure Identity Center instance ARN and Identity Store ID
# 3. Define profiles with Permission Set ARNs and approvers
#
# SECURITY NOTES:
# - signing_secret and bot_token should be stored in a secure location
# - approvers list should be kept minimal (least privilege)
# - max_duration_minutes should be set to the minimum required time
#--------------------------------------------------------------
jit_access = {
  # TODO: Set to true when Slack App and Lambda zip are ready.
  is_enabled                  = true
  cleanup_schedule_expression = "rate(15 minutes)"
  #-----------------------------------------------------------------------------
  # profiles: Map of JIT access profiles. The key is the profile name shown
  # in the Slack modal dropdown.
  #
  # Fields:
  #   account_id (string):
  #     AWS account ID where the Permission Set will be assigned.
  #     How to get: AWS Console -> Organizations -> Accounts, or
  #       aws organizations list-accounts --query "Accounts[].{Name:Name,Id:Id}"
  #
  #   permission_set_arn (string):
  #     ARN of the IAM Identity Center Permission Set to assign.
  #     How to get: AWS Console -> IAM Identity Center -> Permission sets
  #       -> select the permission set -> copy the ARN, or
  #       aws sso-admin list-permission-sets \
  #         --instance-arn <identity-center-instance-arn> \
  #         --query "PermissionSets" --output text
  #
  #   max_duration_minutes (number):
  #     Maximum allowed access duration in minutes. The user can request
  #     up to this value in the Slack modal.
  #
  #   approvers (list of string):
  #     Slack User IDs of users who can approve requests for this profile.
  #     How to get: Open user profile in Slack -> "..." -> "Copy member ID"
  #
  #   description (string, optional):
  #     Human-readable description shown in the Slack modal.
  #-----------------------------------------------------------------------------
  profiles = {
    # Production-AWSAdministratorAccess = {
    #   account_id           = "123456789012"
    #   approvers            = ["UXXXXXXXXXX", "UXXXXXXXXXX"]
    #   description          = "production administrator access"
    #   max_duration_minutes = 240
    #   permission_set_arn   = "arn:aws:sso:::permissionSet/ssoins-xxxxxxxxxxxxxxx/ps-xxxxxxxxxxxxxxx"
    # }
    # Production-Developer = {
    #   account_id           = "123456789012"
    #   approvers            = ["UXXXXXXXXXX", "UXXXXXXXXXX"]
    #   description          = "production developer access"
    #   max_duration_minutes = 240
    #   permission_set_arn   = "arn:aws:sso:::permissionSet/ssoins-xxxxxxxxxxxxxxx/ps-xxxxxxxxxxxxxxx"
    # }
  }
  slack = {
    #---------------------------------------------------------------------------
    # approver_channel_id: Slack channel ID for posting approval notifications.
    #
    # How to get:
    #   1. Open the target channel in Slack
    #   2. Click the channel name -> open "Channel details"
    #   3. Copy the "Channel ID" at the bottom (e.g., C014NHZMLV9)
    #---------------------------------------------------------------------------
    approver_channel_id = "CXXXXXXXXXX"

    #---------------------------------------------------------------------------
    # bot_token: Slack Bot User OAuth Token
    #
    # How to get:
    #   1. Go to https://api.slack.com/apps
    #   2. Select your Slack App (or create one with "Create New App")
    #   3. Click "OAuth & Permissions" in the left menu
    #   4. Copy the "Bot User OAuth Token" value (starts with xoxb-)
    #
    # Required Bot Token Scopes (OAuth & Permissions -> Scopes -> Bot Token Scopes):
    #   - chat:write       (send messages)
    #   - commands         (slash commands)
    #   - users:read       (read user info)
    #   - users:read.email (read user email addresses)
    #---------------------------------------------------------------------------
    bot_token = "xoxb-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"

    #---------------------------------------------------------------------------
    # signing_secret: Slack App Signing Secret (for request verification)
    #
    # How to get:
    #   1. Go to https://api.slack.com/apps
    #   2. Select your Slack App
    #   3. Click "Basic Information" in the left menu
    #   4. Under "App Credentials", click "Show" next to "Signing Secret" and copy
    #---------------------------------------------------------------------------
    signing_secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # pragma: allowlist secret

    #---------------------------------------------------------------------------
    # user_mappings: Slack User ID -> Identity Center User ID mapping
    #
    # By default, users are resolved by matching their Slack email address to
    # the Identity Center UserName. Add manual mappings here only for users
    # whose Slack email does NOT match their Identity Center UserName.
    #
    # How to get Slack User ID:
    #   1. Open the user's profile in Slack
    #   2. Click "..." (More) -> "Copy member ID" (e.g., U014NHZMLV9)
    #
    # How to get Identity Center User ID:
    #   Option A (Console):
    #     1. AWS Console -> IAM Identity Center -> Users -> select the user
    #     2. Copy the "User ID" from the "General information" section
    #   Option B (CLI):
    #     aws identitystore list-users \
    #       --identity-store-id d-xxxxxxxx \
    #       --filters AttributePath=UserName,AttributeValue=<UserName> \
    #       --region ap-northeast-1 \
    #       --query "Users[0].UserId" --output text
    #---------------------------------------------------------------------------
    user_mappings = {
      # "UXXXXXXXXXX" = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    }

    #---------------------------------------------------------------------------
    # workflow_secret: Shared secret for Slack Workflow Builder webhook auth.
    #
    # Used to authenticate requests to the /workflow/request endpoint.
    # Set to null to disable (the endpoint will not be created).
    #---------------------------------------------------------------------------
    workflow_secret = null
  }
  timezone = "UTC"
}
