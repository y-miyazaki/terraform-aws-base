#--------------------------------------------------------------
# module variables(aws_cloudwatch_event_rule)
#--------------------------------------------------------------
variable "aws_cloudwatch_log_subscription_filter" {
  type = list(object(
    {
      name            = string
      destination_arn = string
      filter_pattern  = string
      log_group_name  = string
      #   role_arn        = string
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
