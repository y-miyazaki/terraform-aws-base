#--------------------------------------------------------------
# Central Security Hub organization configuration (us-east-1)
# This configures the Security Hub settings for the entire
# AWS Organization to use a central model in us-east-1.
#--------------------------------------------------------------
module "securityhub_organization_us_east_1" {
  source     = "../../../modules/aws/security/securityhub_organization"
  is_enabled = local.is_enabled_us_east_1 && var.securityhub_organization_us_east_1.is_enabled && local.is_delegated_admin.securityhub
  providers = {
    aws = aws.us-east-1
  }
  # Security Hub organization admin account designation is always disabled, because the management account is used as the admin account.
  is_enabled_admin              = false
  is_enabled_finding_aggregator = var.securityhub_organization_us_east_1.is_enabled_finding_aggregator

  admin_account_id          = data.aws_caller_identity.current.account_id
  configuration_policy      = var.securityhub_organization_us_east_1.configuration_policy
  configuration_policy_name = format("%s%s", var.name_prefix, var.securityhub_organization_us_east_1.configuration_policy_name)
  linking_mode              = var.securityhub_organization_us_east_1.linking_mode
  target_id                 = var.securityhub_organization_us_east_1.target_id
}
