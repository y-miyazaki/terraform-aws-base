#--------------------------------------------------------------
# Provides a Resource Group.
#--------------------------------------------------------------
module "aws_resource_groups" {
  source     = "../../modules/aws/resource_groups"
  is_enabled = var.resource_groups.is_enabled

  name        = format("%stags-resource-groups", var.name_prefix)
  description = "Resource group base for resources tagged with all tags"

  # Build a single resource_query from all tags. We assume caller will not
  # provide use_tags/resource_query entries — this keeps the caller simple and
  # predictable.
  resource_query = [
    {
      query = jsonencode({
        ResourceTypeFilters = ["AWS::AllSupported"],
        TagFilters = [for k, v in var.tags : {
          Key    = k
          Values = [tostring(v)]
        } if v != null && tostring(v) != ""]
      })
    }
  ]

  tags = var.tags
}
