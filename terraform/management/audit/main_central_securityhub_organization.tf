#--------------------------------------------------------------
# Security Hub organization configuration
# Central configuration can only be managed from the aggregation region (primary).
#--------------------------------------------------------------
module "securityhub_organization" {
  source = "../../../modules/aws/security/securityhub_organization"

  is_enabled                    = var.securityhub_organization.is_enabled && local.is_delegated_admin.securityhub
  is_enabled_admin              = false
  is_enabled_finding_aggregator = var.securityhub_organization.is_enabled_finding_aggregator
  region                        = var.region.primary

  admin_account_id          = data.aws_caller_identity.current.account_id
  configuration_policy      = var.securityhub_organization.configuration_policy
  configuration_policy_name = format("%s%s", var.name_prefix, var.securityhub_organization.configuration_policy_name)
  linking_mode              = var.securityhub_organization.linking_mode
  target_id                 = var.securityhub_organization.target_id
}
