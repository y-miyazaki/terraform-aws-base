variable "control_tower" {
  description = <<-EOT
    Control Tower and organization-managed security services configuration.

    Use this object to describe whether Control Tower is enabled and which
    services are centrally managed outside this base stack.

    When managed_services.<service> is omitted, it falls back to is_enabled.
  EOT
  type = object({
    is_enabled = bool
    managed_services = optional(object({
      access_analyzer = optional(bool)
      cloudtrail      = optional(bool)
      config          = optional(bool)
      guardduty       = optional(bool)
      inspector2      = optional(bool)
      macie           = optional(bool)
      securityhub     = optional(bool)
    }))
  })
  default  = null
  nullable = true
}

variable "tags" {
  description = "(Required) Default tags applied to all resources created by this stack."
  type        = map(any)
}

variable "name_prefix" {
  description = "(Required) Prefix prepended to the names of resources created by this stack."
  type        = string
}

variable "region" {
  description = "Region configuration for multi-region deployment"
  type = object({
    global  = string
    primary = string
    targets = list(string)
  })
  validation {
    condition     = length(var.region.targets) > 0
    error_message = "region.targets must contain at least one region"
  }
  validation {
    condition     = contains(var.region.targets, var.region.primary)
    error_message = "region.primary must be included in region.targets"
  }
}

variable "cloudwatch_log_group" {
  description = <<-EOT
    Common CloudWatch Log Group configuration for all services.

    Priority order (higher priority overrides lower):
    1. var.cloudwatch_log_group.override.<service_name>.retention_in_days (highest priority)
    2. var.cloudwatch_log_group.retention_in_days (lowest priority - common default)

    Example:
      cloudwatch_log_group = {
        retention_in_days = 14  # Default for all services
        override = {
          budgets = {
            retention_in_days = 7  # Override for budgets service
          }
          security_cloudtrail = {
            retention_in_days = 90  # Override for security_cloudtrail service
          }
        }
      }
  EOT
  type = object({
    retention_in_days = number
    override = optional(object({
      budgets = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_vpc_flow_log = optional(object({
        retention_in_days = optional(number)
      }))
      guardduty = optional(object({
        retention_in_days = optional(number)
      }))
      health = optional(object({
        retention_in_days = optional(number)
      }))
      iam_password_expired = optional(object({
        retention_in_days = optional(number)
      }))
      security_cloudtrail = optional(object({
        retention_in_days = optional(number)
      }))
      security_config = optional(object({
        retention_in_days = optional(number)
      }))
      security_securityhub = optional(object({
        retention_in_days = optional(number)
      }))
      security_ssm_automation = optional(object({
        retention_in_days = optional(number)
      }))
      trusted_advisor = optional(object({
        retention_in_days = optional(number)
      }))
    }))
  })
}

variable "slack" {
  description = <<-EOT
    Common Slack configuration for all Lambda functions.

    Priority order (higher priority overrides lower):
    1. var.slack.override.<function_name> (highest priority)
    2. var.<function_name>.aws_lambda_function.environment.SLACK_* (middle priority)
    3. var.slack (lowest priority - common defaults)

    Example:
      slack = {
        oauth_access_token = "xoxb-common-token"
        channel_id         = "C-common-channel"
        override = {
          budgets = {
            channel_id = "C-budgets-specific-channel"  # Override only channel_id for budgets
          }
          guardduty = {
            oauth_access_token = "xoxb-guardduty-token"  # Override token for guardduty
            channel_id         = "C-guardduty-channel"   # Override channel for guardduty
          }
        }
      }
  EOT
  type = object({
    oauth_access_token = string
    channel_id         = string
    override = optional(object({
      budgets = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      guardduty = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      health = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      trusted_advisor = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      iam_password_expired = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      security_cloudtrail = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      security_config = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
    }))
  })
  #   sensitive = true
}

variable "kms" {
  description = "(Required) KMS key settings (deletion window and key rotation) used to encrypt data of supported services."
  type        = any
}

variable "oidc_github" {
  description = "(Required) GitHub Actions IAM OIDC identity provider and role settings. dangerously_attach_admin_policy should be false in production."
  type        = any
}

variable "resource_groups" {
  description = "(Required) AWS Resource Groups settings."
  type        = any
}

variable "budgets" {
  description = "(Required) AWS Budgets settings, including budget limits and cost alert notification."
  type        = any
}

variable "compute_optimizer" {
  description = "(Required) AWS AWS Compute Optimizer settings for resource right-sizing recommendations and notification."
  type        = any
}

variable "guardduty" {
  description = "(Required) GuardDuty finding notification settings (SNS, Lambda and Slack)."
  type        = any
}

variable "health" {
  description = "(Required) AWS Health event monitoring and Slack notification settings (regional and global events)."
  type        = any
}

variable "trusted_advisor" {
  description = "(Required) AWS Trusted Advisor check monitoring and notification settings."
  type        = any
}

variable "iam_password_expired" {
  description = "(Required) IAM password expiration check and notification settings."
  type        = any
}

variable "iam" {
  description = "(Required) IAM user, group and switch role settings."
  type        = any
}

variable "common_lambda" {
  description = "(Required) Common Lambda settings (for example VPC placement) shared by the Lambda functions in this stack."
  type        = any
}

variable "common_log" {
  description = "(Required) Common settings for log buckets and log delivery shared across services."
  type        = any
}
# security
variable "security_access_analyzer" {
  description = "(Required) IAM Access Analyzer settings."
  type        = any
}

variable "security_athena" {
  description = "(Required) Athena security settings (query result encryption for the primary workgroup)."
  type        = any
}

variable "security_cloudtrail" {
  description = "(Required) CloudTrail settings, including CloudWatch log metric filters, alarms and notification."
  type        = any
}

variable "security_config" {
  description = "(Required) AWS Config recorder, delivery channel and rule settings."
  type        = any
}

variable "security_default_vpc" {
  description = "(Required) Default VPC hardening settings (default VPC, subnets, security group and flow logs)."
  type        = any
}

variable "security_ebs" {
  description = "(Required) EBS account-level security defaults (encryption by default and public snapshot access blocking)."
  type        = any
}

variable "security_ec2_metadata" {
  description = "(Required) EC2 instance metadata defaults (IMDSv2 required for new instances)."
  type = object({
    is_enabled = bool
  })
}

variable "security_ecr" {
  description = "(Required) ECR account-level security defaults (enhanced scanning)."
  type = object({
    is_enabled = bool
  })
}

variable "security_guardduty" {
  description = "(Required) GuardDuty detector and member account settings."
  type        = any
}

variable "security_iam" {
  description = "(Required) IAM account security settings, including password policy and support role."
  type        = any
}

variable "security_inspector2" {
  description = "(Required) Amazon Inspector v2 settings."
  type        = any
}

variable "security_macie" {
  description = "(Required) Amazon Macie settings."
  type        = any
}

variable "security_s3" {
  description = "(Required) S3 account-level public access block settings."
  type        = any
}

variable "security_securityhub" {
  description = "(Required) Security Hub settings, including standards and finding aggregation."
  type        = any
}

variable "security_ssm_automation" {
  description = "(Required) Systems Manager Automation security settings (SSM.6 logging and SSM.7 public document sharing block)."
  type        = any
}
