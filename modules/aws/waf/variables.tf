#--------------------------------------------------------------
# Module variables
#--------------------------------------------------------------
variable "name" {
  type        = string
  description = "(Required) Name of the WAFv2 Web ACL."
}

variable "description" {
  type        = string
  description = "(Optional) Description of the Web ACL."
  default     = null
}

variable "scope" {
  type        = string
  description = "(Required) Scope of the Web ACL. Valid values: CLOUDFRONT, REGIONAL."
  default     = "REGIONAL"

  validation {
    condition     = contains(["CLOUDFRONT", "REGIONAL"], var.scope)
    error_message = "scope must be CLOUDFRONT or REGIONAL."
  }
}

variable "default_action" {
  type        = string
  description = "(Optional) Default action for the Web ACL. Valid values: allow, block."
  default     = "allow"

  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "default_action must be allow or block."
  }
}

variable "rules" {
  type        = any
  description = "(Optional) List of WAF rule definitions. Supports managed_rule_group_statement, rate_based_statement, and custom statements."
  default     = []
}

variable "visibility_config" {
  type = object({
    cloudwatch_metrics_enabled = optional(bool, true)
    metric_name                = string
    sampled_requests_enabled   = optional(bool, true)
  })
  description = "(Required) Visibility config for the Web ACL."
}

variable "resource_arns" {
  type        = map(string)
  description = "(Optional) Map of resource ARNs to associate the Web ACL with. Key is a stable identifier, value is the ARN."
  default     = {}
}

variable "logging" {
  type = object({
    enabled             = optional(bool, false)
    log_group_name      = optional(string)
    retention_in_days   = optional(number, 14)
    kms_key_id          = optional(string)
    redacted_fields     = optional(list(any), [])
    logging_filter      = optional(any, {})
    log_destination_arn = optional(string)
  })
  description = "(Optional) Logging configuration. Set enabled=true to create CloudWatch Log Group and logging configuration."
  default     = {}
}

variable "custom_response_bodies" {
  type = list(object({
    content      = string
    content_type = string
    key          = string
  }))
  description = "(Optional) Custom response bodies for the Web ACL."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to assign to resources."
  default     = {}
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
