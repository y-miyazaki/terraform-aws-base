#--------------------------------------------------------------
# GuardDuty organization configuration
# Deployed to each region in var.region.targets.
#--------------------------------------------------------------
module "guardduty_organization" {
  for_each = toset(var.region.targets)

  source = "../../../modules/aws/security/guardduty_organization"

  is_enabled       = var.guardduty_organization.is_enabled && local.is_delegated_admin.guardduty
  is_enabled_admin = false
  create_detector  = var.guardduty_organization.create_detector
  region           = each.value

  admin_account_id                 = data.aws_caller_identity.current.account_id
  auto_enable_organization_members = var.guardduty_organization.auto_enable_organization_members
  features                         = var.guardduty_organization.features

  tags = var.tags
}
