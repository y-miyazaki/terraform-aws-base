#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of CloudTrail. Defaults true."
  default     = true
}
variable "aws_kms_key" {
  type = object(
    {
      cloudtrail = object(
        {
          # The description of the key as viewed in AWS console.
          description = string
          # Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days.
          deletion_window_in_days = number
          # Specifies whether the key is enabled. Defaults to true.
          is_enabled = bool
          # Specifies whether key rotation is enabled. Defaults to true.
          enable_key_rotation = bool
          # The display name of the alias. The name must start with the word "alias" followed by a forward slash (alias/)
          alias_name = string
        }
      )
      sns = object(
        {
          # The description of the key as viewed in AWS console.
          description = string
          # Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days.
          deletion_window_in_days = number
          # Specifies whether the key is enabled. Defaults to true.
          is_enabled = bool
          # Specifies whether key rotation is enabled. Defaults to true.
          enable_key_rotation = bool
          # The display name of the alias. The name must start with the word "alias" followed by a forward slash (alias/)
          alias_name = string
        }
      )
    }
  )
  description = "(Optional) The resource of aws_kms_key."
  default = {
    cloudtrail = {
      description             = "This key used for CloudTrail."
      deletion_window_in_days = 7
      is_enabled              = true
      enable_key_rotation     = true
      alias_name              = "alias/cloudtrail"
    }
    sns = {
      description             = "This key used for SNS."
      deletion_window_in_days = 7
      is_enabled              = true
      enable_key_rotation     = true
      alias_name              = "alias/sns"
    }
  }
}
variable "aws_sns_topic" {
  type = object(
    {
      # The name of the topic. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix
      name = string
      # Creates a unique name beginning with the specified prefix. Conflicts with name
      name_prefix = string
      # The display name for the topic
      display_name = string
      # The fully-formed AWS policy as JSON. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.
      delivery_policy = string
      # The IAM role permitted to receive success feedback for this topic
      application_success_feedback_role_arn = string
      # Percentage of success to sample
      application_success_feedback_sample_rate = string
      # IAM role for failure feedback
      application_failure_feedback_role_arn = string
      # The IAM role permitted to receive success feedback for this topic
      http_success_feedback_role_arn = string
      # Percentage of success to sample
      http_success_feedback_sample_rate = string
      # IAM role for failure feedback
      http_failure_feedback_role_arn = string
      # The IAM role permitted to receive success feedback for this topic
      lambda_success_feedback_role_arn = string
      # Percentage of success to sample
      lambda_success_feedback_sample_rate = string
      # IAM role for failure feedback
      lambda_failure_feedback_role_arn = string
      # The IAM role permitted to receive success feedback for this topic
      sqs_success_feedback_role_arn = string
      # Percentage of success to sample
      sqs_success_feedback_sample_rate = string
      # IAM role for failure feedback
      sqs_failure_feedback_role_arn = string
    }
  )
  description = "(Required) The resource of aws_sns_topic."
}
variable "aws_sns_topic_subscription" {
  type = object(
    {
      # Endpoint to send data to. The contents vary with the protocol. See details below.
      endpoint = string
      # Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application. Protocols email, email-json, http and https are also valid but partially supported. See details below.
      protocol = string
      # Integer indicating number of minutes to wait in retrying mode for fetching subscription arn before marking it as failure. Only applicable for http and https protocols. Default is 1.
      confirmation_timeout_in_minutes = number
      # JSON String with the delivery policy (retries, backoff, etc.) that will be used in the subscription - this only applies to HTTP/S subscriptions. Refer to the SNS docs for more details.
      delivery_policy = string
      # Whether the endpoint is capable of auto confirming subscription (e.g., PagerDuty). Default is false.
      endpoint_auto_confirms = bool
      # JSON String with the filter policy that will be used in the subscription to filter messages seen by the target resource. Refer to the SNS docs for more details.
      filter_policy = string
      # Whether to enable raw message delivery (the original message is directly passed, not wrapped in JSON with the original message in the message property). Default is false.
      raw_message_delivery = string
      # JSON String with the redrive policy that will be used in the subscription. Refer to the SNS docs for more details.
      redrive_policy = string
    }
  )
  description = "(Required) The resource of aws_sns_topic_subscription."
}

variable "cloudtrail_log_group_name" {
  type        = string
  description = "(Optional) CloudTrail log group name."
  default     = "aws-controltower/CloudTrailLogs"
}
variable "cis_name_prefix" {
  type        = string
  description = "(Required) CloudWatch Filter/Alarm name prefix."
}
variable "account_id" {
  type        = string
  description = "(Required) AWS account ID for member account."
}
variable "region" {
  type        = string
  description = "(Required) The region name."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
