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
  tags = var.tags
}
