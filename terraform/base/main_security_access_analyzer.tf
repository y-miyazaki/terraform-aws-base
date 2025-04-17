#--------------------------------------------------------------
# For Access Analyzer
#--------------------------------------------------------------
#--------------------------------------------------------------
# Manages an Access Analyzer Analyzer. More information can be found in the Access Analyzer User Guide.
#--------------------------------------------------------------
module "aws_security_access_analyzer" {
  source        = "../../modules/aws/security/access_analyzer"
  is_enabled    = var.security_access_analyzer.is_enabled
  analyzer_name = "${var.name_prefix}${var.security_access_analyzer.aws_accessanalyzer_analyzer.analyzer_name}"
  type          = var.security_access_analyzer.aws_accessanalyzer_analyzer.type
  tags          = var.tags
}
