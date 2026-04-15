#--------------------------------------------------------------
# Basically, it is already set so that the setting is completed only by changing tfvars.
# All parameters that need to be changed for each environment are described in TODO comments.
#
# ENVIRONMENT-SPECIFIC CONFIGURATION GUIDE:
# - Development: Set minimal security services, lower budgets, disable expensive features
# - Staging: Enable moderate security, moderate budgets, enable testing features
# - Production: Enable all security services, higher budgets, comprehensive monitoring
#
# IMPORTANT: Always review and adjust these settings based on your organization's
# security requirements, compliance needs, and cost constraints.
#--------------------------------------------------------------

#--------------------------------------------------------------
# Control Tower and organization-managed security services
# Use this object to define whether Control Tower is enabled and which
# services are centrally managed outside this base stack.
# If managed_services.<service> is omitted, it falls back to is_enabled.
#--------------------------------------------------------------
# TODO: need to change Control Tower settings.
control_tower = {
  is_enabled = false
  managed_services = {
    cloudtrail           = false
    config               = false
    guardduty            = false
    iam_password_expired = false
    securityhub          = false
  }
}
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
# Default Region for Resources
# Specifies the primary AWS region where most resources will be deployed.
# Some services like CloudFront require resources in us-east-1 regardless of this setting.
# Common regions: ap-northeast-1 (Tokyo), us-east-1 (N. Virginia), eu-west-1 (Ireland)
#--------------------------------------------------------------
# TODO: need to change region.
region = "ap-northeast-1"

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
    # guardduty = {
    #   retention_in_days = 30
    # }
    # health = {
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
    # security_securityhub = {
    #   retention_in_days = 30
    # }
    # security_ssm_automation = {
    #   retention_in_days = 14
    # }
    # trusted_advisor = {
    #   retention_in_days = 14
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

  # Optional: Override slack settings for specific Lambda functions
  # Uncomment and configure as needed
  override = {
    # budgets = {
    #   channel_id = "C0XXXXXXXXX"
    # }
    # guardduty = {
    #   channel_id = "C0XXXXXXXXX"
    # }
    # health = {
    #   channel_id = "C0XXXXXXXXX"
    # }
    # iam_password_expired = {
    #   channel_id = "C0XXXXXXXXX"
    # }
    # security_cloudtrail = {
    #   channel_id = "C0XXXXXXXXX"
    # }
    # security_config = {
    #   channel_id = "C0XXXXXXXXX"
    # }
    # trusted_advisor = {
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
  base = {
    description             = "This key used for base default."
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
  attach_read_only_policy = false
  # TODO: Flag to enable/disable the creation of the GitHub OIDC provider.
  create_oidc_provider = true
  # TODO: Set the org/repo of the GitHub repository to github_repositories.
  github_repositories = [
    # "your-repository/repository-name",
  ]
  iam_role_name = "oidc-github-role"
  iam_role_path = "/"
}

#--------------------------------------------------------------
# Resource Group
# AWS Resource Groups allow you to organize and manage AWS resources using tags.
# This creates a resource group that automatically includes all resources matching the specified tags.
# Useful for viewing all resources belonging to a specific environment or service in one place.
#--------------------------------------------------------------
resource_groups = {
  # TODO: need to change is_enabled for settings of resourcegroups_group.
  is_enabled = true
}

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
  aws_eventbridge_schedule = {
    name                = "budgets-eventbridge-scheduler"
    schedule_expression = "cron(0 9 * * ? *)"
    description         = "This eventbridge scheduler called budgets lambda function."
  }
  aws_lambda_function = {
    environment = {
      # TODO: need to change TIMEZONE.
      # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
      TIMEZONE = "Asia/Tokyo"
    }
  }
}

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
}

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
  aws_cloudwatch_event_rule = {
    name        = "guardduty-cloudwatch-event-rule"
    description = "This cloudwatch event used for GuardDuty."
    state       = "ENABLED"
  }
}

#--------------------------------------------------------------
# Health
# AWS Health provides personalized information about events that can affect your AWS infrastructure.
# This monitors AWS Health events and sends notifications to Slack when issues occur.
# Monitors both regional (ap-northeast-1) and global (us-east-1) health events.
#--------------------------------------------------------------
health = {
  # TODO: need to set is_enabled for settings of AWS Health.
  is_enabled = true
  aws_cloudwatch_event_rule = {
    name           = "health-cloudwatch-event-rule"
    name_us_east_1 = "health-us-east-1-cloudwatch-event-rule"
    description    = "This cloudwatch event used for Health."
    state          = "ENABLED"
  }
}

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
  aws_cloudwatch_event_rule = {
    name                = "trusted-advisor-cloudwatch-event-rule"
    schedule_expression = "cron(0 0 * * ? *)"
    description         = "This cloudwatch event used for Trusted Advisor."
    state               = "ENABLED"
  }
}

