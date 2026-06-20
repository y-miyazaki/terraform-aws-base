#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "region" {
  type        = string
  description = "(Optional) AWS region for SSM Service Settings. Uses current region if not specified."
  default     = null
}

variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of SSM Automation. Defaults true."
  default     = true
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "(Optional) Name of the CloudWatch Log Group for SSM Automation. Defaults to '/aws/ssm/automation/executeScript'."
  default     = "/aws/ssm/automation/executeScript"
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "(Optional) Specifies the number of days you want to retain log events in the specified log group. Defaults to 14."
  default     = 14
}

variable "cloudwatch_log_group_kms_key_id" {
  type        = string
  description = "(Optional) The ARN of the KMS Key to use when encrypting log data. Defaults to null."
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
