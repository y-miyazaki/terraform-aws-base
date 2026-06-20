#--------------------------------------------------------------
# Regional deployment of AWS Resource Groups
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# to create resource groups per region.

module "aws_resourcegroups_group" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/resource_groups"

  is_enabled = try(var.resource_groups.is_enabled, true)
  region     = each.value

  name        = try(var.resource_groups.name, "${var.name_prefix}resource-group-${each.value}")
  description = try(var.resource_groups.description, "Resource group for region ${each.value}")
  resource_query = try(var.resource_groups.resource_query, [
    {
      query = jsonencode({
        ResourceTypeFilters = ["AWS::AllSupported"],
        TagFilters = [for k, v in var.tags : {
          Key    = k
          Values = [tostring(v)]
        } if v != null && tostring(v) != ""]
      })
      type = "TAG_FILTERS_1_0"
    }
  ])
  tags = var.tags
}
