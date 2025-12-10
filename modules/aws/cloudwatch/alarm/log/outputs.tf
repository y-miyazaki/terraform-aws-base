#--------------------------------------------------------------
# module outputs
# Purpose: Expose created metric filter and alarm identifiers
#--------------------------------------------------------------
output "metric_filter_names" {
  description = "List of created CloudWatch Log Metric Filter names."
  value       = [for v in aws_cloudwatch_log_metric_filter.this : v.name]
}

output "metric_alarm_names" {
  description = "List of created CloudWatch Metric Alarm names."
  value       = [for v in aws_cloudwatch_metric_alarm.this : v.alarm_name]
}

output "metric_alarm_arns" {
  description = "List of created CloudWatch Metric Alarm ARNs."
  value       = [for v in aws_cloudwatch_metric_alarm.this : v.arn]
}
