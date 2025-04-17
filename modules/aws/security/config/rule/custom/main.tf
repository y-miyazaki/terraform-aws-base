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
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "this" {
  count                       = var.is_enabled ? 1 : 0
  name                        = lookup(var.aws_config_config_rule[count.index], "name")
  description                 = lookup(var.aws_config_config_rule[count.index], "description")
  input_parameters            = lookup(var.aws_config_config_rule[count.index], "input_parameters")
  maximum_execution_frequency = lookup(var.aws_config_config_rule[count.index], "maximum_execution_frequency")
  dynamic "scope" {
    for_each = lookup(var.aws_config_config_rule[count.index], "scope", [])
    content {
      compliance_resource_id    = lookup(scope.value, "compliance_resource_id", null)
      compliance_resource_types = lookup(scope.value, "compliance_resource_types", null)
      tag_key                   = lookup(scope.value, "tag_key", null)
      tag_value                 = lookup(scope.value, "tag_value", null)
    }
  }
  dynamic "source" {
    for_each = lookup(var.aws_config_config_rule[count.index], "source")
    content {
      owner             = lookup(source.value, "owner", null)
      source_identifier = lookup(source.value, "source_identifier", null)
      dynamic "source_detail" {
        for_each = lookup(source.value, "source_detail", [])
        content {
          event_source                = lookup(source_detail.value, "event_source", null)
          maximum_execution_frequency = lookup(source_detail.value, "maximum_execution_frequency", null)
          message_type                = lookup(source_detail.value, "message_type", null)
        }
      }
    }
  }
  tags = local.tags
}
