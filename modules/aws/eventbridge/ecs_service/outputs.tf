#--------------------------------------------------------------
# module outputs
#--------------------------------------------------------------
output "schedules" {
  description = "Map of schedules being managed"
  value       = local.schedules
}

output "start_schedule_arns" {
  description = "ARNs of start schedules"
  value       = { for k, v in aws_scheduler_schedule.start : k => v.arn }
}

output "stop_schedule_arns" {
  description = "ARNs of stop schedules"
  value       = { for k, v in aws_scheduler_schedule.stop : k => v.arn }
}
# Debug outputs from scheduler_helper
output "debug_scheduler_helper_schedule_expression_start" {
  description = "Debug: scheduler_helper's var.schedule_expression_start"
  value       = module.scheduler_helper.debug_schedule_expression_start
}

output "debug_scheduler_helper_schedule_expression_stop" {
  description = "Debug: scheduler_helper's var.schedule_expression_stop"
  value       = module.scheduler_helper.debug_schedule_expression_stop
}

output "debug_scheduler_helper_manual_schedules_with_defaults" {
  description = "Debug: scheduler_helper's manual_schedules_with_defaults"
  value       = module.scheduler_helper.debug_manual_schedules_with_defaults
}
