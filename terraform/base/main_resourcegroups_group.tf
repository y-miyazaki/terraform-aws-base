#--------------------------------------------------------------
# Provides a Resource Group.
#--------------------------------------------------------------
module "aws_resource_groups" {
  source         = "../../modules/aws/resource_groups"
  name           = "${var.name_prefix}${var.resourcegroups_group.name}"
  description    = var.resourcegroups_group.description
  resource_query = var.resourcegroups_group.resource_query
  tags           = var.tags
}
