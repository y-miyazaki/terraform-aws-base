#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_kms_key" {
  type = object(
    {
      cloudtrail = object(
        {
          description         = string
          is_enabled          = bool
          enable_key_rotation = bool
          alias_name          = string
        }
      )
      sns = object(
        {
          description         = string
          is_enabled          = bool
          enable_key_rotation = bool
          alias_name          = string
        }
      )
    }
  )
  description = "(Required) The resource of aws_kms_key."
  default = {
    cloudtrail = {
      description         = "This key used for CloudTrail."
      is_enabled          = true
      enable_key_rotation = true
      alias_name          = "alias/cloudtrail"
    }
    sns = {
      description         = "This key used for SNS."
      is_enabled          = true
      enable_key_rotation = true
      alias_name          = "alias/sns"
    }
  }
}
variable "aws_sns_topic" {
  type = object(
    {
      name                                     = string
      name_prefix                              = string
      display_name                             = string
      delivery_policy                          = string
      application_success_feedback_role_arn    = string
      application_success_feedback_sample_rate = string
      application_failure_feedback_role_arn    = string
      http_success_feedback_role_arn           = string
      http_success_feedback_sample_rate        = string
      http_failure_feedback_role_arn           = string
      lambda_success_feedback_role_arn         = string
      lambda_success_feedback_sample_rate      = string
      lambda_failure_feedback_role_arn         = string
      sqs_success_feedback_role_arn            = string
      sqs_success_feedback_sample_rate         = string
      sqs_failure_feedback_role_arn            = string
    }
  )
  description = "(Required) The resource of aws_sns_topic."
  default     = null
}
variable "aws_sns_topic_subscription" {
  type = object(
    {
      protocol                        = string
      endpoint                        = string
      endpoint_auto_confirms          = bool
      confirmation_timeout_in_minutes = number
      raw_message_delivery            = string
      filter_policy                   = string
      delivery_policy                 = string
      redrive_policy                  = string
    }
  )
  description = "(Required) The resource of aws_sns_topic_subscription."
  default     = null
}
variable "aws_cloudwatch_log_group" {
  type = object(
    {
      name              = string
      retention_in_days = number
    }
  )
  description = "(Required) The resource of aws_cloudwatch_log_group."
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
  description = "(Required) The resource of aws_iam_role."
  default = {
    description = null
    name        = "security-cloudtrail-role"
    path        = "/"
  }
}
variable "aws_iam_policy" {
  type = object(
    {
      # (Optional) Description of the IAM policy.
      description = string
      # (Optional, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # (Optional) Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Required) The resource of aws_iam_policy."
  default = {
    description = null
    name        = "security-cloudtrail-policy"
    path        = "/"
  }
}
variable "aws_s3_bucket" {
  type = object(
    {
      bucket                               = string
      acl                                  = string
      force_destroy                        = bool
      versioning                           = list(any)
      logging                              = list(any)
      lifecycle_rule                       = list(any)
      replication_configuration            = list(any)
      server_side_encryption_configuration = list(any)
      object_lock_configuration            = list(any)
    }
  )
  description = "(Required) The resource of aws_sns_topic_subscription."
  default     = null
}
variable "aws_cloudtrail" {
  type = object(
    {
      name                          = string
      enable_logging                = bool
      include_global_service_events = bool
      is_multi_region_trail         = bool
      is_organization_trail         = bool
      enable_log_file_validation    = bool
      event_selector                = list(any)
      insight_selector              = list(any)
    }
  )
  description = "(Required) The resource of aws_cloudtrail."
  default     = null
}
variable "cis_name_prefix" {
  type        = string
  description = "(Required) Center for Internet Security CloudWatch Filter/Alerm name prefix."
  default     = null
}
variable "account_id" {
  type        = string
  description = "(Required) AWS account ID for member account."
  default     = null
}
variable "region" {
  type        = string
  description = "(Required) The region name."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
