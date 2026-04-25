#--------------------------------------------------------------
# GuardDuty organization configuration
# This configures the GuardDuty settings for the entire
# AWS Organization to use a central model.
#--------------------------------------------------------------
module "guardduty_organization" {
  source     = "../../../modules/aws/security/guardduty_organization"
  is_enabled = var.guardduty_organization.is_enabled && local.is_delegated_admin.guardduty
  # GuardDuty organization admin account designation is always disabled, because the management account is used as the admin account.
  is_enabled_admin = false
  # Set to true to create a new GuardDuty detector if no detector exists in this region.
  create_detector = try(var.guardduty_organization.create_detector, false)

  admin_account_id                 = data.aws_caller_identity.current.account_id
  auto_enable_organization_members = var.guardduty_organization.auto_enable_organization_members
  features                         = var.guardduty_organization.features

  tags = var.tags
}
