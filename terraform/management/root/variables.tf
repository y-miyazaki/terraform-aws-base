variable "tags" {
  type = map(any)
}
variable "name_prefix" {
  type = string
}
variable "region" {
  type = string
}
variable "us_east_1" {
  description = "Configuration for us-east-1 region resources. Set is_enabled to false to skip all us-east-1 resources."
  type = object({
    is_enabled = bool
  })
  default = {
    is_enabled = true
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
      security_cloudtrail = optional(object({
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
            channel_id = "C-budgets-specific-channel"
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
      security_cloudtrail = optional(object({
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
variable "budgets" {
  type = any
}
variable "common_lambda" {
  type = any
}
variable "organizations_policy" {
  type = any
}
variable "security_cloudtrail" {
  type = any
}