#--------------------------------------------------------------
# IAM password expired
# A list of target users will be automatically notified in Slack 10 days before the IAM password expires.
# Notice: This option is automatically disabled if control_tower.managed_services.iam_password_expired=true.
#--------------------------------------------------------------
iam_password_expired = {
  # TODO: need to set is_enabled for settings of IAM password expired.
  is_enabled = false
  aws_cloudwatch_event_rule = {
    name                = "iam-password-expired-cloudwatch-event-rule"
    schedule_expression = "cron(0 0 * * ? *)"
    description         = "This cloudwatch event used for IAM password expired."
    state               = "ENABLED"
  }
}

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
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
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
          },
          {
            sid    = "DenyConfigWrite"
            effect = "Deny"
            actions = [
              "config:DeleteDeliveryChannel",
              "config:DeleteOrganizationConfigRule",
              "config:DeleteConformancePack",
              "config:DeleteRetentionConfiguration",
              "config:StartConfigurationRecorder",
              "config:PutDeliveryChannel",
              "config:PutExternalEvaluation",
              "config:StartRemediationExecution",
              "config:DeleteAggregationAuthorization",
              "config:DeleteEvaluationResults",
              "config:DeleteStoredQuery",
              "config:DeleteConfigurationAggregator",
              "config:DeleteConfigRule",
              "config:PutConformancePack",
              "config:PutStoredQuery",
              "config:PutConfigurationRecorder",
              "config:PutConfigRule",
              "config:DeleteRemediationConfiguration",
              "config:PutEvaluations",
              "config:StopConfigurationRecorder",
              "config:PutAggregationAuthorization",
              "config:PutRemediationConfigurations",
              "config:DeleteRemediationExceptions",
              "config:StartConfigRulesEvaluation",
              "config:DeleteConfigurationRecorder",
              "config:DeleteResourceConfig",
              "config:PutResourceConfig",
              "config:DeleteOrganizationConformancePack",
              "config:PutOrganizationConformancePack",
              "config:PutConfigurationAggregator",
              "config:TagResource",
              "config:DeletePendingAggregationRequest",
              "config:PutRetentionConfiguration",
              "config:PutRemediationExceptions",
              "config:PutOrganizationConfigRule",
              "config:UntagResource",
            ]
            resources = [
              "*"
            ]
          },
          {
            sid    = "DenyS3Log"
            effect = "Deny"
            actions = [
              "s3:PutAnalyticsConfiguration",
              "s3:PutAccessPointConfigurationForObjectLambda",
              "s3:PutStorageLensConfiguration",
              "s3:DeleteAccessPoint",
              "s3:CreateBucket",
              "s3:DeleteAccessPointForObjectLambda",
              "s3:ReplicateObject",
              "s3:DeleteBucketWebsite",
              "s3:DeleteAccessPointPolicyForObjectLambda",
              "s3:DeleteJobTagging",
              "s3:PutLifecycleConfiguration",
              "s3:PutBucketAcl",
              "s3:PutObjectTagging",
              "s3:DeleteObject",
              "s3:CreateMultiRegionAccessPoint",
              "s3:DeleteObjectTagging",
              "s3:PutAccessPointPolicyForObjectLambda",
              "s3:PutAccountPublicAccessBlock",
              "s3:PutMultiRegionAccessPointPolicy",
              "s3:DeleteStorageLensConfigurationTagging",
              "s3:PutReplicationConfiguration",
              "s3:DeleteObjectVersionTagging",
              "s3:PutObjectLegalHold",
              "s3:InitiateReplication",
              "s3:PutBucketCORS",
              "s3:DeleteBucketPolicy",
              "s3:PutObject",
              "s3:PutBucketNotification",
              "s3:PutBucketLogging",
              "s3:PutObjectVersionAcl",
              "s3:PutAccessPointPublicAccessBlock",
              "s3:PutBucketObjectLockConfiguration",
              "s3:CreateJob",
              "s3:PutAccessPointPolicy",
              "s3:CreateAccessPoint",
              "s3:PutAccelerateConfiguration",
              "s3:DeleteObjectVersion",
              "s3:ReplicateTags",
              "s3:RestoreObject",
              "s3:PutEncryptionConfiguration",
              "s3:AbortMultipartUpload",
              "s3:PutBucketTagging",
              "s3:UpdateJobPriority",
              "s3:DeleteBucket",
              "s3:PutBucketVersioning",
              "s3:PutObjectAcl",
              "s3:PutBucketPublicAccessBlock",
              "s3:PutIntelligentTieringConfiguration",
              "s3:PutMetricsConfiguration",
              "s3:PutStorageLensConfigurationTagging",
              "s3:PutBucketOwnershipControls",
              "s3:PutObjectVersionTagging",
              "s3:DeleteMultiRegionAccessPoint",
              "s3:PutJobTagging",
              "s3:UpdateJobStatus",
              "s3:BypassGovernanceRetention",
              "s3:PutInventoryConfiguration",
              "s3:ObjectOwnerOverrideToBucketOwner",
              "s3:DeleteStorageLensConfiguration",
              "s3:PutBucketWebsite",
              "s3:PutBucketRequestPayment",
              "s3:PutObjectRetention",
              "s3:CreateAccessPointForObjectLambda",
              "s3:PutBucketPolicy",
              "s3:DeleteAccessPointPolicy",
              "s3:ReplicateDelete",
            ]
            resources = [
              "arn:aws:s3:::*-aws-log-*"
            ]
          },
          #--------------------------------------------------------------
          # Admin default rule end
          #--------------------------------------------------------------
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
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
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
          },
          {
            sid    = "AllowS3LogList"
            effect = "Allow"
            actions = [
              "s3:ListAllMyBuckets",
            ]
            resources = [
              "*",
            ]
          },
          {
            sid    = "AllowS3Log"
            effect = "Allow"
            actions = [
              "s3:Get*",
              "s3:List*",
              "s3:HeadBucket",
            ]
            resources = [
              "arn:aws:s3:::base-aws-log-common-*",
              "arn:aws:s3:::base-aws-log-common-*/*",
              "arn:aws:s3:::base-aws-log-application-*",
              "arn:aws:s3:::base-aws-log-application-*/*",
            ]
          },
          {
            sid    = "AllowAWSSecurityHubReadOnlyAccess"
            effect = "Allow"
            actions = [
              "securityhub:Get*",
              "securityhub:List*",
              "securityhub:Describe*",
            ]
            resources = [
              "*"
            ]
          },
          {
            sid    = "AllowAWSConfigUserAccess"
            effect = "Allow"
            actions = [
              "config:Get*",
              "config:Describe*",
              "config:Deliver*",
              "config:List*",
              "config:Select*",
              "tag:GetResources",
              "tag:GetTagKeys",
              "cloudtrail:DescribeTrails",
              "cloudtrail:GetTrailStatus",
              "cloudtrail:LookupEvents",
            ]
            resources = [
              "*"
            ]
          },
          {
            sid    = "AllowCloudWatchReadOnlyAccess"
            effect = "Allow"
            actions = [
              "autoscaling:Describe*",
              "cloudwatch:Describe*",
              "cloudwatch:Get*",
              "cloudwatch:List*",
              "logs:Get*",
              "logs:List*",
              "logs:StartQuery",
              "logs:StopQuery",
              "logs:Describe*",
              "logs:TestMetricFilter",
              "logs:FilterLogEvents",
              "sns:Get*",
              "sns:List*"
            ]
            resources = [
              "*"
            ]
          },
          #--------------------------------------------------------------
          # Default rule end
          #--------------------------------------------------------------
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
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
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
          },
          {
            sid    = "AllowS3LogList"
            effect = "Allow"
            actions = [
              "s3:ListAllMyBuckets",
            ]
            resources = [
              "*",
            ]
          },
          {
            sid    = "AllowS3Log"
            effect = "Allow"
            actions = [
              "s3:Get*",
              "s3:List*",
              "s3:HeadBucket",
            ]
            resources = [
              "arn:aws:s3:::base-aws-log-common-*",
              "arn:aws:s3:::base-aws-log-common-*/*",
              "arn:aws:s3:::base-aws-log-application-*",
              "arn:aws:s3:::base-aws-log-application-*/*",
            ]
          },
          {
            sid    = "AllowAWSSecurityHubReadOnlyAccess"
            effect = "Allow"
            actions = [
              "securityhub:Get*",
              "securityhub:List*",
              "securityhub:Describe*",
            ]
            resources = [
              "*"
            ]
          },
          {
            sid    = "AllowAWSConfigUserAccess"
            effect = "Allow"
            actions = [
              "config:Get*",
              "config:Describe*",
              "config:Deliver*",
              "config:List*",
              "config:Select*",
              "tag:GetResources",
              "tag:GetTagKeys",
              "cloudtrail:DescribeTrails",
              "cloudtrail:GetTrailStatus",
              "cloudtrail:LookupEvents",
            ]
            resources = [
              "*"
            ]
          },
          {
            sid    = "AllowCloudWatchReadOnlyAccess"
            effect = "Allow"
            actions = [
              "autoscaling:Describe*",
              "cloudwatch:Describe*",
              "cloudwatch:Get*",
              "cloudwatch:List*",
              "logs:Get*",
              "logs:List*",
              "logs:StartQuery",
              "logs:StopQuery",
              "logs:Describe*",
              "logs:TestMetricFilter",
              "logs:FilterLogEvents",
              "sns:Get*",
              "sns:List*"
            ]
            resources = [
              "*"
            ]
          },
          #--------------------------------------------------------------
          # Default rule end
          #--------------------------------------------------------------
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
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
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
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
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
          },
          {
            sid    = "AllowCloudFrontInvalidation"
            effect = "Allow"
            actions = [
              "cloudfront:GetDistribution",
              "cloudfront:GetDistributionConfig",
              "cloudfront:ListDistributions",
              "cloudfront:ListStreamingDistributions",
              "cloudfront:CreateInvalidation",
              "cloudfront:ListInvalidations",
              "cloudfront:GetInvalidation"
            ]
            resources = [
              "*",
            ]
          },
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
        # TODO: need to change IAM Group name.
        # An IAM policy for the SwitchRole will be attached to the group with the specified name.
        developer = {
          aws_iam_policy = {
            name        = "iam-switch-from-developer-policy"
            path        = "/"
            description = ""
            statement = [
              {
                sid    = "AllowSwitchFromAccountDeveloper"
                effect = "Allow"
                actions = [
                  "sts:AssumeRole",
                ]
                resources = [
                  # TODO: need to change AWS account ID(123456789012) and role name
                  # Specify the original AWS account ID(123456789012) that will use the IAM Switch role.
                  # Specify the AWS Account ID(123456789012) of the switch destination.
                  "arn:aws:iam::123456789012:role/base-iam-switch-to-developer-role",
                ]
              },
            ]
          }
        }
        # TODO: need to change IAM Group name.
        # An IAM policy for the SwitchRole will be attached to the group with the specified name.
        operator = {
          aws_iam_policy = {
            name        = "iam-switch-from-operator-policy"
            path        = "/"
            description = ""
            statement = [
              {
                sid    = "AllowSwitchFromAccountOperator"
                effect = "Allow"
                actions = [
                  "sts:AssumeRole",
                ]
                resources = [
                  # TODO: need to change AWS account ID(123456789012) and role name
                  # Specify the original AWS account ID(123456789012) that will use the IAM Switch role.
                  # Specify the AWS Account ID(123456789012) of the switch destination.
                  "arn:aws:iam::123456789012:role/base-iam-switch-to-operator-role",
                ]
              },
            ]
          }
        }
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
          # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
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
              },
              {
                sid    = "DenyConfigWrite"
                effect = "Deny"
                actions = [
                  "config:DeleteDeliveryChannel",
                  "config:DeleteOrganizationConfigRule",
                  "config:DeleteConformancePack",
                  "config:DeleteRetentionConfiguration",
                  "config:StartConfigurationRecorder",
                  "config:PutDeliveryChannel",
                  "config:PutExternalEvaluation",
                  "config:StartRemediationExecution",
                  "config:DeleteAggregationAuthorization",
                  "config:DeleteEvaluationResults",
                  "config:DeleteStoredQuery",
                  "config:DeleteConfigurationAggregator",
                  "config:DeleteConfigRule",
                  "config:PutConformancePack",
                  "config:PutStoredQuery",
                  "config:PutConfigurationRecorder",
                  "config:PutConfigRule",
                  "config:DeleteRemediationConfiguration",
                  "config:PutEvaluations",
                  "config:StopConfigurationRecorder",
                  "config:PutAggregationAuthorization",
                  "config:PutRemediationConfigurations",
                  "config:DeleteRemediationExceptions",
                  "config:StartConfigRulesEvaluation",
                  "config:DeleteConfigurationRecorder",
                  "config:DeleteResourceConfig",
                  "config:PutResourceConfig",
                  "config:DeleteOrganizationConformancePack",
                  "config:PutOrganizationConformancePack",
                  "config:PutConfigurationAggregator",
                  "config:TagResource",
                  "config:DeletePendingAggregationRequest",
                  "config:PutRetentionConfiguration",
                  "config:PutRemediationExceptions",
                  "config:PutOrganizationConfigRule",
                  "config:UntagResource",
                ]
                resources = [
                  "*"
                ]
              },
              {
                sid    = "DenyS3Log"
                effect = "Deny"
                actions = [
                  "s3:PutAnalyticsConfiguration",
                  "s3:PutAccessPointConfigurationForObjectLambda",
                  "s3:PutStorageLensConfiguration",
                  "s3:DeleteAccessPoint",
                  "s3:CreateBucket",
                  "s3:DeleteAccessPointForObjectLambda",
                  "s3:ReplicateObject",
                  "s3:DeleteBucketWebsite",
                  "s3:DeleteAccessPointPolicyForObjectLambda",
                  "s3:DeleteJobTagging",
                  "s3:PutLifecycleConfiguration",
                  "s3:PutBucketAcl",
                  "s3:PutObjectTagging",
                  "s3:DeleteObject",
                  "s3:CreateMultiRegionAccessPoint",
                  "s3:DeleteObjectTagging",
                  "s3:PutAccessPointPolicyForObjectLambda",
                  "s3:PutAccountPublicAccessBlock",
                  "s3:PutMultiRegionAccessPointPolicy",
                  "s3:DeleteStorageLensConfigurationTagging",
                  "s3:PutReplicationConfiguration",
                  "s3:DeleteObjectVersionTagging",
                  "s3:PutObjectLegalHold",
                  "s3:InitiateReplication",
                  "s3:PutBucketCORS",
                  "s3:DeleteBucketPolicy",
                  "s3:PutObject",
                  "s3:PutBucketNotification",
                  "s3:PutBucketLogging",
                  "s3:PutObjectVersionAcl",
                  "s3:PutAccessPointPublicAccessBlock",
                  "s3:PutBucketObjectLockConfiguration",
                  "s3:CreateJob",
                  "s3:PutAccessPointPolicy",
                  "s3:CreateAccessPoint",
                  "s3:PutAccelerateConfiguration",
                  "s3:DeleteObjectVersion",
                  "s3:ReplicateTags",
                  "s3:RestoreObject",
                  "s3:PutEncryptionConfiguration",
                  "s3:AbortMultipartUpload",
                  "s3:PutBucketTagging",
                  "s3:UpdateJobPriority",
                  "s3:DeleteBucket",
                  "s3:PutBucketVersioning",
                  "s3:PutObjectAcl",
                  "s3:PutBucketPublicAccessBlock",
                  "s3:PutIntelligentTieringConfiguration",
                  "s3:PutMetricsConfiguration",
                  "s3:PutStorageLensConfigurationTagging",
                  "s3:PutBucketOwnershipControls",
                  "s3:PutObjectVersionTagging",
                  "s3:DeleteMultiRegionAccessPoint",
                  "s3:PutJobTagging",
                  "s3:UpdateJobStatus",
                  "s3:BypassGovernanceRetention",
                  "s3:PutInventoryConfiguration",
                  "s3:ObjectOwnerOverrideToBucketOwner",
                  "s3:DeleteStorageLensConfiguration",
                  "s3:PutBucketWebsite",
                  "s3:PutBucketRequestPayment",
                  "s3:PutObjectRetention",
                  "s3:CreateAccessPointForObjectLambda",
                  "s3:PutBucketPolicy",
                  "s3:DeleteAccessPointPolicy",
                  "s3:ReplicateDelete",
                ]
                resources = [
                  "arn:aws:s3:::*-aws-log-*"
                ]
              },
              #--------------------------------------------------------------
              # Admin default rule end
              #--------------------------------------------------------------
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
        # TODO: need to change IAM switch role name.
        # Part of this name will be used as the switch role name.
        developer = {
          # TODO: need to change IAM switch role.
          aws_iam_role = {
            name        = "iam-switch-to-developer-role"
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
          # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
          aws_iam_policy = {
            name        = "iam-switch-to-developer-policy"
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
              },
              {
                sid    = "AllowS3LogList"
                effect = "Allow"
                actions = [
                  "s3:ListAllMyBuckets",
                ]
                resources = [
                  "*",
                ]
              },
              {
                sid    = "AllowS3Log"
                effect = "Allow"
                actions = [
                  "s3:Get*",
                  "s3:List*",
                  "s3:HeadBucket",
                ]
                resources = [
                  "arn:aws:s3:::base-aws-log-common-*",
                  "arn:aws:s3:::base-aws-log-common-*/*",
                  "arn:aws:s3:::base-aws-log-application-*",
                  "arn:aws:s3:::base-aws-log-application-*/*",
                ]
              },
              {
                sid    = "AllowAWSSecurityHubReadOnlyAccess"
                effect = "Allow"
                actions = [
                  "securityhub:Get*",
                  "securityhub:List*",
                  "securityhub:Describe*",
                ]
                resources = [
                  "*"
                ]
              },
              {
                sid    = "AllowAWSConfigUserAccess"
                effect = "Allow"
                actions = [
                  "config:Get*",
                  "config:Describe*",
                  "config:Deliver*",
                  "config:List*",
                  "config:Select*",
                  "tag:GetResources",
                  "tag:GetTagKeys",
                  "cloudtrail:DescribeTrails",
                  "cloudtrail:GetTrailStatus",
                  "cloudtrail:LookupEvents",
                ]
                resources = [
                  "*"
                ]
              },
              {
                sid    = "AllowCloudWatchReadOnlyAccess"
                effect = "Allow"
                actions = [
                  "autoscaling:Describe*",
                  "cloudwatch:Describe*",
                  "cloudwatch:Get*",
                  "cloudwatch:List*",
                  "logs:Get*",
                  "logs:List*",
                  "logs:StartQuery",
                  "logs:StopQuery",
                  "logs:Describe*",
                  "logs:TestMetricFilter",
                  "logs:FilterLogEvents",
                  "sns:Get*",
                  "sns:List*"
                ]
                resources = [
                  "*"
                ]
              },
              #--------------------------------------------------------------
              # Default rule end
              #--------------------------------------------------------------
            ]
          }
          # TODO: need to add policy arn. group policy limit is 10.
          # You need to check this document.
          # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
          policy = [
            {
              policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
            },
          ]
        }
        # TODO: need to change IAM switch role name.
        # Part of this name will be used as the switch role name.
        operator = {
          # TODO: need to change IAM switch role.
          aws_iam_role = {
            name        = "iam-switch-to-operator-role"
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
          # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
          aws_iam_policy = {
            name        = "iam-switch-to-operator-policy"
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
              },
              {
                sid    = "AllowS3LogList"
                effect = "Allow"
                actions = [
                  "s3:ListAllMyBuckets",
                ]
                resources = [
                  "*",
                ]
              },
              {
                sid    = "AllowS3Log"
                effect = "Allow"
                actions = [
                  "s3:Get*",
                  "s3:List*",
                  "s3:HeadBucket",
                ]
                resources = [
                  "arn:aws:s3:::base-aws-log-common-*",
                  "arn:aws:s3:::base-aws-log-common-*/*",
                  "arn:aws:s3:::base-aws-log-application-*",
                  "arn:aws:s3:::base-aws-log-application-*/*",
                ]
              },
              {
                sid    = "AllowAWSSecurityHubReadOnlyAccess"
                effect = "Allow"
                actions = [
                  "securityhub:Get*",
                  "securityhub:List*",
                  "securityhub:Describe*",
                ]
                resources = [
                  "*"
                ]
              },
              {
                sid    = "AllowAWSConfigUserAccess"
                effect = "Allow"
                actions = [
                  "config:Get*",
                  "config:Describe*",
                  "config:Deliver*",
                  "config:List*",
                  "config:Select*",
                  "tag:GetResources",
                  "tag:GetTagKeys",
                  "cloudtrail:DescribeTrails",
                  "cloudtrail:GetTrailStatus",
                  "cloudtrail:LookupEvents",
                ]
                resources = [
                  "*"
                ]
              },
              {
                sid    = "AllowCloudWatchReadOnlyAccess"
                effect = "Allow"
                actions = [
                  "autoscaling:Describe*",
                  "cloudwatch:Describe*",
                  "cloudwatch:Get*",
                  "cloudwatch:List*",
                  "logs:Get*",
                  "logs:List*",
                  "logs:StartQuery",
                  "logs:StopQuery",
                  "logs:Describe*",
                  "logs:TestMetricFilter",
                  "logs:FilterLogEvents",
                  "sns:Get*",
                  "sns:List*"
                ]
                resources = [
                  "*"
                ]
              },
              #--------------------------------------------------------------
              # Default rule end
              #--------------------------------------------------------------
            ]
          }
          # TODO: need to add policy arn. group policy limit is 10.
          # You need to check this document.
          # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
          policy = []
        }
      }
    }
  }
}

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
      enable_flow_log                      = true
      create_flow_log_cloudwatch_log_group = true
      create_flow_log_cloudwatch_iam_role  = true
      flow_log_file_format                 = "plain-text"
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

