#--------------------------------------------------------------
# For Lambda
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  url   = "https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics.html"
  count = length(var.dimensions) > 0 ? length(var.dimensions) : 1
  names = length(var.dimensions) > 0 ? flatten([
    for r in var.dimensions : {
      name = format("%s-", r.FunctionName)
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
# For Concurrent Executions
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "concurrent_executions" {
  count                     = var.is_enabled && var.threshold.enabled_concurrent_executions ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-lambda-${local.names[count.index].name}concurrent-executions"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "ConcurrentExecutions"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.concurrent_executions
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda concurrent executions>(>= ${var.threshold.concurrent_executions}msec)."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For Duration
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "duration" {
  count                     = var.is_enabled && var.threshold.enabled_duration ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-lambda-${local.names[count.index].name}duration"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "Duration"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.duration
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda duration>(>= ${var.threshold.duration}msec)."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}

#--------------------------------------------------------------
# For error
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error" {
  count                     = var.is_enabled && var.threshold.enabled_errors ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-lambda-${local.names[count.index].name}error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "Errors"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.errors
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda errors>(>= ${var.threshold.errors})."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For Throttles
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "throttles" {
  count                     = var.is_enabled && var.threshold.enabled_throttles ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-lambda-${local.names[count.index].name}throttles"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "Throttles"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.throttles
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda throttles>(>= ${var.threshold.throttles})."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
