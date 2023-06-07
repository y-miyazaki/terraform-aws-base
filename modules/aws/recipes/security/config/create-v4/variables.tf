#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable AWS Config. Defaults true."
  default     = true
}
variable "is_s3_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable S3 Bucket. Defaults false."
  default     = false
}
variable "aws_config_configuration_recorder" {
  type = object(
    {
      name            = string
      recording_group = list(any)
    }
  )
  description = "(Required) The aws_config_configuration_recorder resource."
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
  description = "(Optional) The aws_iam_role resource."
  default = {
    description = "Role for AWS Config."
    name        = "security-config-role"
    path        = "/"
  }
}
variable "s3_bucket" {
  type = object(
    {
      # (Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be lowercase and less than or equal to 63 characters in length. A full list of bucket naming rules may be found here.
      bucket                               = string
      lifecycle_rule                       = any
      logging                              = any
      server_side_encryption_configuration = any
      versioning                           = any
    }
  )
  description = "(Optional) If you have a new S3 to create, please specify this one. Yes to the variable:aws_s3_bucket_exsiting."
  default = {
    bucket                               = "s3-log"
    lifecycle_rule                       = {}
    logging                              = {}
    server_side_encryption_configuration = {}
    versioning                           = {}
  }
}
variable "aws_s3_bucket_existing" {
  type = object(
    {
      # The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be less than or equal to 63 characters in length.
      bucket_id = string
      # The S3 bucket arn
      bucket_arn = string
    }
  )
  description = "(Optional) If you have an S3 that already exists, please specify this one. It is exclusive to the variable:aws_s3_bucket."
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
}

variable "aws_config_configuration_recorder_status" {
  type = object(
    {
      is_enabled = bool
    }
  )
  description = "(Required) The aws_config_configuration_recorder_status resource."
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
    name        = "security-config-cloudwatch-event-rule"
    description = "This cloudwatch event used for Config."
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
