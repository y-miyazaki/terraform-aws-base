#--------------------------------------------------------------
# Module: aws/_internal/metric_helper
# Purpose: Provide common metric module helper logic including:
#          - Auto-discovery filtering with null safety and include/exclude patterns
#          - Dimension list generation for for_each usage
#          - Threshold override merging (base + per-resource overrides)
# Notes: Internal helper module for metric modules; not intended for direct use.
#        Replaces auto_discovery_filter with additional threshold_override support.
#--------------------------------------------------------------

#--------------------------------------------------------------
# Locals - Core filtering and list generation logic
#--------------------------------------------------------------
locals {
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

  # Generate the list map for for_each usage
  # Key is the dimension value (e.g., queue name), value contains name and dimensions map
  list = var.create_auto ? {
    for v in local.filtered_list : v => {
      name = v
      dimensions = {
        (var.dimension_key) = v
      }
    }
    } : {
    for v in local.safe_manual_dimensions : v[var.dimension_key] => {
      name       = v[var.dimension_key]
      dimensions = v
    } if v != null && try(v[var.dimension_key], null) != null && v[var.dimension_key] != ""
  }

  # Get all resource keys for threshold override calculation
  resource_keys = keys(local.list)

  # Safe threshold_override (ensure it's a map)
  safe_threshold_override = var.threshold_override != null ? var.threshold_override : {}
}

#--------------------------------------------------------------
# Locals - Threshold override merging logic
# For each resource key, merge base_threshold with any overrides.
# Uses coalesce pattern: override value if not null, otherwise base value.
#--------------------------------------------------------------
locals {
  # Generate effective thresholds for each resource
  # Each attribute in threshold_override[key] will override the corresponding base_threshold attribute
  effective_thresholds = {
    for key in local.resource_keys : key => merge(
      var.base_threshold,
      # Only merge non-null values from override
      {
        for attr, value in try(local.safe_threshold_override[key], {}) :
        attr => value
        if value != null
      }
    )
  }
}
