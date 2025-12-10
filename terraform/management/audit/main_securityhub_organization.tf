#--------------------------------------------------------------
# Central Security Hub organization configuration
# This configures the Security Hub settings for the entire
# AWS Organization to use a central model.
#--------------------------------------------------------------
module "securityhub_organization" {
  source     = "../../../modules/aws/security/securityhub_organization"
  is_enabled = var.securityhub_organization.is_enabled
  # Security Hub organization admin account designation is always disabled, because the management account is used as the admin account.
  is_enabled_admin              = false
  is_enabled_finding_aggregator = var.securityhub_organization.is_enabled_finding_aggregator

  admin_account_id          = data.aws_caller_identity.current.account_id
  configuration_policy      = var.securityhub_organization.configuration_policy
  configuration_policy_name = format("%s%s", var.name_prefix, var.securityhub_organization.configuration_policy_name)
  linking_mode              = var.securityhub_organization.linking_mode
  target_id                 = var.securityhub_organization.target_id
}
