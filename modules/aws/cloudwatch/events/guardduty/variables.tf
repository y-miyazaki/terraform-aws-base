#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of GuardDuty. Defaults true."
  default     = true
}

variable "region" {
  type        = string
  description = "(Optional) AWS region for GuardDuty resources."
  default     = null
}

variable "aws_cloudwatch_event_rule" {
  type = object(
    {
      # (Required) The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.
      name = string
      # (Optional) The description of the rule.
      description = optional(string)
    }
  )
  description = "(Optional) Provides an EventBridge Rule resource."
  default = {
    name        = "security-guardduty-cloudwatch-event-rule"
    description = "This cloudwatch event used for GuardDuty."
  }
}

variable "aws_cloudwatch_event_target" {
  type = object(
    {
      # (Required) The Amazon Resource Name (ARN) associated of the target.
      arn = string
    }
  )
  description = "(Required) Provides an EventBridge Target resource."
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
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
