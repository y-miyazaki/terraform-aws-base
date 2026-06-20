#--------------------------------------------------------------
# Module: aws/_internal/eventbridge_scheduler_helper
# Purpose: Provide common EventBridge Scheduler helper logic including:
#          - Filtering with null safety and include/exclude patterns
#          - Schedule map generation for for_each usage
# Notes: Internal helper module for eventbridge/scheduler modules; not intended for direct use.
#        Follows metric_helper pattern: resource-specific parsing is done by caller.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

#--------------------------------------------------------------
# Locals - Core filtering and schedule generation logic
#--------------------------------------------------------------
locals {
  # Mode determination - use local variables to avoid repetition
  should_use_auto   = var.is_enabled && var.create_auto_schedules
  should_use_manual = var.is_enabled && !var.create_auto_schedules

  # Apply include/exclude filter with null checks
  # Filter by checking the primary_key value in each schedule object
  filtered_schedules = local.should_use_auto ? {
    for k, v in var.source_schedules : k => v
    if v != null && try(v[var.primary_key], null) != null && v[var.primary_key] != "" && (
      (length(var.auto_schedules_include_list) == 0 || anytrue([for pattern in var.auto_schedules_include_list : strcontains(v[var.primary_key], pattern)])) &&
      !anytrue([for pattern in var.auto_schedules_exclude_list : strcontains(v[var.primary_key], pattern)])
    )
  } : {}

  # Add default schedule expressions to manual schedules when omitted
  manual_schedules_with_defaults = {
    for k, v in var.manual_schedules :
    k => merge(
      v,
      {
        # Fallback: use module default if key absent or explicitly null
        schedule_expression_start = try(coalesce(v.schedule_expression_start, var.schedule_expression_start), var.schedule_expression_start)
        schedule_expression_stop  = try(coalesce(v.schedule_expression_stop, var.schedule_expression_stop), var.schedule_expression_stop)
      }
    )
  }

  # Add default schedule expressions to auto-discovered schedules when omitted
  auto_schedules_with_defaults = {
    for k, v in local.filtered_schedules :
    k => merge(
      v,
      {
        schedule_expression_start = try(coalesce(v.schedule_expression_start, var.schedule_expression_start), var.schedule_expression_start)
        schedule_expression_stop  = try(coalesce(v.schedule_expression_stop, var.schedule_expression_stop), var.schedule_expression_stop)
      }
    )
  }

  # Final schedules: auto-discovered or manual (empty if disabled)
  schedules = local.should_use_auto ? local.auto_schedules_with_defaults : (local.should_use_manual ? local.manual_schedules_with_defaults : {})
}