#--------------------------------------------------------------
# Common:Log Bucket
# S3 buckets for centralized log storage and management.
# Includes buckets for ELB logs, CloudTrail logs, and other AWS service logs.
# Configured with lifecycle policies, encryption, and versioning for compliance.
#--------------------------------------------------------------
common_log = {
  # TODO: need to set elb_account_id for ELB access log.
  # Please specify the account ID for the target region of ELB. Refer to the following URL for the account ID.
  # https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/classic/enable-access-logs.html
  # elb account id is ap-northeast-1.
  elb_account_id = "582318560864"
  #--------------------------------------------------------------
  # S3 for log
  # https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
  #--------------------------------------------------------------
  s3_log = {
    bucket               = "aws-log-common"
    create_bucket        = true
    attach_public_policy = true
    block_public_acls    = true
    block_public_policy  = true
    force_destroy        = true
    ignore_public_acls   = true
    lifecycle_rule = [
      {
        id                                     = "default"
        abort_incomplete_multipart_upload_days = 7
        enabled                                = true
        prefix                                 = null
        expiration = [
          {
            # TODO: need to change days. default 3years.
            # Adjust retention period based on your compliance requirements
            days                         = 1095
            expired_object_delete_marker = null
          }
        ]
        transition = [
          {
            days          = 30
            storage_class = "ONEZONE_IA"
          }
        ]
        noncurrent_version_expiration = [
          {
            days = 30
          }
        ]
      }
    ]
    restrict_public_buckets = true
    server_side_encryption_configuration = {
      rule = {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "AES256"
          kms_master_key_id = null
        }
      }
    }
    versioning = {
      enabled = true
    }
  }

  #--------------------------------------------------------------
  # S3 for CloudTrail
  # https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
  # Notice: This option is automatically disabled if control_tower.managed_services.cloudtrail=true.
  #--------------------------------------------------------------
  s3_cloudtrail = {
    bucket = "aws-log-cloudtrail"
    # TODO: need to change create_bucket for cloudtrail
    create_bucket        = false
    attach_public_policy = true
    block_public_acls    = true
    block_public_policy  = true
    force_destroy        = true
    ignore_public_acls   = true
    lifecycle_rule = [
      {
        id                                     = "default"
        abort_incomplete_multipart_upload_days = 7
        enabled                                = true
        prefix                                 = null
        expiration = [
          {
            # TODO: need to change days. default 3years.
            # Adjust retention period based on your compliance requirements
            days                         = 1095
            expired_object_delete_marker = null
          }
        ]
        transition = [
          {
            days          = 30
            storage_class = "ONEZONE_IA"
          }
        ]
        noncurrent_version_expiration = [
          {
            days = 30
          }
        ]
      }
    ]
    restrict_public_buckets = true
    server_side_encryption_configuration = {
      rule = {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "AES256"
          kms_master_key_id = null
        }
      }
    }
    versioning = {
      enabled = true
    }
  }
}

