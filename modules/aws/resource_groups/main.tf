#--------------------------------------------------------------
# Module: aws/resource_groups
# Purpose: Create AWS Resource Groups with tag-based or CloudFormation-stack queries per region.
# Notes: Assumes resource_query passed directly; future improvement: add validation ensuring only supported query types provided.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

#--------------------------------------------------------------
# Provides a Resource Group.
#--------------------------------------------------------------
resource "aws_resourcegroups_group" "this" {
  count = var.is_enabled ? 1 : 0

  region      = local.region
  description = var.description
  name        = var.name

  dynamic "resource_query" {
    for_each = var.resource_query

    content {
      query = try(resource_query.value.query, null)
      type  = try(resource_query.value.type, null)
    }
  }

  tags = var.tags
}
