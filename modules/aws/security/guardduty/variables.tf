#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "region" {
  type        = string
  description = "(Optional) AWS region for this GuardDuty detector. Enables multi-region deployments. Defaults to provider region."
  default     = null
}

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

variable "aws_guardduty_detector_feature" {
  type = map(object(
    {
      # (Required) ENABLED or DISABLED.
      status = string
      # (Optional) Additional configurations of the feature (for example RUNTIME_MONITORING agent management).
      additional_configurations = optional(list(object({
        name   = string
        status = string
      })), [])
    }
  ))
  description = "(Optional) Map of GuardDuty detector features keyed by feature name (for example S3_DATA_EVENTS, EBS_MALWARE_PROTECTION). Features that are not listed keep the AWS default. Defaults to an empty map."
  default     = {}
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
