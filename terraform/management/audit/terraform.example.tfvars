#--------------------------------------------------------------
# Basically, it is already set so that the setting is completed only by changing tfvars.
# All parameters that need to be changed for each environment are described in TODO comments.
#
# ENVIRONMENT-SPECIFIC CONFIGURATION GUIDE:
# - Audit Environment: Security monitoring including Security Hub, GuardDuty, CloudTrail
#
# IMPORTANT: Always review and adjust these settings based on your organization's
# security requirements, compliance needs, and cost constraints.
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
# Default Region for Resources
# Specifies the primary AWS region where most resources will be deployed.
# Some services like CloudFront require resources in us-east-1 regardless of this setting.
# Common regions: ap-northeast-1 (Tokyo), us-east-1 (N. Virginia), eu-west-1 (Ireland)
#--------------------------------------------------------------
# TODO: need to change region.
region = "ap-northeast-1"

#--------------------------------------------------------------
# us-east-1 Region Resources
# Set is_enabled to false to skip creating all us-east-1 specific resources.
# When the default region is us-east-1, these resources are automatically skipped
# regardless of this setting to avoid duplication.
#--------------------------------------------------------------
us_east_1 = {
  is_enabled = true
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
    # security_cloudtrail = {
    #   retention_in_days = 90
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
  audit = {
    description             = "This key used for audit default."
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
# Security Notification
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
# NOTICE: GuardDuty is automatically disabled if control_tower.managed_services.guardduty = true.
#--------------------------------------------------------------
security_notification = {
  # TODO: need to set slack_channel_id for settings of AWS SecurityHub Notification(Slack).
  slack_channel_id = "C0XXXXXXXXX"
  # TODO: need to set slack_team_id for settings of AWS SecurityHub Notification(Slack).
  slack_team_id = "xxxxxxxxxxx"
  #--------------------------------------------------------------
  # GuardDuty
  # Amazon GuardDuty is a threat detection service that continuously monitors your AWS accounts and workloads for malicious activity and
  # delivers detailed security findings for visibility and remediation.
  # Notice: This option is automatically disabled if control_tower.managed_services.guardduty = true.
  # COST CONSIDERATION: ~$1.00 per GB of logs analyzed
  #--------------------------------------------------------------
  guardduty = {
    # TODO: need to set is_enabled for settings of AWS GuardDuty.
    is_enabled = false
  }
  #--------------------------------------------------------------
  # Security:SecurityHub
  # NOTE: Before using Chatbot functionality for Slack notifications, you must create a Slack client.
  # This involves setting up a Slack app and obtaining the necessary OAuth tokens and permissions.
  # For detailed setup instructions, refer to AWS Chatbot documentation:
  # https://docs.aws.amazon.com/chatbot/latest/adminguide/slack-setup.html
  #--------------------------------------------------------------
  securityhub = {
    # TODO: need to set is_enabled for settings of AWS SecurityHub.
    is_enabled = false
  }
}

#--------------------------------------------------------------
# Access Analyzer Organization
# AWS IAM Access Analyzer central configuration for organization-wide access analysis.
# Enables organization-wide settings for identifying resources shared with external entities.
#--------------------------------------------------------------
access_analyzer_organization = {
  # TODO: need to set is_enabled for settings of AWS Access Analyzer Organization.
  is_enabled    = false
  analyzer_name = "aws-access-analyzer"
}

#--------------------------------------------------------------
# Access Analyzer Organization (us-east-1)
# AWS IAM Access Analyzer central configuration for organization-wide access analysis in us-east-1.
#--------------------------------------------------------------
access_analyzer_organization_us_east_1 = {
  # TODO: need to set is_enabled for settings of AWS Access Analyzer Organization(us-east-1).
  is_enabled    = false
  analyzer_name = "aws-access-analyzer"
}

#--------------------------------------------------------------
# GuardDuty Organization
# AWS GuardDuty central configuration for organization-wide threat detection.
# Enables organization-wide settings for automated threat detection and response.
#--------------------------------------------------------------
guardduty_organization = {
  # TODO: need to set is_enabled for settings of AWS GuardDuty Organization.
  is_enabled = false
  # Set to true to create a new GuardDuty detector if no detector exists in this region.
  create_detector = false
  # TODO: need to set auto_enable_organization_members for settings of AWS GuardDuty Organization.
  auto_enable_organization_members = "ALL"
  features = {
    # https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorFeatureConfiguration.html
    EBS_MALWARE_PROTECTION = {
      auto_enable = "ALL"
    }
    EKS_AUDIT_LOGS = {
      auto_enable = "ALL"
    }
    LAMBDA_NETWORK_LOGS = {
      auto_enable = "ALL"
    }
    RDS_LOGIN_EVENTS = {
      auto_enable = "ALL"
    }
    RUNTIME_MONITORING = {
      auto_enable = "ALL"
      additional_configurations = [
        {
          name        = "ECS_FARGATE_AGENT_MANAGEMENT"
          auto_enable = "ALL"
        },
        {
          name        = "EC2_AGENT_MANAGEMENT"
          auto_enable = "ALL"
        },
        {
          name        = "EKS_ADDON_MANAGEMENT"
          auto_enable = "ALL"
        }
      ]
    }
    S3_DATA_EVENTS = {
      auto_enable = "ALL"
    }
  }
}

#--------------------------------------------------------------
# GuardDuty Organization (us-east-1)
# This configures the GuardDuty settings for the entire
# AWS Organization to use a central model in us-east-1.
#--------------------------------------------------------------
guardduty_organization_us_east_1 = {
  # TODO: need to set is_enabled for settings of AWS GuardDuty Organization(us-east-1).
  is_enabled = false
  # Set to true to create a new GuardDuty detector in us-east-1 (no existing detector from Control Tower).
  # Detector was created by Terraform since it did not exist in us-east-1.
  create_detector = true
  # TODO: need to set auto_enable_organization_members for settings of AWS GuardDuty Organization(us-east-1).
  auto_enable_organization_members = "ALL"
  features = {
    # https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorFeatureConfiguration.html
    EBS_MALWARE_PROTECTION = {
      auto_enable = "ALL"
    }
    EKS_AUDIT_LOGS = {
      auto_enable = "ALL"
    }
    LAMBDA_NETWORK_LOGS = {
      auto_enable = "ALL"
    }
    RDS_LOGIN_EVENTS = {
      auto_enable = "ALL"
    }
    RUNTIME_MONITORING = {
      auto_enable = "ALL"
      additional_configurations = [
        {
          name        = "ECS_FARGATE_AGENT_MANAGEMENT"
          auto_enable = "ALL"
        },
        {
          name        = "EC2_AGENT_MANAGEMENT"
          auto_enable = "ALL"
        },
        {
          name        = "EKS_ADDON_MANAGEMENT"
          auto_enable = "ALL"
        }
      ]
    }
    S3_DATA_EVENTS = {
      auto_enable = "ALL"
    }
  }
}

#--------------------------------------------------------------
# Inspector2 Organization
# AWS Inspector2 configurations for vulnerability management and security assessment.
# Enables organization-wide settings for automated security assessments.
#--------------------------------------------------------------
inspector2_organization = {
  # TODO: need to set is_enabled for settings of AWS Inspector2.
  is_enabled = false

  enabler = {
    default = {
      account_ids = [
        "123456789012",
        "123456789012"
      ]
      resource_types = [
        "EC2",
        "ECR",
        "LAMBDA",
        "LAMBDA_CODE",
        "CODE_REPOSITORY"
      ]
    }
    other = {
      account_ids = [
        "123456789012",
      ]
      resource_types = [
        "EC2",
        "ECR"
      ]
    }
  }
  # TODO: need to set is_enabled_configuration for settings of AWS Inspector2.
  is_enabled_configuration = false
  configuration = {
    auto_enable_ec2             = false
    auto_enable_ecr             = false
    auto_enable_lambda          = false
    auto_enable_lambda_code     = false
    auto_enable_code_repository = false
  }
}

#--------------------------------------------------------------
# Amazon Inspector2 Organization (us-east-1)
# AWS Inspector2 configurations for vulnerability management and security assessment in us-east-1.
#--------------------------------------------------------------
inspector2_organization_us_east_1 = {
  # TODO: need to set is_enabled for settings of AWS Inspector2(us-east-1).
  is_enabled = false

  enabler = {}
  # TODO: need to set is_enabled_configuration for settings of AWS Inspector2(us-east-1).
  is_enabled_configuration = false
  configuration = {
    auto_enable_ec2             = false
    auto_enable_ecr             = false
    auto_enable_lambda          = false
    auto_enable_lambda_code     = false
    auto_enable_code_repository = false
  }
}

#--------------------------------------------------------------
# Macie Organization
# Amazon Macie central configuration for organization-wide sensitive data discovery.
#--------------------------------------------------------------
macie_organization = {
  # TODO: need to set is_enabled for settings of AWS Macie Organization.
  is_enabled = false
  # TODO: need to set auto_enable for settings of AWS Macie Organization.
  auto_enable = true
  # TODO: need to set status for settings of AWS Macie account.
  status = "ENABLED"
  # TODO: need to set finding_publishing_frequency for settings of AWS Macie account.
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  classification_jobs          = []
  findings_filters             = []
}

#--------------------------------------------------------------
# Macie Organization (us-east-1)
# This configures the Macie settings for the entire
# AWS Organization to use a central model in us-east-1.
#--------------------------------------------------------------
macie_organization_us_east_1 = {
  # TODO: need to set is_enabled for settings of AWS Macie Organization(us-east-1).
  is_enabled = false
  # TODO: need to set auto_enable for settings of AWS Macie Organization(us-east-1).
  auto_enable = true
  # TODO: need to set status for settings of AWS Macie account(us-east-1).
  status = "ENABLED"
  # TODO: need to set finding_publishing_frequency for settings of AWS Macie account(us-east-1).
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  classification_jobs          = []
  findings_filters             = []
}

#--------------------------------------------------------------
# SecurityHub Organization
# AWS Security Hub central configuration for organization-wide settings.
#--------------------------------------------------------------
securityhub_organization = {
  # TODO: need to set is_enabled for settings of AWS SecurityHub Organization.
  is_enabled = false
  # TODO: need to set is_enabled_finding_aggregator for settings of Security Hub finding aggregator.
  is_enabled_finding_aggregator = false
  configuration_policy = {
    service_enabled = true
    name            = "securityhub-configuration-policy"
    # TODO: need to set enabled_standard_arns for settings of AWS SecurityHub Organization.
    # https://docs.aws.amazon.com/ja_jp/securityhub/latest/userguide/cis-aws-foundations-benchmark.html
    enabled_standard_arns = [
      "arn:aws:securityhub:{any region}::standards/aws-foundational-security-best-practices/v/1.0.0",
      "arn:aws:securityhub:{any region}::standards/cis-aws-foundations-benchmark/v/5.0.0"
    ]
    # TODO: need to set disabled_control_identifiers for settings of AWS SecurityHub Organization.
    # https://docs.aws.amazon.com/ja_jp/securityhub/latest/userguide/securityhub-controls-reference.html
    security_controls_configuration = {
      disabled_control_identifiers = [
        # "RDS.13",
        # "IAM.19", # for IAM 1.19 Access Analyzer already covers this control.
      ]
    }
  }
  configuration_policy_name = "securityhub-configuration-policy"
  linking_mode              = "ALL_REGIONS"
  target_id                 = "r-xxxxxx"
}

#--------------------------------------------------------------
# SecurityHub Organization (us-east-1)
# AWS Security Hub central configuration for organization-wide settings in us-east-1.
#--------------------------------------------------------------
securityhub_organization_us_east_1 = {
  # TODO: need to set is_enabled for settings of AWS SecurityHub Organization(us-east-1).
  is_enabled = false
  # TODO: need to set is_enabled_finding_aggregator for settings of Security Hub finding aggregator(us-east-1).
  is_enabled_finding_aggregator = false
  configuration_policy = {
    service_enabled = true
    name            = "securityhub-configuration-policy"
    # TODO: need to set enabled_standard_arns for settings of AWS SecurityHub Organization(us-east-1).
    # https://docs.aws.amazon.com/ja_jp/securityhub/latest/userguide/cis-aws-foundations-benchmark.html
    enabled_standard_arns = [
      "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0",
      "arn:aws:securityhub:us-east-1::standards/cis-aws-foundations-benchmark/v/5.0.0"
    ]
    # TODO: need to set disabled_control_identifiers for settings of AWS SecurityHub Organization(us-east-1).
    # https://docs.aws.amazon.com/ja_jp/securityhub/latest/userguide/securityhub-controls-reference.html
    security_controls_configuration = {
      disabled_control_identifiers = [
        # "RDS.13",
        # "IAM.19", # for IAM 1.19 Access Analyzer already covers this control.
      ]
    }
  }
  configuration_policy_name = "securityhub-configuration-policy"
  linking_mode              = "ALL_REGIONS"
  target_id                 = "r-xxxxxx"
}
