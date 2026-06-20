#--------------------------------------------------------------
# Module: aws/security/securityhub_organization
# Purpose: Central Security Hub organization configuration (organization-configuration,
#          finding aggregator and a central CSPM policy). Designed to be called from
#          the organization management account.
#--------------------------------------------------------------
# Optional Security Hub org admin account

data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

resource "aws_securityhub_organization_admin_account" "this" {
  count = var.is_enabled && var.is_enabled_admin ? 1 : 0

  region           = local.region
  admin_account_id = var.admin_account_id
}

resource "aws_securityhub_organization_configuration" "this" {
  count = var.is_enabled ? 1 : 0

  region                = local.region
  auto_enable           = false
  auto_enable_standards = "NONE"
  organization_configuration {
    configuration_type = "CENTRAL"
  }

  depends_on = [
    aws_securityhub_finding_aggregator.this
  ]
}

resource "aws_securityhub_finding_aggregator" "this" {
  count = var.is_enabled && var.is_enabled_finding_aggregator ? 1 : 0

  region       = local.region
  linking_mode = var.linking_mode
}

resource "aws_securityhub_configuration_policy" "this" {
  count = var.is_enabled ? 1 : 0

  region = local.region
  configuration_policy {
    service_enabled       = var.configuration_policy.service_enabled
    enabled_standard_arns = try(var.configuration_policy.enabled_standard_arns, [])
    security_controls_configuration {
      disabled_control_identifiers = try(var.configuration_policy.security_controls_configuration.disabled_control_identifiers, [])
    }
  }
  description = var.configuration_policy_description
  name        = var.configuration_policy_name

  depends_on = [aws_securityhub_organization_configuration.this]
}

resource "aws_securityhub_configuration_policy_association" "this" {
  count = var.is_enabled ? 1 : 0

  region    = local.region
  policy_id = aws_securityhub_configuration_policy.this[0].id
  target_id = var.target_id
}
