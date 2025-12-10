#--------------------------------------------------------------
# Module: aws/security/iam
# Purpose: Enforce account-level IAM password policy and optionally provision a support role with AWSSupportAccess.
# Notes: Role creation conditional on var.aws_iam_role; future enhancement: parameterize attached policies and strengthen assume role principals validation.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Manages Password Policy for the AWS Account. See more about Account Password Policy in the official AWS docs.
#--------------------------------------------------------------
resource "aws_iam_account_password_policy" "this" {
  count = var.is_enabled ? 1 : 0

  allow_users_to_change_password = var.aws_iam_account_password_policy.allow_users_to_change_password
  hard_expiry                    = var.aws_iam_account_password_policy.hard_expiry
  max_password_age               = var.aws_iam_account_password_policy.max_password_age
  minimum_password_length        = var.aws_iam_account_password_policy.minimum_password_length
  password_reuse_prevention      = var.aws_iam_account_password_policy.password_reuse_prevention
  require_lowercase_characters   = var.aws_iam_account_password_policy.require_lowercase_characters
  require_numbers                = var.aws_iam_account_password_policy.require_numbers
  require_symbols                = var.aws_iam_account_password_policy.require_symbols
  require_uppercase_characters   = var.aws_iam_account_password_policy.require_uppercase_characters
}

#--------------------------------------------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "this" {
  count = var.is_enabled && var.aws_iam_role != null ? 1 : 0

  statement {
    principals {
      type        = "AWS"
      identifiers = var.support_iam_role_principal_arns
    }
    actions = ["sts:AssumeRole"]
  }
}

#--------------------------------------------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------------------------------------------
resource "aws_iam_role" "this" {
  count = var.is_enabled && var.aws_iam_role != null ? 1 : 0

  assume_role_policy = var.is_enabled ? data.aws_iam_policy_document.this[0].json : null

  description           = try(var.aws_iam_role.description, null)
  force_detach_policies = true
  name                  = var.aws_iam_role.name
  path                  = try(var.aws_iam_role.path, "/")

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "support_policy" {
  count = var.is_enabled && var.aws_iam_role != null ? 1 : 0

  role       = aws_iam_role.this[0].id
  policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}
