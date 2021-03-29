#--------------------------------------------------------------
# Manages an Access Analyzer Analyzer. More information can be found in the Access Analyzer User Guide.
#--------------------------------------------------------------
resource "aws_accessanalyzer_analyzer" "this" {
  count         = var.is_enabled ? 1 : 0
  analyzer_name = var.analyzer_name
  tags          = var.tags
  type          = var.type
}
