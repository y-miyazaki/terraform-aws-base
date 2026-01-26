#--------------------------------------------------------------
# Outputs for eventbridge_scheduler_helper internal module
#--------------------------------------------------------------

output "schedules" {
  description = "Map of schedules for for_each usage. Key is unique identifier, value contains schedule configuration."
  value       = local.schedules
}

output "should_use_auto" {
  description = "Whether to use auto-discovered schedules (true) or manual (false)"
  value       = var.is_enabled && var.create_auto_schedules
}

output "schedule_count" {
  description = "Number of schedules after filtering"
  value       = length(local.schedules)
}
# Debug outputs
output "debug_schedule_expression_start" {
  description = "Debug: var.schedule_expression_start value"
  value       = var.schedule_expression_start
}

output "debug_schedule_expression_stop" {
  description = "Debug: var.schedule_expression_stop value"
  value       = var.schedule_expression_stop
}

output "debug_manual_schedules_with_defaults" {
  description = "Debug: manual_schedules_with_defaults"
  value       = local.manual_schedules_with_defaults
}
