output "pattern" {
  description = "The metric filter pattern. Exposed so that callers and tests can inspect it."
  value       = local.pattern
}

output "alarm_name" {
  description = "The name of the alarm. Null when the module is disabled."
  value       = one(aws_cloudwatch_metric_alarm.this[*].alarm_name)
}

output "log_group_name" {
  description = "The log group the metric filter reads. Null when the module is disabled."
  value       = one(aws_cloudwatch_log_metric_filter.this[*].log_group_name)
}
