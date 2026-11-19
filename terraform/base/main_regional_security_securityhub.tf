#--------------------------------------------------------------
# Regional deployment of AWS Security Hub
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# to enable centralized security findings across regions.
# Not created when Security Hub is managed by Control Tower / the organization
# (control_tower.managed_services.securityhub).

module "aws_security_securityhub" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/securityhub"

  is_enabled = (
    var.security_securityhub.is_enabled &&
    !local.control_tower_managed_services.securityhub
  )
  region = each.value

  auto_enable_controls                  = var.security_securityhub.auto_enable_controls
  aws_securityhub_action_target         = var.security_securityhub.aws_securityhub_action_target
  aws_securityhub_member                = var.security_securityhub.aws_securityhub_member
  aws_securityhub_product_subscription  = var.security_securityhub.aws_securityhub_product_subscription
  cis_aws_foundations_benchmark_version = var.security_securityhub.cis_aws_foundations_benchmark_version
  enable_default_standards              = var.security_securityhub.enable_default_standards
  enabled_cis_aws_foundations_benchmark = var.security_securityhub.enabled_cis_aws_foundations_benchmark
  enabled_pci_dss                       = var.security_securityhub.enabled_pci_dss
  pci_dss_version                       = var.security_securityhub.pci_dss_version
}
