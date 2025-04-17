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
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
