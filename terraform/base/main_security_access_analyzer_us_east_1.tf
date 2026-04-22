#--------------------------------------------------------------
# For Access Analyzer (us-east-1)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Manages an Access Analyzer Analyzer in us-east-1.
#--------------------------------------------------------------
module "aws_security_access_analyzer_us_east_1" {
  source     = "../../modules/aws/security/access_analyzer"
  is_enabled = local.is_enabled_us_east_1 && var.security_access_analyzer.is_enabled
  providers = {
    aws = aws.us-east-1
  }

  analyzer_name = "${var.name_prefix}${var.security_access_analyzer.aws_accessanalyzer_analyzer.analyzer_name}-us-east-1"
  type          = var.security_access_analyzer.aws_accessanalyzer_analyzer.type

  tags = var.tags
}
