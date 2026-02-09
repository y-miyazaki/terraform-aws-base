#--------------------------------------------------------------
# Module: aws/iam/switch_role/from
# Purpose: Create a custom IAM policy and attach it to a group enabling switching from a source account.
# Notes: Policy document fully parameterized; future improvement: add validation for mutually exclusive actions/not_actions usage.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "custom" {
  count = var.is_enabled && var.aws_iam_policy != null ? 1 : 0

  dynamic "statement" {
    for_each = var.aws_iam_policy != null ? var.aws_iam_policy.statement : []

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
  name        = "${var.name_prefix}${var.aws_iam_policy.name}"
  path        = try(var.aws_iam_policy.path, "/")
  policy      = data.aws_iam_policy_document.custom[0].json

  tags = var.tags
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM group
#--------------------------------------------------------------
resource "aws_iam_group_policy_attachment" "custom" {
  count = var.is_enabled && var.aws_iam_policy != null ? 1 : 0

  group      = var.group
  policy_arn = aws_iam_policy.custom[0].arn
}
