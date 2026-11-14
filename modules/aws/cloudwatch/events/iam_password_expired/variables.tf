#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable Trusted Advisor. Defaults true."
  default     = true
}

variable "aws_cloudwatch_event_rule" {
  type = object(
    {
      # The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.
      name = string
      # The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes). At least one of schedule_expression or event_pattern is required. Can only be used on the default event bus.
      schedule_expression = string
      # The description of the rule.
      description = optional(string)
      # Whether the rule should be enabled (defaults to ENABLED).
      state = string
    }
  )
  description = "(Optional) Provides an EventBridge Rule resource."
  default = {
    name                = "trusted-advisor-cloudwatch-event-rule"
    schedule_expression = "cron(*/5 * * * ? *)"
    description         = "Trusted Advisor event rule."
    state               = "ENABLED"
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
