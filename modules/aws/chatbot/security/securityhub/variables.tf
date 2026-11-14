#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "name_prefix" {
  type        = string
  description = "(Optional) Name prefix of all resources."
  default     = ""
}

variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of GuardDuty. Defaults true."
  default     = true
}

variable "kms_master_key_id" {
  type        = string
  description = "(Optional) KMS key ID to set for SNS Topic."
  default     = null
}

variable "cloudwatch_log_group_kms_key_id" {
  type        = string
  description = "(Optional) KMS key ID to set for CloudWatch log group."
  default     = null
}

variable "step_functions_kms_key_arn" {
  type        = string
  description = "(Optional) KMS key ARN to encrypt the Step Functions state machine with a customer managed key. Null uses the AWS owned key."
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "(Required) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}

variable "retry_policy" {
  type = object({
    # The maximum amount of time, in seconds, to continue to make retry attempts.
    maximum_event_age_in_seconds = number
    # The maximum number of retry attempts to make before the request fails.
    maximum_retry_attempts = number
  })
  description = "(Optional) Retry policy of the EventBridge target. Defaults to the EventBridge defaults (24 hours, 185 attempts). Events are dropped after the retries are exhausted because no dead-letter queue is configured."
  default = {
    maximum_event_age_in_seconds = 86400
    maximum_retry_attempts       = 185
  }
}
