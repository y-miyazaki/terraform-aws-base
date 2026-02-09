#--------------------------------------------------------------
# GuardDuty organization configuration
# This configures the GuardDuty settings for the entire
# AWS Organization to use a central model.
#--------------------------------------------------------------
module "guardduty_organization" {
  source     = "../../../modules/aws/security/guardduty_organization"
  is_enabled = var.guardduty_organization.is_enabled
  # GuardDuty organization admin account designation is always disabled, because the management account is used as the admin account.
  is_enabled_admin = false

  admin_account_id                 = data.aws_caller_identity.current.account_id
  auto_enable_organization_members = var.guardduty_organization.auto_enable_organization_members
  features                         = var.guardduty_organization.features
}