#--------------------------------------------------------------
# Security:Access Analyzer
# AWS IAM Access Analyzer helps identify resources in your organization and accounts that are shared with external entities.
# Analyzes resource-based policies and generates findings for resources with public or cross-account access.
# Helps ensure that only intended access to resources is allowed.
#--------------------------------------------------------------
security_access_analyzer = {
  # TODO: need to set is_enabled for settings of Access Analyzer.
  is_enabled = true
  aws_accessanalyzer_analyzer = {
    analyzer_name = "aws-access-analyzer"
    type          = "ACCOUNT"
  }
}

#--------------------------------------------------------------
# Security:Athena
# AWS Athena security configuration for query results encryption.
# Changes the EncryptionConfiguration setting of Athena's Workgroup(primary) to SSE_S3.
# Ensures that all query results are encrypted at rest using S3 server-side encryption.
#--------------------------------------------------------------
security_athena = {
  # TODO: need to set is_enabled for settings of Athena.
  is_enabled = true
}

#--------------------------------------------------------------
# Security:CloudTrail
# Notice: This option is automatically disabled if control_tower.managed_services.cloudtrail=true.
#--------------------------------------------------------------
security_cloudtrail = {
  # TODO: need to set is_enabled for settings of CloudTrail.
  is_enabled = false
  # TODO: need to set is_s3_enabled for settings of New S3 Bucket.
  is_s3_enabled = false
  aws_iam_role = {
    description = ""
    name        = "security-cloudtrail-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = ""
    name        = "security-cloudtrail-policy"
    path        = "/"
  }
  aws_cloudwatch_log_metric_filter = [
    {
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
    },
  ]
  aws_cloudwatch_metric_alarm = [
    {
      alarm_name          = "cloudtrail-logs-terminate"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 1
      period              = 300
      statistic           = "Sum"
      threshold           = 1
      threshold_metric_id = null
      actions_enabled     = true
      alarm_description   = "Alert Security Notification"
      datapoints_to_alarm = 1
      dimensions          = null
      treat_missing_data  = "notBreaching"
    },
  ]
  #   aws_s3_bucket = {
  #     bucket        = "aws-cloudtrail"
  #     force_destroy = true
  #     versioning = [
  #       {
  #         enabled = true
  #       }
  #     ]
  #     #    logging               = []
  #     lifecycle_rule = [
  #       {
  #         id                                     = "default"
  #         abort_incomplete_multipart_upload_days = 7
  #         enabled                                = true
  #         prefix                                 = null
  #         expiration = [
  #           {
  #             # TODO: need to change days. default 3years.
  #             # Adjust retention period based on your compliance requirements
  #             days                         = 1095
  #             expired_object_delete_marker = null
  #           }
  #         ]
  #         transition = [
  #           {
  #             days          = 30
  #             storage_class = "ONEZONE_IA"
  #           }
  #         ]
  #         noncurrent_version_expiration = [
  #           {
  #             days = 30
  #           }
  #         ]
  #       }
  #     ]
  #     replication_configuration = []
  #     server_side_encryption_configuration = [
  #       {
  #         rule = [
  #           {
  #             apply_server_side_encryption_by_default = [
  #               {
  #                 sse_algorithm     = "AES256"
  #                 kms_master_key_id = null
  #               }
  #             ]
  #           }
  #         ]
  #       }
  #     ]
  #     object_lock_configuration = []
  #   }
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
  aws_cloudtrail = {
    name                          = "cloudtrail"
    enable_logging                = true
    include_global_service_events = true
    is_multi_region_trail         = true
    is_organization_trail         = false
    enable_log_file_validation    = true
    event_selector = [
      {
        read_write_type           = "All"
        include_management_events = true
        data_resource = [
          {
            type   = "AWS::S3::Object"
            values = ["arn:aws:s3:::"]
          }
        ]
      }
    ]
    insight_selector = [
      {
        insight_type = "ApiCallRateInsight"
      }
    ]
  }
}

