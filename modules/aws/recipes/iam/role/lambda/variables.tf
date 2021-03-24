#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
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
  description = "(Required) Provides an IAM role."
  default = {
    description = null
    name        = "lambda-role"
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
      #  (Required) The policy document. This is a JSON formatted string. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.
      policy = string
    }
  )
  description = "(Required) Provides an IAM policy."
  default = {
    description = null
    name        = "lambda-policy"
    path        = "/"
    policy      = null
  }
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
