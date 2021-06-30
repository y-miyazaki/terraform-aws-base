#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_cloudwatch_log_subscription_filter" {
  type = list(object(
    {
      # A name for the subscription filter
      name = string
      # The ARN of the destination to deliver matching log events to. Kinesis stream or Lambda function ARN.
      destination_arn = string
      # A valid CloudWatch Logs filter pattern for subscribing to a filtered stream of log events.
      filter_pattern = string
      # The name of the log group to associate the subscription filter with
      log_group_name = string
      # The method used to distribute log data to the destination. By default log data is grouped by log stream, but the grouping can be set to random for a more even distribution. This property is only applicable when the destination is an Amazon Kinesis stream. Valid values are "Random" and "ByLogStream".
      distribution = string
    }
    )
  )
  description = "(Optional) aws_cloudwatch_log_subscription_filter."
  default     = []
}
variable "aws_iam_role" {
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
  description = "(Optional) Provides an IAM role."
  default = {
    description = "Roles for CloudWatch Subscription."
    name        = "cloudwatch-subscription-role"
    path        = "/"
  }
}
variable "aws_iam_policy" {
  type = object(
    {
      # Description of the IAM policy.
      description = string
      # The name of the policy. If omitted, Terraform will assign a random, unique name.
      name = string
      # Path in which to create the policy. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Optional) Provides an IAM policy."
  default = {
    description = "Policy for CloudWatch Subscription."
    name        = "cloudwatch-subscription-policy"
    path        = "/"
  }
}
variable "account_id" {
  type        = string
  description = "(Required) AWS account ID for member account."
}
variable "region" {
  type        = string
  description = "(Required) Specify the region."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
