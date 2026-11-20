#--------------------------------------------------------------
# Security Hub organization configuration
# Central configuration can only be managed from the aggregation region (primary).
# Configuration policies take effect in the primary region and the linked regions only, so the linked regions are
# fixed to region.targets (not ALL_REGIONS: that includes disabled opt-in regions, which fails the policy association).
#--------------------------------------------------------------
module "securityhub_organization" {
  source = "../../../modules/aws/security/securityhub_organization"

  is_enabled = var.securityhub_organization.is_enabled && local.is_delegated_admin.securityhub
  region     = var.region.primary

  admin_account_id              = data.aws_caller_identity.current.account_id
  configuration_policy          = var.securityhub_organization.configuration_policy
  configuration_policy_name     = format("%s%s", var.name_prefix, var.securityhub_organization.configuration_policy_name)
  is_enabled_admin              = false
  is_enabled_finding_aggregator = var.securityhub_organization.is_enabled_finding_aggregator
  linked_regions                = [for r in var.region.targets : r if r != var.region.primary]
  target_id                     = var.securityhub_organization.target_id
}
