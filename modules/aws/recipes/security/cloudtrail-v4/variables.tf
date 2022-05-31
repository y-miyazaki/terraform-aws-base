#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of CloudTrail. Defaults true."
  default     = true
}
variable "is_s3_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable S3 Bucket. Defaults false."
  default     = false
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
variable "aws_cloudwatch_log_group" {
  type = object(
    {
      # The name of the log group. If omitted, Terraform will assign a random, unique name.
      name = string
      # Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire.
      retention_in_days = number
    }
  )
  description = "(Required) The resource of aws_cloudwatch_log_group."
}
variable "aws_iam_role" {
  type = object(
    {
      # Description of the role.
      description = string
      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Optional) The resource of aws_iam_role."
  default = {
    description = "Role for CloudTrail."
    name        = "security-cloudtrail-role"
    path        = "/"
  }
}
variable "aws_iam_policy" {
  type = object(
    {
      # Description of the IAM policy.
      description = string
      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Optional) The resource of aws_iam_policy."
  default = {
    description = "Policy for CloudTrail."
    name        = "security-cloudtrail-policy"
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
    bucket                               = "s3-cloudtrail"
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

variable "aws_cloudtrail" {
  type = object(
    {
      # Name of the trail.
      name = string
      # Enables logging for the trail. Defaults to true. Setting this to false will pause logging.
      enable_logging = bool
      # Whether the trail is publishing events from global services such as IAM to the log files. Defaults to true.
      include_global_service_events = bool
      # Whether the trail is created in the current region or in all regions. Defaults to false.
      is_multi_region_trail = bool
      # Whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account. Defaults to false.
      is_organization_trail = bool
      # Enables logging for the trail. Defaults to true. Setting this to false will pause logging.
      enable_log_file_validation = bool
      # Configuration block of an event selector for enabling data event logging. See details below. Please note the CloudTrail limits when configuring these.
      event_selector = list(any)
      # Configuration block for identifying unusual operational activity. See details below.
      insight_selector = list(any)
    }
  )
  description = "(Optional) The resource of aws_cloudtrail."
  default = {
    name                          = "cloudtrail"
    enable_logging                = true
    include_global_service_events = true
    is_multi_region_trail         = true
    is_organization_trail         = false
    enable_log_file_validation    = true
    event_selector = [
      {
        read_write_type           = "All"
        include_management_events = true
        data_resource = [
          {
            type   = "AWS::S3::Object"
            values = ["arn:aws:s3:::"]
          }
        ]
      }
    ]
    insight_selector = [
      {
        insight_type = "ApiCallRateInsight"
      }
    ]
  }
}
variable "cis_name_prefix" {
  type        = string
  description = "(Required) Center for Internet Security CloudWatch Filter/Alarm name prefix."
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
