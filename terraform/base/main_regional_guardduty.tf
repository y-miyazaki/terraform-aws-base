#############################################################################
# Security: GuardDuty (Multi-Region)
#############################################################################
# GuardDuty deployment across multiple regions using AWS Provider v6+ region attribute
# This leverages the region attribute available on aws_guardduty_* resources

module "guardduty" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/guardduty"

  is_enabled = (
    var.security_guardduty.is_enabled &&
    !local.control_tower_managed_services.guardduty
  )
  region = each.value

  aws_guardduty_detector = try(var.security_guardduty.aws_guardduty_detector, {})
  aws_guardduty_member   = try(var.security_guardduty.aws_guardduty_member, {})

  tags = var.tags
}
