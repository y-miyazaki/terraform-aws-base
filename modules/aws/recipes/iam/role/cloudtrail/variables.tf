#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
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
    name        = "cloudtrail-role"
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
    name        = "cloudtrail-policy"
    path        = "/"
  }
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
