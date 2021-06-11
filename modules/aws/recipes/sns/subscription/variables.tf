#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_kms_key" {
  type = object(
    {
      description             = string
      deletion_window_in_days = number
      is_enabled              = bool
      enable_key_rotation     = bool
      alias_name              = string
    }
  )
  description = "(Required) The resource of aws_kms_key."
  default = {
    description             = "This key used for SNS."
    deletion_window_in_days = 7
    is_enabled              = true
    enable_key_rotation     = true
    alias_name              = "alias/sns"
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
variable "account_id" {
  type        = string
  description = "(Required) AWS account ID for member account."
}
variable "region" {
  type        = string
  description = "(Required) The region name."
}
variable "user" {
  type        = string
  description = "(Required) IAM user access KMS."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
