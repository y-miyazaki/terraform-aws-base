#--------------------------------------------------------------
# Provides a Resource Group.
#--------------------------------------------------------------
module "aws_recipes_resource_groups" {
  source         = "../modules/aws/recipes/resource_groups"
  name           = "${var.name_prefix}${lookup(var.resourcegroups_group, "name")}"
  description    = lookup(var.resourcegroups_group, "description", null)
  resource_query = lookup(var.resourcegroups_group, "resource_query")
  tags           = var.tags
}
