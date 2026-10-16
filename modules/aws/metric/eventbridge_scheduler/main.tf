#--------------------------------------------------------------
# Module: aws/metric/eventbridge_scheduler
# Purpose: Provide CloudWatch metric alarms for EventBridge Scheduler operational metrics (invocation attempts, errors, throttles, drops).
# Notes: Supports multiple schedule groups via dimension expansion; unified tagging applied; future improvement: add percentage-based error rate alarms.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

#--------------------------------------------------------------
# Auto-discovery metric filter module
#--------------------------------------------------------------
module "metric_helper" {
  source = "../../_internal/metric_helper"

  is_enabled = var.is_enabled

  base_threshold     = var.threshold
  create_auto        = var.create_auto_dimensions
  dimension_key      = "ScheduleGroup"
  exclude_list       = var.auto_dimensions_exclude_list
  include_list       = var.auto_dimensions_include_list
  manual_dimensions  = var.dimensions
  source_list        = local.list_schedule_group
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url                  = "https://docs.aws.amazon.com/scheduler/latest/UserGuide/monitoring-cloudwatch.html"
  effective_dimensions = module.metric_helper.list
  effective_thresholds = module.metric_helper.effective_thresholds
}

#--------------------------------------------------------------
# For InvocationAttemptCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "invocation_attempt_count" {
  for_each = var.is_enabled ? {
    for k, v in local.effective_dimensions : k => v
    if local.effective_thresholds[k].invocation_attempt_count.enabled
  } : {}

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler InvocationAttemptCount>(>= ${local.effective_thresholds[each.key].invocation_attempt_count.value})."
  alarm_name                = "${var.name_prefix}metric-sch-${each.key}-invocation-attempt-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].invocation_attempt_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].invocation_attempt_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "InvocationAttemptCount"
  namespace                 = "AWS/Scheduler"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].invocation_attempt_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_error_count" {
  for_each = var.is_enabled ? {
    for k, v in local.effective_dimensions : k => v
    if local.effective_thresholds[k].target_error_count.enabled
  } : {}

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler TargetErrorCount>(>= ${local.effective_thresholds[each.key].target_error_count.value})."
  alarm_name                = "${var.name_prefix}metric-sch-${each.key}-target-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_error_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_error_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetErrorCount"
  namespace                 = "AWS/Scheduler"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_error_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetErrorThrottledCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_error_throttled_count" {
  for_each = var.is_enabled ? {
    for k, v in local.effective_dimensions : k => v
    if local.effective_thresholds[k].target_error_throttled_count.enabled
  } : {}

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler TargetErrorThrottledCount>(>= ${local.effective_thresholds[each.key].target_error_throttled_count.value})."
  alarm_name                = "${var.name_prefix}metric-sch-${each.key}-target-error-throttled-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_error_throttled_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_error_throttled_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetErrorThrottledCount"
  namespace                 = "AWS/Scheduler"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_error_throttled_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For InvocationDroppedCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "invocation_dropped_count" {
  for_each = var.is_enabled ? {
    for k, v in local.effective_dimensions : k => v
    if local.effective_thresholds[k].invocation_dropped_count.enabled
  } : {}

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler InvocationDroppedCount>(>= ${local.effective_thresholds[each.key].invocation_dropped_count.value})."
  alarm_name                = "${var.name_prefix}metric-sch-${each.key}-invocation-dropped-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].invocation_dropped_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].invocation_dropped_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "InvocationDroppedCount"
  namespace                 = "AWS/Scheduler"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].invocation_dropped_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For InvocationThrottleCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "invocation_throttle_count" {
  for_each = var.is_enabled ? {
    for k, v in local.effective_dimensions : k => v
    if local.effective_thresholds[k].invocation_throttle_count.enabled
  } : {}

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler InvocationThrottleCount>(>= ${local.effective_thresholds[each.key].invocation_throttle_count.value})."
  alarm_name                = "${var.name_prefix}metric-sch-${each.key}-invocation-throttle-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].invocation_throttle_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].invocation_throttle_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "InvocationThrottleCount"
  namespace                 = "AWS/Scheduler"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].invocation_throttle_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}
