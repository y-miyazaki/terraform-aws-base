#--------------------------------------------------------------
# For EventBridge Scheduler
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  url   = "https://docs.aws.amazon.com/scheduler/latest/UserGuide/monitoring-cloudwatch.html"
  count = length(var.dimensions) > 0 ? length(var.dimensions) : 1
  names = length(var.dimensions) > 0 ? flatten([
    for r in var.dimensions : {
      name = format("%s-", r.ScheduleGroup)
    }]) : [{
    name = ""
  }]
  is_dimensions = length(var.dimensions) > 0 ? true : false
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# For InvocationAttemptCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "invocation_attempt_count" {
  count                     = var.is_enabled && var.threshold.enabled_invocation_attempt_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-eventbridge-scheduler-${local.names[count.index].name}invocation-attempt-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Scheduler"
  metric_name               = "InvocationAttemptCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.invocation_attempt_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler InvocationAttemptCount>(>= ${var.threshold.invocation_attempt_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For TargetErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_error_count" {
  count                     = var.is_enabled && var.threshold.enabled_target_error_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-eventbridge-scheduler-${local.names[count.index].name}target-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Scheduler"
  metric_name               = "TargetErrorCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.target_error_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler TargetErrorCount>(>= ${var.threshold.target_error_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For TargetErrorThrottledCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_error_throttled_count" {
  count                     = var.is_enabled && var.threshold.enabled_target_error_throttled_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-eventbridge-scheduler-${local.names[count.index].name}target-error-throttled-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Scheduler"
  metric_name               = "TargetErrorThrottledCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.target_error_throttled_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler TargetErrorThrottledCount>(>= ${var.threshold.target_error_throttled_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For InvocationThrottleCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "invocation_throttle_count" {
  count                     = var.is_enabled && var.threshold.enabled_invocation_throttle_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-eventbridge-scheduler-${local.names[count.index].name}invocation-throttle-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Scheduler"
  metric_name               = "InvocationThrottleCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.invocation_throttle_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler InvocationThrottleCount>(>= ${var.threshold.invocation_throttle_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For InvocationDroppedCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "invocation_dropped_count" {
  count                     = var.is_enabled && var.threshold.enabled_invocation_dropped_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-eventbridge-scheduler-${local.names[count.index].name}invocation-dropped-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Scheduler"
  metric_name               = "InvocationDroppedCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.invocation_dropped_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EventBridge Scheduler InvocationDroppedCount>(>= ${var.threshold.invocation_dropped_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
