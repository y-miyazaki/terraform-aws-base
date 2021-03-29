#--------------------------------------------------------------
# module variables(aws_cloudwatch_event_rule)
#--------------------------------------------------------------
variable "aws_cloudwatch_log_subscription_filter" {
  type = list(object(
    {
      # (Required) A name for the subscription filter
      name = string
      # (Required) The ARN of the destination to deliver matching log events to. Kinesis stream or Lambda function ARN.
      destination_arn = string
      # (Required) A valid CloudWatch Logs filter pattern for subscribing to a filtered stream of log events.
      filter_pattern = string
      # (Required) The name of the log group to associate the subscription filter with
      log_group_name = string
      # (Optional) The method used to distribute log data to the destination. By default log data is grouped by log stream, but the grouping can be set to random for a more even distribution. This property is only applicable when the destination is an Amazon Kinesis stream. Valid values are "Random" and "ByLogStream".
      distribution = string
    }
    )
  )
  description = "(Required) aws_cloudwatch_log_subscription_filter."
  default     = []
}
variable "aws_iam_role" {
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
  description = "(Required) Provides an IAM role."
  default = {
    description = null
    name        = "cloudwatch-subscription-role"
    path        = "/"
  }
}
variable "aws_iam_policy" {
  type = object(
    {
      # (Optional, Forces new resource) Description of the IAM policy.
      description = string
      # (Optional, Forces new resource) The name of the policy. If omitted, Terraform will assign a random, unique name.
      name = string
      # (Optional, default "/") Path in which to create the policy. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Required) Provides an IAM policy."
  default = {
    description = null
    name        = "cloudwatch-subscription-policy"
    path        = "/"
  }
}
variable "account_id" {
  type        = number
  description = "(Required) AWS account ID for member account."
  default     = null
}
variable "region" {
  type        = string
  description = "(Required) Specify the region."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
