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
      # Whether to allow users to change their own password
      allow_users_to_change_password = bool
      # Whether users are prevented from setting a new password after their password has expired (i.e. require administrator reset)
      hard_expiry = bool
      # The number of days that an user password is valid.
      max_password_age = number
      # Minimum length to require for user passwords.
      minimum_password_length = number
      # The number of previous passwords that users are prevented from reusing.
      password_reuse_prevention = number
      # Whether to require lowercase characters for user passwords.
      require_lowercase_characters = bool
      # Whether to require numbers for user passwords.
      require_numbers = bool
      # Whether to require symbols for user passwords.
      require_symbols = bool
      # Whether to require uppercase characters for user passwords.
      require_uppercase_characters = bool
    }
  )
  description = "(Optional) The resource of aws_iam_account_password_policy."
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
  description = "(Optional) The resource of aws_iam_role."
  default = {
    description = "Role for IAM Role."
    name        = "security-iam-role"
    path        = "/"
  }
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