#--------------------------------------------------------------
# Security:AWS Config
# Notice: This option is automatically disabled if control_tower.managed_services.config=true.
#--------------------------------------------------------------
security_config = {
  # TODO: need to set is_enabled for settings of AWS Config.
  is_enabled = false
  # TODO: need to set is_s3_enabled for settings of New S3 Bucket.
  is_s3_enabled = false
  aws_config_configuration_recorder = {
    name = "aws-config-configuration-recorder"
    recording_group = [
      {
        all_supported                 = true
        include_global_resource_types = true
      }
    ]
  }
  aws_iam_role = {
    description = "IAM role for AWS Config."
    name        = "security-config-role"
    path        = "/"
  }
  #   aws_s3_bucket = {
  #     # Random suffix is automatically added to the bucket name.
  #     bucket        = "aws-config"
  #     force_destroy = true
  #     versioning = [
  #       {
  #         enabled = true
  #       }
  #     ]
  #     logging = []
  #     lifecycle_rule = [
  #       {
  #         id                                     = "default"
  #         abort_incomplete_multipart_upload_days = 7
  #         enabled                                = true
  #         prefix                                 = null
  #         expiration = [
  #           {
  #             # TODO: need to change days. default 3years.
  #             # Adjust retention period based on your compliance requirements
  #             days                         = 1095
  #             expired_object_delete_marker = null
  #           }
  #         ]
  #         transition = [
  #           {
  #             days          = 30
  #             storage_class = "ONEZONE_IA"
  #           }
  #         ]
  #         noncurrent_version_expiration = [
  #           {
  #             days = 30
  #           }
  #         ]
  #       }
  #     ]
  #     replication_configuration = []
  #     server_side_encryption_configuration = [
  #       {
  #         rule = [
  #           {
  #             apply_server_side_encryption_by_default = [
  #               {
  #                 sse_algorithm     = "AES256"
  #                 kms_master_key_id = null
  #               }
  #             ]
  #           }
  #         ]
  #       }
  #     ]
  #     object_lock_configuration = []
  #   }
  aws_config_delivery_channel = {
    name          = "aws-config-delivery-channel"
    sns_topic_arn = null
    snapshot_delivery_properties = [
      {
        delivery_frequency = "Three_Hours"
      }
    ]
  }
  aws_config_configuration_recorder_status = {
    is_enabled = true
  }
  aws_cloudwatch_event_rule = {
    name        = "security-config-cloudwatch-event-rule"
    description = "This cloudwatch event used for Config."
  }
  # SSM Automation configuration
  ssm_automation = {
    aws_iam_role = {
      description = ""
      name        = "security-config-ssm-automation-role"
      path        = "/"
    }
    aws_iam_policy = {
      description = ""
      name        = "security-config-ssm-automation-policy"
      path        = "/"
    }
  }
  # TODO: If you want to automatically remediation resources, please modify the following.
  # AWS Config allows you to remediate noncompliant resources that are evaluated by AWS Config Rules. AWS Config applies remediation using AWS Systems Manager Automation documents.
  # https://docs.aws.amazon.com/config/latest/developerguide/remediation.html
  remediation = {
    ec2 = {
      # TODO: If true, it will disable the default SSH and RDP ports that are open for all IP addresses.
      is_disable_public_access_for_security_group = true
    }
    s3 = {
      # TODO: If true, configures the Amazon Simple Storage Service (Amazon S3) public access block settings for an Amazon S3 bucket based on the values you specify.
      is_configure_s3_bucket_public_access_block = true
      configure_s3_bucket_public_access_block = {
        # TODO: If set to True, Amazon S3 blocks public access control lists (ACLs) for the S3 bucket, and objects stored in the S3 bucket you specify in the BucketName parameter.
        block_public_acls = true
        # TODO: If set to True, Amazon S3 blocks public bucket policies for the S3 bucket you specify in the BucketName parameter.
        block_public_policy = true
        # TODO: If set to True, Amazon S3 ignores all public ACLs for the S3 bucket you specify in the BucketName parameter.
        ignore_public_acls = true
        # TODO: If set to True, Amazon S3 restricts public bucket policies for the S3 bucket you specify in the BucketName parameter.
        restrict_public_buckets = true
      }
      # TODO: If true, public read/write of the S3 bucket will be disabled.
      is_disable_s3_bucket_public_read_write = true
      # TODO: If true, Enable encryption for an Amazon Simple Storage Service (Amazon S3) bucket (encrypt the contents of the bucket).
      is_enabled_s3_bucket_encryption            = true
      enabled_s3_bucket_encryption_sse_algorithm = "AES256"
      # TODO: If true, bucket policy statement that explicitly denies HTTP requests to the Amazon S3 bucket you specify.
      is_restrict_bucket_ssl_requests_only = false
      # TODO: If true, it will enable S3 bucket versioning.
      is_configure_s3_bucket_versioning = true
    }
  }
}

