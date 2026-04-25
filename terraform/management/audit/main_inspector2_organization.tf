#--------------------------------------------------------------
# Amazon Inspector2 org-level configuration
#--------------------------------------------------------------
module "inspector2_organization" {
  source     = "../../../modules/aws/security/inspector2_organization"
  is_enabled = try(var.inspector2_organization.is_enabled, false) && local.is_delegated_admin.inspector2
  # Disable delegated admin account configuration for Inspector2, because the management account is used as the delegated admin account.
  is_enabled_delegated_admin = false
  is_enabled_configuration   = var.inspector2_organization.is_enabled_configuration

  configuration              = var.inspector2_organization.configuration
  delegated_admin_account_id = data.aws_caller_identity.current.account_id
  enabler                    = var.inspector2_organization.enabler
}
