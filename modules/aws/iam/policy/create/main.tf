#--------------------------------------------------------------
# Module: aws/iam/policy/create
# Purpose: Create a managed IAM policy from either a template file or inline policy document definition.
# Notes: Adds unified tagging local; future improvement: deprecate template_file data source in favor of templatefile() function.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Create Template
# TODO 0.12.x and later, can use the template function.
#--------------------------------------------------------------
data "template_file" "this" {
  template = var.template != null ? file(var.template) : null
  vars     = var.vars
}

#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "this" {
  policy_id = var.policy_id
  # source_json   = var.source_json
  # override_json = var.override_json
  dynamic "statement" {
    for_each = var.statement

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
  version = var.ver
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
resource "aws_iam_policy" "this" {
  description = var.description
  name        = var.name
  path        = var.path
  policy      = var.template != null ? data.template_file.this.rendered : data.aws_iam_policy_document.this.json

  tags = var.tags
}