#--------------------------------------------------------------
# Security:AWS Config(us-east-1(CloudFront))
# Notice: This option is automatically disabled if control_tower.managed_services.config=true.
#--------------------------------------------------------------
security_config_us_east_1 = {
  # TODO: need to set is_enabled for settings of AWS Config.
  is_enabled = false
  # TODO: need to set is_s3_enabled for settings of New S3 Bucket.
  is_s3_enabled = false
  aws_config_configuration_recorder = {
    name = "aws-config-us-east-1-configuration-recorder"
    recording_group = [
      {
        all_supported                 = true
        include_global_resource_types = true
      }
    ]
  }
  aws_iam_role = {
    description = "IAM role for AWS Config."
    name        = "security-config-us-east-1-role"
    path        = "/"
  }
  #   aws_s3_bucket = {
  #     # Random suffix is automatically added to the bucket name.
  #     bucket        = "aws-config"
  #     force_destroy = true
  #     versioning = [
  #       {
  #         enabled = true
  #       }
  #     ]
  #     logging = []
  #     lifecycle_rule = [
  #       {
  #         id                                     = "default"
  #         abort_incomplete_multipart_upload_days = 7
  #         enabled                                = true
  #         prefix                                 = null
  #         expiration = [
  #           {
  #             # TODO: need to change days. default 3years.
  #             # Adjust retention period based on your compliance requirements
  #             days                         = 1095
  #             expired_object_delete_marker = null
  #           }
  #         ]
  #         transition = [
  #           {
  #             days          = 30
  #             storage_class = "ONEZONE_IA"
  #           }
  #         ]
  #         noncurrent_version_expiration = [
  #           {
  #             days = 30
  #           }
  #         ]
  #       }
  #     ]
  #     replication_configuration = []
  #     server_side_encryption_configuration = [
  #       {
  #         rule = [
  #           {
  #             apply_server_side_encryption_by_default = [
  #               {
  #                 sse_algorithm     = "AES256"
  #                 kms_master_key_id = null
  #               }
  #             ]
  #           }
  #         ]
  #       }
  #     ]
  #     object_lock_configuration = []
  #   }
  aws_config_delivery_channel = {
    name          = "aws-config-us-east-1-delivery-channel"
    sns_topic_arn = null
    snapshot_delivery_properties = [
      {
        delivery_frequency = "Three_Hours"
      }
    ]
  }
  aws_config_configuration_recorder_status = {
    is_enabled = true
  }
  aws_cloudwatch_event_rule = {
    name        = "security-config-us-east-1-cloudwatch-event-rule"
    description = "This cloudwatch event used for Config."
  }
  # TODO: If you want to automatically remediation resources, please modify the following.
  # AWS Config allows you to remediate noncompliant resources that are evaluated by AWS Config Rules. AWS Config applies remediation using AWS Systems Manager Automation documents.
  # https://docs.aws.amazon.com/config/latest/developerguide/remediation.html
  remediation = {
    cloudfront = {
      # TODO: If true, it will change the viewer protocol policy to redirect-to-https.
      is_enable_cloudfront_viewer_policy_https = true
    }
  }
}

