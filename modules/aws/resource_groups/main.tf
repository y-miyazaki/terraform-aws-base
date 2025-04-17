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
# Provides a Resource Group.
#--------------------------------------------------------------
resource "aws_resourcegroups_group" "this" {
  name        = var.name
  description = var.description
  dynamic "resource_query" {
    for_each = var.resource_query
    content {
      query = lookup(resource_query.value, "query", null)
      type  = lookup(resource_query.value, "type", null)
    }
  }
  tags = local.tags
}
