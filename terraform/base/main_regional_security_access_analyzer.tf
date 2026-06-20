# Regional deployment of AWS Access Analyzer
# This module is deployed to each region in var.region.targets
# to enable cross-region security posture monitoring.

module "aws_security_access_analyzer" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/access_analyzer"

  is_enabled = try(var.security_access_analyzer.is_enabled, false)
  region     = each.value

  analyzer_name = try(var.security_access_analyzer.analyzer_name, "${var.name_prefix}analyzer-${each.value}")
  tags          = var.tags
  type          = try(var.security_access_analyzer.type, "ACCOUNT")
}
