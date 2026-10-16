#--------------------------------------------------------------
# Module: aws/cloudwatch/alarm/log
# Purpose: Create CloudWatch Logs metric filters and corresponding metric alarms with optional auto-discovery of log groups.
# Notes: Builds dynamic names per log group; unified tagging applied; future improvement: allow multiple transformations per filter with for_each.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}
module "filter" {
  source = "../../../_internal/auto_discovery_filter"

  is_enabled = var.is_enabled

  create_auto       = var.create_auto_log_group_names
  exclude_list      = var.auto_log_group_names_exclude_list
  include_list      = var.auto_log_group_names_include_list
  manual_dimensions = var.log_group_names
  source_list       = data.aws_cloudwatch_log_groups.this.log_group_names
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  comparison_operator_symbols = {
    GreaterThanOrEqualToThreshold = ">="
    GreaterThanThreshold          = ">"
    LessThanOrEqualToThreshold    = "<="
    LessThanThreshold             = "<"
  }
  # Use filtered results from helper module
  auto_log_group_names = module.filter.filtered_list
  safe_log_group_names = module.filter.safe_manual_dimensions

  base_list = var.create_auto_log_group_names ? {
    for v in local.auto_log_group_names : v => {
      metric_filter_name = "${var.name_prefix}${var.aws_cloudwatch_log_metric_filter.name}-${replace(replace(v, "/", "-"), "/^-/", "")}"
      metric_alarm_name  = "${var.name_prefix}${var.aws_cloudwatch_metric_alarm.alarm_name}-${replace(replace(v, "/", "-"), "/^-/", "")}"
    }
    } : {
    for v in local.safe_log_group_names : v => {
      metric_filter_name = "${var.name_prefix}${var.aws_cloudwatch_log_metric_filter.name}-${replace(replace(v, "/", "-"), "/^-/", "")}"
      metric_alarm_name  = "${var.name_prefix}${var.aws_cloudwatch_metric_alarm.alarm_name}-${replace(replace(v, "/", "-"), "/^-/", "")}"
    } if v != null && v != ""
  }

  # Apply log_group_override per log group. Unspecified values fall back to the common settings.
  list = {
    for k, v in local.base_list : k => merge(v, {
      datapoints_to_alarm = try(var.log_group_override[k].datapoints_to_alarm, var.aws_cloudwatch_metric_alarm.datapoints_to_alarm)
      evaluation_periods  = try(var.log_group_override[k].evaluation_periods, var.aws_cloudwatch_metric_alarm.evaluation_periods)
      pattern             = try(var.log_group_override[k].pattern, var.aws_cloudwatch_log_metric_filter.pattern)
      period              = try(var.log_group_override[k].period, var.aws_cloudwatch_metric_alarm.period)
      threshold           = try(var.log_group_override[k].threshold, var.aws_cloudwatch_metric_alarm.threshold)
    }) if try(var.log_group_override[k].enabled, true)
  }
}

#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = var.is_enabled ? local.list : {}

  region         = local.region
  log_group_name = each.key
  name           = each.value.metric_filter_name
  pattern        = each.value.pattern

  dynamic "metric_transformation" {
    for_each = var.aws_cloudwatch_log_metric_filter.metric_transformation

    content {
      name          = each.value.metric_filter_name
      namespace     = metric_transformation.value.namespace
      value         = metric_transformation.value.value
      default_value = try(metric_transformation.value.default_value, null)
      unit          = "Count"
    }
  }
}

#--------------------------------------------------------------
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.is_enabled ? local.list : {}

  region                                = local.region
  actions_enabled                       = var.aws_cloudwatch_metric_alarm.actions_enabled
  alarm_actions                         = var.alarm_actions
  alarm_description                     = "This is an alarm to check for ${var.aws_cloudwatch_log_metric_filter.name}(${lookup(local.comparison_operator_symbols, var.aws_cloudwatch_metric_alarm.comparison_operator, var.aws_cloudwatch_metric_alarm.comparison_operator)} ${each.value.threshold})."
  alarm_name                            = each.value.metric_alarm_name
  comparison_operator                   = var.aws_cloudwatch_metric_alarm.comparison_operator
  datapoints_to_alarm                   = each.value.datapoints_to_alarm
  dimensions                            = var.aws_cloudwatch_metric_alarm.dimensions
  evaluate_low_sample_count_percentiles = try(var.aws_cloudwatch_metric_alarm.evaluate_low_sample_count_percentiles, null)
  evaluation_periods                    = each.value.evaluation_periods
  extended_statistic                    = try(var.aws_cloudwatch_metric_alarm.extended_statistic, null)
  insufficient_data_actions             = var.insufficient_data_actions
  metric_name                           = each.value.metric_filter_name
  namespace                             = var.aws_cloudwatch_log_metric_filter.metric_transformation[0].namespace
  ok_actions                            = var.ok_actions
  period                                = each.value.period
  statistic                             = try(var.aws_cloudwatch_metric_alarm.statistic, null)
  threshold                             = each.value.threshold
  threshold_metric_id                   = var.aws_cloudwatch_metric_alarm.threshold_metric_id
  treat_missing_data                    = var.aws_cloudwatch_metric_alarm.treat_missing_data
  unit                                  = "Count"

  tags = var.tags
}
