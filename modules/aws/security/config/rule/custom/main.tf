#--------------------------------------------------------------
# Module: aws/security/config/rule/custom
# Purpose: Deploy parameterized custom AWS Config rules (managed or custom Lambda) with dynamic scope and source details.
# Notes: Iterates over complex nested structures; future improvement: add validation for consistent source_detail fields.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

resource "aws_config_config_rule" "this" {
  count = var.is_enabled ? 1 : 0

  region                      = local.region
  name                        = var.aws_config_config_rule[count.index].name
  description                 = var.aws_config_config_rule[count.index].description
  input_parameters            = var.aws_config_config_rule[count.index].input_parameters
  maximum_execution_frequency = var.aws_config_config_rule[count.index].maximum_execution_frequency
  dynamic "scope" {
    for_each = try(var.aws_config_config_rule[count.index].scope, [])

    content {
      compliance_resource_id    = try(scope.value.compliance_resource_id, null)
      compliance_resource_types = try(scope.value.compliance_resource_types, null)
      tag_key                   = try(scope.value.tag_key, null)
      tag_value                 = try(scope.value.tag_value, null)
    }
  }
  dynamic "source" {
    for_each = var.aws_config_config_rule[count.index].source

    content {
      owner             = try(source.value.owner, null)
      source_identifier = try(source.value.source_identifier, null)
      dynamic "source_detail" {
        for_each = try(source.value.source_detail, [])

        content {
          event_source                = try(source_detail.value.event_source, null)
          maximum_execution_frequency = try(source_detail.value.maximum_execution_frequency, null)
          message_type                = try(source_detail.value.message_type, null)
        }
      }
    }
  }

  tags = var.tags
}