#--------------------------------------------------------------
# Security:Default VPC
# Security configuration for the default VPC in each region.
# Enables VPC Flow Logs for network traffic monitoring and analysis.
# Optionally creates VPC Endpoints to resolve Security Hub EC2.10 finding (costs ~$10/month per VPC).
#--------------------------------------------------------------
security_default_vpc = {
  # TODO: need to set is_enabled for settings of default VPC security.
  is_enabled           = true
  is_enabled_flow_logs = true
  # A boolean flag to enable/disable VPC Endpoint for [EC2.10]. Defaults true."
  # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#ec2-10-remediation
  # If true, the EC2-10 indication will be resolved.
  # If false, Security Hub will point out Severity: Medium on EC2-10.
  # This flag will set the VPC Endpoint for the default VPC in each region.
  # Normally, it costs more than 10 USD a month for the default VPC that you do not use, so the initial value is set to false.
  is_enabled_vpc_end_point = false
  aws_iam_role = {
    description = ""
    name        = "security-vpc-flow-log-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = ""
    name        = "security-vpc-flow-log-policy"
    path        = "/"
  }
}

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

#--------------------------------------------------------------
# Security:GuardDuty
# Amazon GuardDuty provides intelligent threat detection for your AWS environment.
# Continuously monitors for malicious activity and unauthorized behavior using machine learning.
# Detects reconnaissance, instance compromise, account compromise, and bucket compromise.
# Notice: This option is automatically disabled if control_tower.managed_services.guardduty=true.
#--------------------------------------------------------------
security_guardduty = {
  # TODO: need to set is_enabled for settings of GuardDuty. Even if GuardDuty is already set, it must be set to false.
  is_enabled = false
  aws_guardduty_detector = {
    # TODO: need to set enabled for settings of GuardDuty Detector.
    enable                       = false
    finding_publishing_frequency = "FIFTEEN_MINUTES"
  }
  aws_guardduty_member = [
  ]
}

