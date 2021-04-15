#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable IAM security. Defaults true."
  default     = true
}
variable "aws_iam_account_password_policy" {
  type = object(
    {
      allow_users_to_change_password = bool
      hard_expiry                    = bool
      max_password_age               = number
      minimum_password_length        = number
      password_reuse_prevention      = number
      require_lowercase_characters   = bool
      require_numbers                = bool
      require_symbols                = bool
      require_uppercase_characters   = bool
    }
  )
  description = "(Required) The resource of aws_iam_account_password_policy."
  default = {
    allow_users_to_change_password = true
    hard_expiry                    = true
    max_password_age               = 90
    minimum_password_length        = 14
    password_reuse_prevention      = 24
    require_lowercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    require_uppercase_characters   = true
  }
}
variable "support_iam_role_principal_arns" {
  type        = list(any)
  description = "(Required) iam role principal arn."
  default     = null
}
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
  description = "(Required) The resource of aws_iam_role."
  default = {
    description = null
    name        = "security-iam-role"
    path        = "/"
  }
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
