#--------------------------------------------------------------
# Amazon Inspector2 org-level configuration (us-east-1)
#--------------------------------------------------------------
module "inspector2_organization_us_east_1" {
  source     = "../../../modules/aws/security/inspector2_organization"
  is_enabled = local.is_enabled_us_east_1 && var.inspector2_organization_us_east_1.is_enabled && local.is_delegated_admin.inspector2
  providers = {
    aws = aws.us-east-1
  }
  # Disable delegated admin account configuration for Inspector2, because the management account is used as the delegated admin account.
  is_enabled_delegated_admin = false
  is_enabled_configuration   = var.inspector2_organization_us_east_1.is_enabled_configuration

  configuration              = var.inspector2_organization_us_east_1.configuration
  delegated_admin_account_id = data.aws_caller_identity.current.account_id
  enabler                    = var.inspector2_organization_us_east_1.enabler
}
