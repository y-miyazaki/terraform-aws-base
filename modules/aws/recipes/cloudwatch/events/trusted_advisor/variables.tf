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
      description = string
      # Whether the rule should be enabled (defaults to true).
      is_enabled = bool
    }
  )
  description = "(Optional) Provides an EventBridge Rule resource."
  default = {
    name                = "trusted-advisor-cloudwatch-event-rule"
    schedule_expression = "cron(*/5 * * * ? *)"
    description         = "Trusted Advisor event rule."
    role_arn            = null
    is_enabled          = true
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
