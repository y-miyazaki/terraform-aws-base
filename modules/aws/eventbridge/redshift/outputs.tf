#--------------------------------------------------------------
# module outputs
#--------------------------------------------------------------
output "schedule_arns_pause" {
  description = "Map of schedule ARNs for stop/pause operations. Key is the cluster identifier."
  value = {
    for k, v in aws_scheduler_schedule.pause : k => v.arn
  }
}

output "schedule_arns_resume" {
  description = "Map of schedule ARNs for start/resume operations. Key is the cluster identifier."
  value = {
    for k, v in aws_scheduler_schedule.resume : k => v.arn
  }
}

output "schedules" {
  description = "Map of all configured schedules after filtering and merging."
  value       = local.schedules
}
