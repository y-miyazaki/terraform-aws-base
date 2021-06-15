#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of GuardDuty. Defaults true."
  default     = true
}
variable "aws_guardduty_detector" {
  type = object(
    {
      enable                       = bool
      finding_publishing_frequency = string
    }
  )
  description = "(Required) The resource of aws_guardduty_detector."
}
variable "aws_guardduty_member" {
  type = list(object(
    {
      account_id                 = string
      email                      = string
      invite                     = bool
      invitation_message         = string
      disable_email_notification = bool
    }
  ))
  description = "(Required) The resource of aws_guardduty_member."
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
    name        = "security-guarduty-cloudwatch-event-rule"
    description = "This cloudwatch event used for GuardDuty."
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
