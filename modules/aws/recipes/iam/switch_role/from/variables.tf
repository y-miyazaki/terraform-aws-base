#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable Trusted Advisor. Defaults true."
  default     = true
}
variable "group" {
  type        = string
  description = "(Required) Specify the group name to which the IAM policy is attached."
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
variable "name_prefix" {
  type        = string
  description = "(Optional) Prefix of policy name ."
  default     = ""
}
