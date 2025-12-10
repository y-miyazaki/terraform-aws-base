#--------------------------------------------------------------
# Module: aws/metric/synthetics_canary
# Purpose: Provide CloudWatch metric alarms for Synthetics Canary success rates, duration, and HTTP status metrics with optional auto-discovery.
# Notes: Supports multiple canaries via auto-discovery or manual dimensions; unified tagging applied; uses for_each for stable resource references.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "filter" {
  source     = "../../_internal/auto_discovery_filter"
  is_enabled = var.is_enabled

  create_auto       = var.create_auto_dimensions
  source_list       = var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list) : []
  include_list      = var.auto_dimensions_include_list
  exclude_list      = var.auto_dimensions_exclude_list
  manual_dimensions = var.dimensions
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries_metrics.html"

  # Use filtered results from helper module
  auto_dimensions = module.filter.filtered_list
  safe_dimensions = module.filter.safe_manual_dimensions

  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : v => {
      name = v
      dimensions = {
        "CanaryName" = v
      }
    }
    } : {
    for v in local.safe_dimensions : v.CanaryName => {
      name       = v.CanaryName
      dimensions = v
    } if v != null && try(v.CanaryName, null) != null && v.CanaryName != ""
  }
}

#--------------------------------------------------------------
# For 2xx
# Monitors count of HTTP 2xx responses.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "http_2xx" {
  for_each = var.is_enabled && var.threshold.enabled_2xx ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-2xx"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  namespace                 = "CloudWatchSynthetics"
  metric_name               = "2xx"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.http_2xx
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary 2xx responses>(< ${var.threshold.http_2xx})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For 4xx
# Monitors count of HTTP 4xx client errors.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "http_4xx" {
  for_each = var.is_enabled && var.threshold.enabled_4xx ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-4xx"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "CloudWatchSynthetics"
  metric_name               = "4xx"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.http_4xx
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary 4xx errors>(>= ${var.threshold.http_4xx})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For 5xx
# Monitors count of HTTP 5xx server errors.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "http_5xx" {
  for_each = var.is_enabled && var.threshold.enabled_5xx ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-5xx"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "CloudWatchSynthetics"
  metric_name               = "5xx"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.http_5xx
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary 5xx errors>(>= ${var.threshold.http_5xx})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For Duration
# Monitors execution time of canary runs.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "duration" {
  for_each = var.is_enabled && var.threshold.enabled_duration ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-duration"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "CloudWatchSynthetics"
  metric_name               = "Duration"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.duration
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary duration>(>= ${var.threshold.duration}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DurationDryRun
# Monitors execution time of dry run canary executions.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "duration_dry_run" {
  for_each = var.is_enabled && var.threshold.enabled_duration_dry_run ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-duration-dry-run"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "CloudWatchSynthetics"
  metric_name               = "DurationDryRun"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.duration_dry_run
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary DryRun duration>(>= ${var.threshold.duration_dry_run}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For Failed
# Monitors count of failed canary executions.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "failed" {
  for_each = var.is_enabled && var.threshold.enabled_failed ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "CloudWatchSynthetics"
  metric_name               = "Failed"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.failed
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary failed count>(>= ${var.threshold.failed})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For Failed requests
# Monitors count of failed HTTP requests with no response.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "failed_requests" {
  for_each = var.is_enabled && var.threshold.enabled_failed_requests ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-failed-requests"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "CloudWatchSynthetics"
  metric_name               = "Failed requests"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.failed_requests
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary failed requests>(>= ${var.threshold.failed_requests})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For SuccessPercent
# Monitors percentage of successful canary runs.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "success_percent" {
  for_each = var.is_enabled && var.threshold.enabled_success_percent ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-success-percent"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "CloudWatchSynthetics"
  metric_name               = "SuccessPercent"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.success_percent
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary success percent>(<= ${var.threshold.success_percent}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For SuccessPercentDryRun
# Monitors percentage of successful dry run executions.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "success_percent_dry_run" {
  for_each = var.is_enabled && var.threshold.enabled_success_percent_dry_run ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-success-percent-dry-run"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "CloudWatchSynthetics"
  metric_name               = "SuccessPercentDryRun"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.success_percent_dry_run
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary DryRun success percent>(<= ${var.threshold.success_percent_dry_run}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For SuccessPercentWithRetries
# Monitors percentage of successful canary runs after retries.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "success_percent_with_retries" {
  for_each = var.is_enabled && var.threshold.enabled_success_percent_with_retries ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-success-percent-with-retries"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "CloudWatchSynthetics"
  metric_name               = "SuccessPercentWithRetries"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.success_percent_with_retries
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary success percent with retries>(<= ${var.threshold.success_percent_with_retries}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For VisualMonitoringSuccessPercent
# Monitors percentage of visual comparisons matching baseline.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "visual_monitoring_success_percent" {
  for_each = var.is_enabled && var.threshold.enabled_visual_monitoring_success_percent ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-visual-monitoring-success-percent"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "CloudWatchSynthetics"
  metric_name               = "VisualMonitoringSuccessPercent"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.visual_monitoring_success_percent
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary visual monitoring success percent>(<= ${var.threshold.visual_monitoring_success_percent}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
