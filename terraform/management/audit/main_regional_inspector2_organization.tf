#--------------------------------------------------------------
# Amazon Inspector2 organization configuration
# Deployed to each region in var.region.targets.
# Accounts are limited to region.account_allowlist[<region>] when it is set;
# organization auto-enable configuration is skipped in those regions.
#--------------------------------------------------------------
module "inspector2_organization" {
  for_each = toset(var.region.targets)

  source = "../../../modules/aws/security/inspector2_organization"

  is_enabled = var.inspector2_organization.is_enabled && local.is_delegated_admin.inspector2
  region     = each.value

  configuration              = var.inspector2_organization.configuration
  delegated_admin_account_id = data.aws_caller_identity.current.account_id
  enabler                    = local.inspector2_enabler_by_region[each.value]
  is_enabled_configuration   = local.region_account_allowlist[each.value] == null ? var.inspector2_organization.is_enabled_configuration : false
  is_enabled_delegated_admin = false
}
