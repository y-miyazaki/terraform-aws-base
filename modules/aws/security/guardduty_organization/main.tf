#--------------------------------------------------------------
# Module: aws/security/guardduty_organization
# Purpose: Central GuardDuty organization configuration (organization-configuration,
#          admin account and features). Designed to be called from
#          the organization management account.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

#--------------------------------------------------------------
# GuardDuty Organization Admin Account
# - Register a delegated admin account for GuardDuty in the Organization.
# - This must be executed from the Organization management account.
#--------------------------------------------------------------
resource "aws_guardduty_organization_admin_account" "this" {
  count = var.is_enabled && var.is_enabled_admin ? 1 : 0

  region           = local.region
  admin_account_id = var.admin_account_id
}

#--------------------------------------------------------------
# GuardDuty Detector
# - Use existing detector if available, otherwise create a new one.
# - Set create_detector = true when no detector exists in the target region.
#--------------------------------------------------------------
data "aws_guardduty_detector" "existing" {
  count = var.is_enabled && !var.create_detector ? 1 : 0
}

resource "aws_guardduty_detector" "this" {
  count = var.is_enabled && var.create_detector ? 1 : 0

  region                       = local.region
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = var.tags
}

locals {
  detector_id = var.is_enabled ? (
    var.create_detector ? aws_guardduty_detector.this[0].id : data.aws_guardduty_detector.existing[0].id
  ) : null
}

#--------------------------------------------------------------
# GuardDuty Organization Configuration
# - Configure organization-level settings for GuardDuty auto-enabling new accounts.
#--------------------------------------------------------------
resource "aws_guardduty_organization_configuration" "this" {
  count = var.is_enabled ? 1 : 0

  region                           = local.region
  auto_enable_organization_members = var.auto_enable_organization_members
  detector_id                      = local.detector_id

  depends_on = [aws_guardduty_organization_admin_account.this, aws_guardduty_detector.this]
}

#--------------------------------------------------------------
# GuardDuty Organization Configuration Features
# - Configure which GuardDuty features will automatically be turned on
#   for new members of the organization.
#--------------------------------------------------------------
resource "aws_guardduty_organization_configuration_feature" "this" {
  for_each = var.is_enabled ? var.features : {}

  region      = local.region
  detector_id = local.detector_id
  name        = each.key
  auto_enable = each.value.auto_enable

  dynamic "additional_configuration" {
    for_each = each.value.additional_configurations
    content {
      name        = additional_configuration.value.name
      auto_enable = additional_configuration.value.auto_enable
    }
  }

  depends_on = [aws_guardduty_organization_configuration.this]
}
