#--------------------------------------------------------------
# Manages an Access Analyzer Analyzer. More information can be found in the Access Analyzer User Guide.
#--------------------------------------------------------------
module "aws_recipes_security_access_analyzer" {
  source        = "../modules/aws/recipes/security/access_analyzer"
  analyzer_name = "${var.name_prefix}${lookup(var.security_access_analyzer.aws_accessanalyzer_analyzer, "analyzer_name")}"
  type          = lookup(var.security_access_analyzer.aws_accessanalyzer_analyzer, "type")
  tags          = var.tags
}
