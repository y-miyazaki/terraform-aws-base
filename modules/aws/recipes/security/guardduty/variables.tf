#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_guardduty_detector" {
  type = object(
    {
      enable                       = bool
      finding_publishing_frequency = string
    }
  )
  description = "(Required) The resource of aws_guardduty_detector."
  default     = null
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
  default     = null
}
