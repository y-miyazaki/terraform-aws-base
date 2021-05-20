#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable AWS Config. Defaults true."
  default     = true
}
variable "aws_config_configuration_recorder" {
  type = object(
    {
      name            = string
      recording_group = list(any)
    }
  )
  description = "(Required) The aws_config_configuration_recorder resource."
  default     = null
}

variable "aws_iam_role" {
  type = object(
    {
      # (Optional) Description of the role.
      description = string
      # (Optional, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # (Optional) Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Required) The aws_iam_role resource."
  default = {
    description = null
    name        = "security-config-role"
    path        = "/"
  }
}

variable "aws_s3_bucket" {
  type = object(
    {
      bucket                               = string
      force_destroy                        = bool
      versioning                           = list(any)
      logging                              = list(any)
      lifecycle_rule                       = list(any)
      replication_configuration            = list(any)
      server_side_encryption_configuration = list(any)
      object_lock_configuration            = list(any)
    }
  )
  description = "(Required) The aws_s3_bucket resource."
  default     = null
}

variable "aws_config_delivery_channel" {
  type = object(
    {
      name                         = string
      sns_topic_arn                = string
      snapshot_delivery_properties = list(any)
    }
  )
  description = "(Required) The aws_config_delivery_channel resource."
  default     = null
}

variable "aws_config_configuration_recorder_status" {
  type = object(
    {
      is_enabled = bool
    }
  )
  description = "(Required) The aws_config_configuration_recorder_status resource."
  default     = null
}
variable "account_id" {
  type        = number
  description = "(Required) AWS account ID for member account."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
