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
  type = map(any)
}

variable "name_prefix" {
  type = string
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
  type = any
}

variable "oidc_github" {
  type = any
}

variable "resource_groups" {
  type = any
}

variable "budgets" {
  type = any
}

variable "compute_optimizer" {
  type = any
}

variable "guardduty" {
  type = any
}

variable "health" {
  type = any
}

variable "trusted_advisor" {
  type = any
}

variable "iam_password_expired" {
  type = any
}

variable "iam" {
  type = any
}

variable "common_lambda" {
  type = any
}

variable "common_log" {
  type = any
}
# security
variable "security_access_analyzer" {
  type = any
}

variable "security_athena" {
  type = any
}

variable "security_cloudtrail" {
  type = any
}

variable "security_config" {
  type = any
}

variable "security_default_vpc" {
  type = any
}

variable "security_ebs" {
  type = any
}

variable "security_ec2_metadata" {
  type = object({
    is_enabled = bool
  })
}

variable "security_ecr" {
  type = object({
    is_enabled = bool
  })
}

variable "security_guardduty" {
  type = any
}

variable "security_iam" {
  type = any
}

variable "security_inspector2" {
  type = any
}

variable "security_macie" {
  type = any
}

variable "security_s3" {
  type = any
}

variable "security_securityhub" {
  type = any
}

variable "security_ssm_automation" {
  type = any
}
