#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "custom" {
  count = var.is_enabled ? 1 : 0
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
  count       = var.is_enabled ? 1 : 0
  description = lookup(var.aws_iam_policy, "description", null)
  name        = "${var.name_prefix}${lookup(var.aws_iam_policy, "name", null)}"
  #   name_prefix = var.name_prefix
  path   = lookup(var.aws_iam_policy, "path", "/")
  policy = data.aws_iam_policy_document.custom[0].json
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM group
#--------------------------------------------------------------
resource "aws_iam_group_policy_attachment" "custom" {
  count      = var.is_enabled ? 1 : 0
  group      = var.group
  policy_arn = aws_iam_policy.custom[0].arn
  depends_on = [
    aws_iam_policy.custom
  ]
}
