#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable Trusted Advisor. Defaults true."
  default     = true
}
variable "aws_iam_role" {
  type = object(
    {
      # Description of the IAM policy.
      description = string
      # The name of the policy. If omitted, Terraform will assign a random, unique name.
      name = string
      # Path in which to create the policy. See IAM Identifiers for more information.
      path = string
      # Specify the original AWS account ID that will use the IAM Switch role. Please specify either assume_policy or account_id.
      account_id = string
      # If you want to configure your own settings for the role, specify the assume_policy. Please specify either assume_policy or account_id.
      assume_role_policy = string
    }
  )
  description = "(Required) Provides an IAM role."
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
      # The policy document. This is a JSON formatted string. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.
      statement = list(any)
    }
  )
  description = "(Optional) Provides an IAM policy."
  default     = null
}
variable "policy" {
  type        = list(any)
  description = "(Optional) Provides an IAM policy."
  default     = []
}
variable "name_prefix" {
  type        = string
  description = "(Optional) Prefix of policy name ."
  default     = ""
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
