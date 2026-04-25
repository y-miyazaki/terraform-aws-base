#--------------------------------------------------------------
# Module: aws/security/access_analyzer
# Purpose: Create an AWS Access Analyzer to monitor external access to supported resource types.
#
# When type is "ORGANIZATION", checks if an analyzer already exists
# to avoid conflicts with manually or Control Tower created analyzers.
#--------------------------------------------------------------

#--------------------------------------------------------------
# Check if an ORGANIZATION-type analyzer already exists.
# Skips creation if one is found to avoid duplicate resource errors.
# This check is only performed when type is "ORGANIZATION".
#
# Verification command:
#   aws accessanalyzer list-analyzers --type ORGANIZATION
#--------------------------------------------------------------
data "external" "organization_analyzer_exists" {
  count   = var.is_enabled && var.type == "ORGANIZATION" ? 1 : 0
  program = ["bash", "${path.module}/scripts/check_organization_analyzer.sh"]
  query = {
    analyzer_name = var.analyzer_name
    region        = var.region
  }
}

locals {
  organization_analyzer_exists = try(data.external.organization_analyzer_exists[0].result.exists, "false") == "true"
  create                       = var.is_enabled && !(var.type == "ORGANIZATION" && local.organization_analyzer_exists)
}

#--------------------------------------------------------------
# Manages an Access Analyzer Analyzer.
#--------------------------------------------------------------
resource "aws_accessanalyzer_analyzer" "this" {
  count = local.create ? 1 : 0

  analyzer_name = var.analyzer_name
  type          = var.type

  tags = var.tags
}
