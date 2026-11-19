#--------------------------------------------------------------
# Regional deployment of AWS Access Analyzer
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# to enable cross-region security posture monitoring.
# Not created when Access Analyzer is managed by Control Tower / the organization
# (control_tower.managed_services.access_analyzer).

module "aws_security_access_analyzer" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/access_analyzer"

  is_enabled = (
    var.security_access_analyzer.is_enabled &&
    !local.control_tower_managed_services.access_analyzer
  )
  region = each.value

  analyzer_name = "${var.name_prefix}${var.security_access_analyzer.aws_accessanalyzer_analyzer.analyzer_name}-${each.value}"
  type          = var.security_access_analyzer.aws_accessanalyzer_analyzer.type

  tags = var.tags
}
