#--------------------------------------------------------------
# Create Template
# TODO 0.12.x and later, can use the template function.
#--------------------------------------------------------------
data "template_file" "this" {
  #  template = file("task_definition/sonarqube.json.tpl")
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
  version = var.ver
}
#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
resource "aws_iam_policy" "this" {
  description = var.description
  name        = var.name
  #   name_prefix = var.name_prefix
  path   = var.path
  policy = var.template != null ? data.template_file.this.rendered : data.aws_iam_policy_document.this.json
  tags   = var.tags
}
