#--------------------------------------------------------------
# Module: Amazon Inspector v2 (org-level / delegated admin)
# CAUTION: This module manages organization-level Inspector2 settings.
# Use only in your organization's admin (delegated) account.
# Default is false to avoid accidental organization-wide enablement.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

#--------------------------------------------------------------
# Delegated admin account
# - Register a delegated admin account for Amazon Inspector in the Organization.
# - This must be executed from the Organization management account.
#--------------------------------------------------------------
resource "aws_inspector2_delegated_admin_account" "this" {
  count = var.is_enabled && var.is_enabled_delegated_admin ? 1 : 0

  region     = local.region
  account_id = var.delegated_admin_account_id
}

#--------------------------------------------------------------
# Member account association
# - Associate member accounts with Inspector2 before enabling scanning.
# - Automatically derived from enabler account_ids.
#--------------------------------------------------------------
locals {
  member_account_ids = var.is_enabled ? toset(flatten([for k, v in var.enabler : v.account_ids])) : toset([])
}

resource "aws_inspector2_member_association" "this" {
  for_each = local.member_account_ids

  region     = local.region
  account_id = each.value
}

#--------------------------------------------------------------
# Enabler for Amazon Inspector scanning in specified accounts
# - Must be executed in the Organization's Administrator account
# - Accepts account_ids and resource_types (EC2, ECR, LAMBDA, LAMBDA_CODE, CODE_REPOSITORY)
#--------------------------------------------------------------
resource "aws_inspector2_enabler" "this" {
  for_each = var.is_enabled ? var.enabler : {}

  region         = local.region
  account_ids    = each.value.account_ids
  resource_types = each.value.resource_types

  depends_on = [aws_inspector2_member_association.this]
}
#--------------------------------------------------------------
# Organization-level configuration for Inspector2 auto-enabling new accounts
# - Configure which resource scanning types will automatically be turned on
#   for new members of the organization.
#--------------------------------------------------------------
resource "aws_inspector2_organization_configuration" "this" {
  count = var.is_enabled && var.is_enabled_configuration ? 1 : 0

  region = local.region
  auto_enable {
    ec2             = var.configuration.auto_enable_ec2
    ecr             = var.configuration.auto_enable_ecr
    lambda          = var.configuration.auto_enable_lambda
    lambda_code     = var.configuration.auto_enable_lambda_code
    code_repository = var.configuration.auto_enable_code_repository
  }
}
