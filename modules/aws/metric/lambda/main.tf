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
  url = "https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics.html"
  auto_dimensions = var.create_auto_dimensions ? [
    for v in data.aws_lambda_functions.this.function_names : v if !anytrue([for el in var.auto_dimensions_exclude_list : strcontains(v, el)])
  ] : []
  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : v => {
      name = v
      dimensions = {
        "FunctionName" = v
      }
    }
    } : {
    for v in var.dimensions : v.FunctionName => {
      name       = v.FunctionName
      dimensions = v
    }
  }
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
  for_each                  = var.is_enabled && var.threshold.enabled_concurrent_executions ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-concurrent-executions"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "ConcurrentExecutions"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.concurrent_executions
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda concurrent executions>(>= ${var.threshold.concurrent_executions})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For Duration
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "duration" {
  for_each                  = var.is_enabled && var.threshold.enabled_duration ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-duration"
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
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}

#--------------------------------------------------------------
# For error
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error" {
  for_each                  = var.is_enabled && var.threshold.enabled_errors ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-error"
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
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For Throttles
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "throttles" {
  for_each                  = var.is_enabled && var.threshold.enabled_throttles ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-throttles"
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
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
