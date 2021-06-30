#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
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
  description = "(Optional) Provides an IAM role."
  default = {
    description = "Role for CloudWatch."
    name        = "cloudwatch-role"
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
      # Path in which to create the poliwcy. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Optional) Provides an IAM policy."
  default = {
    description = "Policy for CloudWatch."
    name        = "cloudwatch-policy"
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
