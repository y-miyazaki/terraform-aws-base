#--------------------------------------------------------------
# Module: aws/metric/synthetics_canary
# Purpose: Provide CloudWatch metric alarms for Synthetics Canary success rates, duration, and HTTP status metrics with optional auto-discovery.
# Notes: Supports multiple canaries via auto-discovery or manual dimensions; unified tagging applied; uses for_each for stable resource references.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

module "helper" {
  source = "../../_internal/metric_helper"

  is_enabled = var.is_enabled
  region     = local.region

  base_threshold     = var.threshold
  create_auto        = var.create_auto_dimensions
  dimension_key      = "CanaryName"
  exclude_list       = var.auto_dimensions_exclude_list
  include_list       = var.auto_dimensions_include_list
  manual_dimensions  = var.dimensions
  source_list        = var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list) : []
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries_metrics.html"

  # Use filtered results from helper module
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
}

#--------------------------------------------------------------
# For 2xx
# Monitors count of HTTP 2xx responses.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "http_2xx" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].http_2xx.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary 2xx responses>(< ${local.effective_thresholds[each.key].http_2xx.value})."
  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-2xx"
  comparison_operator       = "LessThanThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].http_2xx.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].http_2xx.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "2xx"
  namespace                 = "CloudWatchSynthetics"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].http_2xx.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For 4xx
# Monitors count of HTTP 4xx client errors.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "http_4xx" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].http_4xx.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary 4xx errors>(>= ${local.effective_thresholds[each.key].http_4xx.value})."
  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-4xx"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].http_4xx.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].http_4xx.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "4xx"
  namespace                 = "CloudWatchSynthetics"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].http_4xx.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For 5xx
# Monitors count of HTTP 5xx server errors.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "http_5xx" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].http_5xx.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary 5xx errors>(>= ${local.effective_thresholds[each.key].http_5xx.value})."
  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-5xx"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].http_5xx.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].http_5xx.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "5xx"
  namespace                 = "CloudWatchSynthetics"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].http_5xx.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For Duration
# Monitors execution time of canary runs.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "duration" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].duration.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary duration>(>= ${local.effective_thresholds[each.key].duration.value}ms)."
  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-duration"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].duration.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].duration.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Duration"
  namespace                 = "CloudWatchSynthetics"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].duration.value
  treat_missing_data        = "notBreaching"
  unit                      = "Milliseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For DurationDryRun
# Monitors execution time of dry run canary executions.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "duration_dry_run" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].duration_dry_run.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary DryRun duration>(>= ${local.effective_thresholds[each.key].duration_dry_run.value}ms)."
  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-duration-dry-run"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].duration_dry_run.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].duration_dry_run.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DurationDryRun"
  namespace                 = "CloudWatchSynthetics"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].duration_dry_run.value
  treat_missing_data        = "notBreaching"
  unit                      = "Milliseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For Failed
# Monitors count of failed canary executions.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "failed" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].failed.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary failed count>(>= ${local.effective_thresholds[each.key].failed.value})."
  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].failed.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].failed.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Failed"
  namespace                 = "CloudWatchSynthetics"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].failed.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For FailedRequests
# Monitors count of failed HTTP requests with no response.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "failed_requests" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].failed_requests.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary failed requests>(>= ${local.effective_thresholds[each.key].failed_requests.value})."
  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-failed-requests"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].failed_requests.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].failed_requests.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "FailedRequests"
  namespace                 = "CloudWatchSynthetics"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].failed_requests.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For SuccessPercent
# Monitors percentage of successful canary runs.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "success_percent" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].success_percent.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary success percent>(<= ${local.effective_thresholds[each.key].success_percent.value}%)."
  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-success-percent"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].success_percent.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].success_percent.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "SuccessPercent"
  namespace                 = "CloudWatchSynthetics"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].success_percent.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For SuccessPercentDryRun
# Monitors percentage of successful dry run executions.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "success_percent_dry_run" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].success_percent_dry_run.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary DryRun success percent>(<= ${local.effective_thresholds[each.key].success_percent_dry_run.value}%)."
  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-success-percent-dry-run"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].success_percent_dry_run.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].success_percent_dry_run.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "SuccessPercentDryRun"
  namespace                 = "CloudWatchSynthetics"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].success_percent_dry_run.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For SuccessPercentWithRetries
# Monitors percentage of successful canary runs after retries.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "success_percent_with_retries" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].success_percent_with_retries.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary success percent with retries>(<= ${local.effective_thresholds[each.key].success_percent_with_retries.value}%)."
  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-success-percent-with-retries"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].success_percent_with_retries.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].success_percent_with_retries.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "SuccessPercentWithRetries"
  namespace                 = "CloudWatchSynthetics"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].success_percent_with_retries.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For VisualMonitoringSuccessPercent
# Monitors percentage of visual comparisons matching baseline.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "visual_monitoring_success_percent" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].visual_monitoring_success_percent.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Synthetics Canary visual monitoring success percent>(<= ${local.effective_thresholds[each.key].visual_monitoring_success_percent.value}%)."
  alarm_name                = "${var.name_prefix}metric-synthetics-canary-${each.value.name}-visual-monitoring-success-percent"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].visual_monitoring_success_percent.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].visual_monitoring_success_percent.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "VisualMonitoringSuccessPercent"
  namespace                 = "CloudWatchSynthetics"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].visual_monitoring_success_percent.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}
