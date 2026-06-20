#--------------------------------------------------------------
# Access Analyzer organization configuration
# Deployed to each region in var.region.targets.
#--------------------------------------------------------------
module "access_analyzer_organization" {
  for_each = toset(var.region.targets)

  source = "../../../modules/aws/security/access_analyzer"

  is_enabled = var.access_analyzer_organization.is_enabled && local.is_delegated_admin.access_analyzer
  region     = each.value

  analyzer_name = "${var.name_prefix}${var.access_analyzer_organization.analyzer_name}-${each.value}"
  type          = "ORGANIZATION"

  tags = var.tags
}
