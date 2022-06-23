#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of Health. Defaults true."
  default     = true
}
variable "aws_cloudwatch_event_rule" {
  type = object(
    {
      # (Required) The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.
      name = string
      # (Optional) The description of the rule.
      description = string
    }
  )
  description = "(Optional) Provides an EventBridge Rule resource."
  default = {
    name        = "health-cloudwatch-event-rule"
    description = "This cloudwatch event used for Health."
    role_arn    = null
    is_enabled  = true
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
