#--------------------------------------------------------------
# GuardDuty organization configuration (us-east-1)
# This configures the GuardDuty settings for the entire
# AWS Organization to use a central model in us-east-1.
#--------------------------------------------------------------
module "guardduty_organization_us_east_1" {
  source     = "../../../modules/aws/security/guardduty_organization"
  is_enabled = local.is_enabled_us_east_1 && var.guardduty_organization_us_east_1.is_enabled && local.is_delegated_admin.guardduty
  providers = {
    aws = aws.us-east-1
  }
  # GuardDuty organization admin account designation is always disabled, because the management account is used as the admin account.
  is_enabled_admin = false
  # Create detector since Control Tower does not manage GuardDuty detector creation.
  create_detector = var.guardduty_organization_us_east_1.create_detector

  admin_account_id                 = data.aws_caller_identity.current.account_id
  auto_enable_organization_members = var.guardduty_organization_us_east_1.auto_enable_organization_members
  features                         = var.guardduty_organization_us_east_1.features

  tags = var.tags
}