#--------------------------------------------------------------
# Security:IAM
# IAM security settings including password policy and support role configuration.
# Configures account-wide password requirements (length, complexity, expiration, reuse prevention).
# Creates IAM role for AWS Support access as required by CIS benchmark 1.20.
#--------------------------------------------------------------
security_iam = {
  # TODO: need to set is_enabled for settings of IAM security.
  is_enabled = true
  aws_iam_account_password_policy = {
    allow_users_to_change_password = true
    hard_expiry                    = true
    max_password_age               = 90
    minimum_password_length        = 14
    password_reuse_prevention      = 24
    require_lowercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    require_uppercase_characters   = true
  }
  # TODO: need to set principal role arn for Support IAM Role.
  # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.20-remediation
  support_iam_role_principal_arns = [
    # example)
    # "arn:aws:iam::{account id}:{iam user}"
    "arn:aws:iam::123456789012:root"
  ]
  aws_iam_role = {
    description = ""
    name        = "security-support-role"
    path        = "/"
  }
}

#--------------------------------------------------------------
# Security:S3
# S3 account-level public access block configuration.
# Prevents accidental public exposure of S3 buckets and objects across the entire AWS account.
# These settings apply to all buckets in the account unless explicitly overridden.
#--------------------------------------------------------------
security_s3 = {
  # TODO: need to set is_enabled for settings of S3 security.
  is_enabled = true

  # Manages S3 account-level Public Access Block configuration. For more information about these settings, see the AWS S3 Block Public Access documentation.
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

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
  aws_securityhub_member = {
  }
  # TODO: need to change product_subscription.
  aws_securityhub_product_subscription = {
  }
  aws_securityhub_action_target = {
    name        = "Send notification"
    identifier  = "SendToEvent"
    description = "This is custom action sends selected findings to event"
  }
}

#--------------------------------------------------------------
# Security:SSM Automation
# SSM.6 and SSM.7 compliance settings for AWS Systems Manager Automation.
# Enables CloudWatch logging for SSM Automation to meet SSM.6 control requirements.
# Disables public sharing of SSM Automation documents to comply with SSM.7 control.
#--------------------------------------------------------------
security_ssm_automation = {
  # TODO: need to set is_enabled for settings of SSM Automation.
  is_enabled                = true
  cloudwatch_log_group_name = "/aws/ssm/automation/executeScript"
}
