variable "tags" {
  type = map(any)
}
variable "name_prefix" {
  type = string
}
variable "region" {
  type = string
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
          security_cloudtrail = {
            retention_in_days = 90  # Override for security_cloudtrail service
          }
        }
      }
  EOT
  type = object({
    retention_in_days = number
    override = optional(object({
      security_cloudtrail = optional(object({
        retention_in_days = optional(number)
      }))
    }))
  })
}
variable "kms" {
  type = any
}
variable "oidc_github" {
  type = any
}
variable "security_notification" {
  type = any
}
variable "guardduty_organization" {
  type = any
}
variable "inspector2_organization" {
  type = any
}
variable "securityhub_organization" {
  type = any
}
