#--------------------------------------------------------------
# Access Analyzer organization configuration (us-east-1)
# This configures the Access Analyzer settings for the entire
# AWS Organization to use a central model in us-east-1.
#--------------------------------------------------------------
module "access_analyzer_organization_us_east_1" {
  source     = "../../../modules/aws/security/access_analyzer"
  is_enabled = local.is_enabled_us_east_1 && var.access_analyzer_organization_us_east_1.is_enabled && local.is_delegated_admin.access_analyzer
  providers = {
    aws = aws.us-east-1
  }

  analyzer_name = "${var.name_prefix}${var.access_analyzer_organization_us_east_1.analyzer_name}-us-east-1"
  type          = "ORGANIZATION"
  region        = "us-east-1"

  tags = var.tags
}
