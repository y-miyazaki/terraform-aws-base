#--------------------------------------------------------------
# Module: aws/_internal/auto_discovery_filter
# Purpose: Provide common auto-discovery filtering logic with null safety and include/exclude patterns.
# Notes: Internal helper module for metric and CloudWatch modules; not intended for direct use.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
  # Apply null safety to source list
  safe_source_list = var.source_list != null ? var.source_list : []

  # Apply include/exclude filter with null checks
  filtered_list = var.is_enabled && var.create_auto ? [
    for v in local.safe_source_list : v
    if v != null && v != "" && (
      (length(var.include_list) == 0 || anytrue([for il in var.include_list : strcontains(v, il)]))
      && !anytrue([for el in var.exclude_list : strcontains(v, el)])
    )
  ] : []

  # Apply null safety to manual dimensions
  safe_manual_dimensions = var.manual_dimensions != null ? var.manual_dimensions : []
}
