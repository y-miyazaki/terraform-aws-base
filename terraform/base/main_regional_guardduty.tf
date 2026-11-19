#--------------------------------------------------------------
# Regional deployment of AWS GuardDuty
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# using AWS Provider v6+ region attribute.
# Not created when GuardDuty is managed by Control Tower / the organization
# (control_tower.managed_services.guardduty).

module "guardduty" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/guardduty"

  is_enabled = (
    var.security_guardduty.is_enabled &&
    !local.control_tower_managed_services.guardduty
  )
  region = each.value

  aws_guardduty_detector         = var.security_guardduty.aws_guardduty_detector
  aws_guardduty_detector_feature = var.security_guardduty.aws_guardduty_detector_feature
  aws_guardduty_member           = var.security_guardduty.aws_guardduty_member
  master_account_id              = lookup(var.security_guardduty.master_account_ids, each.value, null)

  tags = var.tags
}
