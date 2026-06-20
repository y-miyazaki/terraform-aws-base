#--------------------------------------------------------------
# Module: aws/waf
# Purpose: Generic WAFv2 Web ACL module supporting managed rules,
#          rate-based rules, and resource association.
#          Inspired by umotif-public/terraform-aws-waf-webaclv2,
#          simplified and modernized for AWS provider v6.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

#--------------------------------------------------------------
# CloudWatch Log Group for WAF logging
#--------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  count = var.logging.enabled && var.logging.log_destination_arn == null ? 1 : 0

  region            = local.region
  name              = coalesce(var.logging.log_group_name, "aws-waf-logs-${var.name}")
  kms_key_id        = var.logging.kms_key_id
  retention_in_days = var.logging.retention_in_days

  tags = var.tags
}

#--------------------------------------------------------------
# WAFv2 Web ACL
#--------------------------------------------------------------
resource "aws_wafv2_web_acl" "this" {
  region      = local.region
  name        = var.name
  description = var.description
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  dynamic "custom_response_body" {
    for_each = var.custom_response_bodies
    content {
      content      = custom_response_body.value.content
      content_type = custom_response_body.value.content_type
      key          = custom_response_body.value.key
    }
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      dynamic "action" {
        for_each = try(rule.value.action, null) != null ? [rule.value.action] : []
        content {
          dynamic "allow" {
            for_each = action.value == "allow" ? [1] : []
            content {}
          }
          dynamic "block" {
            for_each = action.value == "block" ? [1] : []
            content {}
          }
          dynamic "count" {
            for_each = action.value == "count" ? [1] : []
            content {}
          }
          dynamic "captcha" {
            for_each = action.value == "captcha" ? [1] : []
            content {}
          }
        }
      }

      dynamic "override_action" {
        for_each = try(rule.value.override_action, null) != null ? [rule.value.override_action] : []
        content {
          dynamic "none" {
            for_each = override_action.value == "none" ? [1] : []
            content {}
          }
          dynamic "count" {
            for_each = override_action.value == "count" ? [1] : []
            content {}
          }
        }
      }

      statement {
        # Managed rule group
        dynamic "managed_rule_group_statement" {
          for_each = try(rule.value.managed_rule_group_statement, null) != null ? [rule.value.managed_rule_group_statement] : []
          content {
            name        = managed_rule_group_statement.value.name
            vendor_name = try(managed_rule_group_statement.value.vendor_name, "AWS")
            version     = try(managed_rule_group_statement.value.version, null)

            dynamic "rule_action_override" {
              for_each = try(managed_rule_group_statement.value.rule_action_overrides, [])
              content {
                name = rule_action_override.value.name
                action_to_use {
                  dynamic "count" {
                    for_each = try(rule_action_override.value.action_to_use.count, null) != null ? [1] : []
                    content {}
                  }
                  dynamic "allow" {
                    for_each = try(rule_action_override.value.action_to_use.allow, null) != null ? [1] : []
                    content {}
                  }
                  dynamic "block" {
                    for_each = try(rule_action_override.value.action_to_use.block, null) != null ? [1] : []
                    content {}
                  }
                }
              }
            }
          }
        }

        # Rate-based rule
        dynamic "rate_based_statement" {
          for_each = try(rule.value.rate_based_statement, null) != null ? [rule.value.rate_based_statement] : []
          content {
            aggregate_key_type = try(rate_based_statement.value.aggregate_key_type, "IP")
            limit              = rate_based_statement.value.limit
          }
        }

        # Geo match
        dynamic "geo_match_statement" {
          for_each = try(rule.value.geo_match_statement, null) != null ? [rule.value.geo_match_statement] : []
          content {
            country_codes = geo_match_statement.value.country_codes
          }
        }

        # IP set reference
        dynamic "ip_set_reference_statement" {
          for_each = try(rule.value.ip_set_reference_statement, null) != null ? [rule.value.ip_set_reference_statement] : []
          content {
            arn = ip_set_reference_statement.value.arn
          }
        }
      }

      dynamic "visibility_config" {
        for_each = try(rule.value.visibility_config, null) != null ? [rule.value.visibility_config] : []
        content {
          cloudwatch_metrics_enabled = try(visibility_config.value.cloudwatch_metrics_enabled, true)
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = try(visibility_config.value.sampled_requests_enabled, true)
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.visibility_config.cloudwatch_metrics_enabled
    metric_name                = var.visibility_config.metric_name
    sampled_requests_enabled   = var.visibility_config.sampled_requests_enabled
  }

  tags = var.tags
}

#--------------------------------------------------------------
# WAFv2 Web ACL Association
#--------------------------------------------------------------
resource "aws_wafv2_web_acl_association" "this" {
  for_each = var.resource_arns

  region       = local.region
  resource_arn = each.value
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

#--------------------------------------------------------------
# WAFv2 Logging Configuration
#--------------------------------------------------------------
resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.logging.enabled ? 1 : 0

  region                  = local.region
  log_destination_configs = [coalesce(var.logging.log_destination_arn, try(aws_cloudwatch_log_group.this[0].arn, null))]
  resource_arn            = aws_wafv2_web_acl.this.arn

  dynamic "redacted_fields" {
    for_each = var.logging.redacted_fields
    content {
      dynamic "single_header" {
        for_each = try(redacted_fields.value.single_header, null) != null ? [redacted_fields.value.single_header] : []
        content {
          name = single_header.value.name
        }
      }
    }
  }

  dynamic "logging_filter" {
    for_each = try(var.logging.logging_filter.default_behavior, null) != null ? [var.logging.logging_filter] : []
    content {
      default_behavior = logging_filter.value.default_behavior

      dynamic "filter" {
        for_each = try(logging_filter.value.filter, [])
        content {
          behavior    = filter.value.behavior
          requirement = try(filter.value.requirement, "MEETS_ANY")

          dynamic "condition" {
            for_each = try(filter.value.condition, [])
            content {
              dynamic "action_condition" {
                for_each = try(condition.value.action_condition, null) != null ? [condition.value.action_condition] : []
                content {
                  action = action_condition.value.action
                }
              }
              dynamic "label_name_condition" {
                for_each = try(condition.value.label_name_condition, null) != null ? [condition.value.label_name_condition] : []
                content {
                  label_name = label_name_condition.value.label_name
                }
              }
            }
          }
        }
      }
    }
  }
}
