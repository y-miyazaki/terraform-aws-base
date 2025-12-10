#--------------------------------------------------------------
# Outputs
#--------------------------------------------------------------
output "alarm_arns" {
  description = "Map of alarm ARNs by canary name and metric type"
  value = {
    http_2xx = {
      for k, v in aws_cloudwatch_metric_alarm.http_2xx : k => v.arn
    }
    http_4xx = {
      for k, v in aws_cloudwatch_metric_alarm.http_4xx : k => v.arn
    }
    http_5xx = {
      for k, v in aws_cloudwatch_metric_alarm.http_5xx : k => v.arn
    }
    duration = {
      for k, v in aws_cloudwatch_metric_alarm.duration : k => v.arn
    }
    duration_dry_run = {
      for k, v in aws_cloudwatch_metric_alarm.duration_dry_run : k => v.arn
    }
    failed = {
      for k, v in aws_cloudwatch_metric_alarm.failed : k => v.arn
    }
    failed_requests = {
      for k, v in aws_cloudwatch_metric_alarm.failed_requests : k => v.arn
    }
    success_percent = {
      for k, v in aws_cloudwatch_metric_alarm.success_percent : k => v.arn
    }
    success_percent_dry_run = {
      for k, v in aws_cloudwatch_metric_alarm.success_percent_dry_run : k => v.arn
    }
    success_percent_with_retries = {
      for k, v in aws_cloudwatch_metric_alarm.success_percent_with_retries : k => v.arn
    }
    visual_monitoring_success_percent = {
      for k, v in aws_cloudwatch_metric_alarm.visual_monitoring_success_percent : k => v.arn
    }
  }
}

output "alarm_arns_list" {
  description = "Flattened list of all alarm ARNs"
  value = compact(flatten([
    [for v in aws_cloudwatch_metric_alarm.http_2xx : v.arn],
    [for v in aws_cloudwatch_metric_alarm.http_4xx : v.arn],
    [for v in aws_cloudwatch_metric_alarm.http_5xx : v.arn],
    [for v in aws_cloudwatch_metric_alarm.duration : v.arn],
    [for v in aws_cloudwatch_metric_alarm.duration_dry_run : v.arn],
    [for v in aws_cloudwatch_metric_alarm.failed : v.arn],
    [for v in aws_cloudwatch_metric_alarm.failed_requests : v.arn],
    [for v in aws_cloudwatch_metric_alarm.success_percent : v.arn],
    [for v in aws_cloudwatch_metric_alarm.success_percent_dry_run : v.arn],
    [for v in aws_cloudwatch_metric_alarm.success_percent_with_retries : v.arn],
    [for v in aws_cloudwatch_metric_alarm.visual_monitoring_success_percent : v.arn]
  ]))
}

output "monitored_canaries" {
  description = "List of canary names being monitored"
  value       = keys(local.list)
}
