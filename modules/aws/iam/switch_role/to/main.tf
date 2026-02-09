#--------------------------------------------------------------
# Module: aws/iam/switch_role/to
# Purpose: Create a target IAM role for cross-account switch with optional managed and custom inline policies.
# Notes: Enforces MFA via assume role policy; future improvement: add validation for mutually exclusive actions/not_actions.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.aws_iam_role.account_id
        }
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })
}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  count = var.is_enabled ? 1 : 0

  assume_role_policy = try(var.aws_iam_role.assume_role_policy, null) == null ? local.assume_role_policy : try(var.aws_iam_role.assume_role_policy, null)

  description           = try(var.aws_iam_role.description, null)
  force_detach_policies = true
  name                  = "${var.name_prefix}${var.aws_iam_role.name}"
  path                  = try(var.aws_iam_role.path, "/")

  tags = var.tags
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  count = var.is_enabled ? length(var.policy) : 0

  role       = aws_iam_role.this[0].name
  policy_arn = var.policy[count.index].policy_arn
}

#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "custom" {
  count = var.is_enabled && var.aws_iam_policy != null ? 1 : 0

  dynamic "statement" {
    for_each = try(var.aws_iam_policy.statement, [])

    content {
      sid           = try(statement.value.sid, null)
      effect        = try(statement.value.effect, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)
      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = try(principals.value.type, null)
          identifiers = try(principals.value.identifiers, null)
        }
      }
      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = try(not_principals.value.type, null)
          identifiers = try(not_principals.value.identifiers, null)
        }
      }
      dynamic "condition" {
        for_each = try(statement.value.condition, [])

        content {
          test     = try(condition.value.test, null)
          variable = try(condition.value.variable, null)
          values   = try(condition.value.values, null)
        }
      }
    }
  }
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
resource "aws_iam_policy" "custom" {
  count = var.is_enabled && var.aws_iam_policy != null ? 1 : 0

  description = try(var.aws_iam_policy.description, null)
  name        = "${var.name_prefix}${try(var.aws_iam_policy.name, null)}"
  path        = try(var.aws_iam_policy.path, "/")
  policy      = data.aws_iam_policy_document.custom[0].json

  tags = var.tags
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "custom" {
  count = var.is_enabled && var.aws_iam_policy != null ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.custom[0].arn
}
