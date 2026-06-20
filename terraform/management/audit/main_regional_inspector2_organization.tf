#--------------------------------------------------------------
# Amazon Inspector2 organization configuration
# Deployed to each region in var.region.targets.
#--------------------------------------------------------------
module "inspector2_organization" {
  for_each = toset(var.region.targets)

  source = "../../../modules/aws/security/inspector2_organization"

  is_enabled                 = var.inspector2_organization.is_enabled && local.is_delegated_admin.inspector2
  is_enabled_delegated_admin = false
  is_enabled_configuration   = var.inspector2_organization.is_enabled_configuration
  region                     = each.value

  configuration              = var.inspector2_organization.configuration
  delegated_admin_account_id = data.aws_caller_identity.current.account_id
  enabler                    = var.inspector2_organization.enabler
}
