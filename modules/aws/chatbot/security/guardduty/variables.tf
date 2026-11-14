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
