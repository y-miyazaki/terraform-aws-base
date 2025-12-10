#--------------------------------------------------------------
# Module: aws/security/access_analyzer
# Purpose: Create an AWS Access Analyzer to monitor external access to supported resource types.
# Notes: Supports analyzer type variable; future improvement: add validation for analyzer name length/pattern.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Manages an Access Analyzer Analyzer. More information can be found in the Access Analyzer User Guide.
#--------------------------------------------------------------
resource "aws_accessanalyzer_analyzer" "this" {
  count = var.is_enabled ? 1 : 0

  analyzer_name = var.analyzer_name
  type          = var.type

  tags = var.tags
}
