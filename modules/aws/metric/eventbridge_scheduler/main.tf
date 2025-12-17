#--------------------------------------------------------------
# Module: aws/metric/eventbridge_scheduler
# Purpose: Provide CloudWatch metric alarms for EventBridge Scheduler operational metrics (invocation attempts, errors, throttles, drops).
# Notes: Supports multiple schedule groups via dimension expansion; unified tagging applied; future improvement: add percentage-based error rate alarms.
#--------------------------------------------------------------
#--------------------------------------------------------------
# metric_helper module for combining dimensions and threshold overrides
#--------------------------------------------------------------
module "metric_helper" {
  source = "../../_internal/metric_helper"

  create_auto        = var.create_auto_dimensions
  source_list        = local.list_schedule_group
  include_list       = var.auto_dimensions_include_list
  exclude_list       = var.auto_dimensions_exclude_list
  manual_dimensions  = var.dimensions
  dimension_key      = "ScheduleGroup"
  base_threshold     = var.threshold
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
    if local.effective_thresholds[k].enabled_invocation_attempt_count
  } : {}

  alarm_name                = "${var.name_prefix}metric-eventbridge-scheduler-${each.key}-invocation-attempt-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Scheduler"
  metric_name               = "InvocationAttemptCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].invocation_attempt_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler InvocationAttemptCount>(>= ${local.effective_thresholds[each.key].invocation_attempt_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_error_count" {
  for_each = var.is_enabled ? {
    for k, v in local.effective_dimensions : k => v
    if local.effective_thresholds[k].enabled_target_error_count
  } : {}

  alarm_name                = "${var.name_prefix}metric-eventbridge-scheduler-${each.key}-target-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Scheduler"
  metric_name               = "TargetErrorCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_error_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler TargetErrorCount>(>= ${local.effective_thresholds[each.key].target_error_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetErrorThrottledCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_error_throttled_count" {
  for_each = var.is_enabled ? {
    for k, v in local.effective_dimensions : k => v
    if local.effective_thresholds[k].enabled_target_error_throttled_count
  } : {}

  alarm_name                = "${var.name_prefix}metric-eventbridge-scheduler-${each.key}-target-error-throttled-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Scheduler"
  metric_name               = "TargetErrorThrottledCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_error_throttled_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler TargetErrorThrottledCount>(>= ${local.effective_thresholds[each.key].target_error_throttled_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For InvocationDroppedCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "invocation_dropped_count" {
  for_each = var.is_enabled ? {
    for k, v in local.effective_dimensions : k => v
    if local.effective_thresholds[k].enabled_invocation_dropped_count
  } : {}

  alarm_name                = "${var.name_prefix}metric-eventbridge-scheduler-${each.key}-invocation-dropped-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Scheduler"
  metric_name               = "InvocationDroppedCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].invocation_dropped_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler InvocationDroppedCount>(>= ${local.effective_thresholds[each.key].invocation_dropped_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For InvocationThrottleCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "invocation_throttle_count" {
  for_each = var.is_enabled ? {
    for k, v in local.effective_dimensions : k => v
    if local.effective_thresholds[k].enabled_invocation_throttle_count
  } : {}

  alarm_name                = "${var.name_prefix}metric-eventbridge-scheduler-${each.key}-invocation-throttle-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Scheduler"
  metric_name               = "InvocationThrottleCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].invocation_throttle_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler InvocationThrottleCount>(>= ${local.effective_thresholds[each.key].invocation_throttle_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
