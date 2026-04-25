#--------------------------------------------------------------
# Access Analyzer organization configuration
# This configures the Access Analyzer settings for the entire
# AWS Organization to use a central model.
#--------------------------------------------------------------
module "access_analyzer_organization" {
  source     = "../../../modules/aws/security/access_analyzer"
  is_enabled = var.access_analyzer_organization.is_enabled && local.is_delegated_admin.access_analyzer

  analyzer_name = "${var.name_prefix}${var.access_analyzer_organization.analyzer_name}"
  region        = var.region
  type          = "ORGANIZATION"

  tags = var.tags
}
