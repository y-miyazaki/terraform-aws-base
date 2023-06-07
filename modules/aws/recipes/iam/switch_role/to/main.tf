#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.aws_iam_role.account_id}"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
POLICY
}
#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  count                 = var.is_enabled ? 1 : 0
  description           = lookup(var.aws_iam_role, "description")
  name                  = "${var.name_prefix}${lookup(var.aws_iam_role, "name")}"
  assume_role_policy    = lookup(var.aws_iam_role, "assume_role_policy", null) == null ? local.assume_role_policy : lookup(var.aws_iam_role, "assume_role_policy", null)
  force_detach_policies = true
  path                  = lookup(var.aws_iam_role, "path", "/")
  tags                  = local.tags
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  count      = var.is_enabled ? length(var.policy) : 0
  role       = aws_iam_role.this[0].name
  policy_arn = var.policy[count.index].policy_arn
}

#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "custom" {
  count = var.is_enabled && var.aws_iam_policy != null ? 1 : 0
  dynamic "statement" {
    for_each = lookup(var.aws_iam_policy, "statement", [])
    content {
      sid           = lookup(statement.value, "sid", null)
      effect        = lookup(statement.value, "effect", null)
      actions       = lookup(statement.value, "actions", null)
      not_actions   = lookup(statement.value, "not_actions", null)
      resources     = lookup(statement.value, "resources", null)
      not_resources = lookup(statement.value, "not_resources", null)
      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])
        content {
          type        = lookup(principals.value, "type", null)
          identifiers = lookup(principals.value, "identifiers", null)
        }
      }
      dynamic "not_principals" {
        for_each = lookup(statement.value, "not_principals", [])
        content {
          type        = lookup(not_principals.value, "type", null)
          identifiers = lookup(not_principals.value, "identifiers", null)
        }
      }
      dynamic "condition" {
        for_each = lookup(statement.value, "condition", [])
        content {
          test     = lookup(condition.value, "test", null)
          variable = lookup(condition.value, "variable", null)
          values   = lookup(condition.value, "values", null)
        }
      }
    }
  }
}
#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
resource "aws_iam_policy" "custom" {
  count       = var.is_enabled && var.aws_iam_policy != null ? 1 : 0
  description = lookup(var.aws_iam_policy, "description")
  name        = "${var.name_prefix}${lookup(var.aws_iam_policy, "name", null)}"
  #   name_prefix = var.name_prefix
  path   = lookup(var.aws_iam_policy, "path", "/")
  policy = data.aws_iam_policy_document.custom[0].json
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "custom" {
  count      = var.is_enabled && var.aws_iam_policy != null ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.custom[0].arn
}
