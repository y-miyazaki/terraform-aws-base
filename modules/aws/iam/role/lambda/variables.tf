#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_vpc" {
  type        = bool
  description = "(Optional) If you are deploying Lambda inside a VPC, set to true."
  default     = false
}
variable "aws_iam_role" {
  type = object(
    {
      # Description of the role.
      description = optional(string)
      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # Path to the role. See IAM Identifiers for more information.
      path = optional(string)
    }
  )
  description = "(Optional) Provides an IAM role."
  default = {
    description = "Role for Lambda."
    name        = "lambda-role"
    path        = "/"
  }
}
variable "aws_iam_policy" {
  type = object(
    {
      # Description of the IAM policy.
      description = optional(string)
      # The name of the policy. If omitted, Terraform will assign a random, unique name.
      name = string
      # Path in which to create the policy. See IAM Identifiers for more information.
      path = optional(string)
      #  (Required) The policy document. This is a JSON formatted string. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.
      policy = string
    }
  )
  description = "(Optional) Provides an IAM policy."
  default = {
    description = "Policy for Lambda."
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
