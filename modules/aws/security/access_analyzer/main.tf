#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Manages an Access Analyzer Analyzer. More information can be found in the Access Analyzer User Guide.
#--------------------------------------------------------------
resource "aws_accessanalyzer_analyzer" "this" {
  count         = var.is_enabled ? 1 : 0
  analyzer_name = var.analyzer_name
  tags          = local.tags
  type          = var.type
}
