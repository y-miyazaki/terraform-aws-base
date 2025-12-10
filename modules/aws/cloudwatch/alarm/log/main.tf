#--------------------------------------------------------------
# Module: aws/cloudwatch/alarm/log
# Purpose: Create CloudWatch Logs metric filters and corresponding metric alarms with optional auto-discovery of log groups.
# Notes: Builds dynamic names per log group; unified tagging applied; future improvement: allow multiple transformations per filter with for_each.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "filter" {
  source     = "../../../_internal/auto_discovery_filter"
  is_enabled = var.is_enabled

  create_auto       = var.create_auto_log_group_names
  source_list       = data.aws_cloudwatch_log_groups.this.log_group_names
  include_list      = var.auto_log_group_names_include_list
  exclude_list      = var.auto_log_group_names_exclude_list
  manual_dimensions = var.log_group_names
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  # Use filtered results from helper module
  auto_log_group_names = module.filter.filtered_list
  safe_log_group_names = module.filter.safe_manual_dimensions

  list = var.create_auto_log_group_names ? {
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
}

#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = var.is_enabled ? local.list : {}

  name           = each.value.metric_filter_name
  pattern        = var.aws_cloudwatch_log_metric_filter.pattern
  log_group_name = each.key
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

  alarm_name                            = each.value.metric_alarm_name
  comparison_operator                   = var.aws_cloudwatch_metric_alarm.comparison_operator
  evaluation_periods                    = var.aws_cloudwatch_metric_alarm.evaluation_periods
  metric_name                           = each.value.metric_filter_name
  namespace                             = var.aws_cloudwatch_log_metric_filter.metric_transformation[0].namespace
  period                                = var.aws_cloudwatch_metric_alarm.period
  statistic                             = try(var.aws_cloudwatch_metric_alarm.statistic, null)
  threshold                             = var.aws_cloudwatch_metric_alarm.threshold
  threshold_metric_id                   = var.aws_cloudwatch_metric_alarm.threshold_metric_id
  actions_enabled                       = var.aws_cloudwatch_metric_alarm.actions_enabled
  alarm_actions                         = var.alarm_actions
  alarm_description                     = "This is an alarm to check for ${var.aws_cloudwatch_log_metric_filter.name}(>= ${var.aws_cloudwatch_metric_alarm.threshold})."
  datapoints_to_alarm                   = var.aws_cloudwatch_metric_alarm.datapoints_to_alarm
  dimensions                            = var.aws_cloudwatch_metric_alarm.dimensions
  insufficient_data_actions             = var.insufficient_data_actions
  ok_actions                            = var.ok_actions
  unit                                  = "Count"
  extended_statistic                    = try(var.aws_cloudwatch_metric_alarm.extended_statistic, null)
  treat_missing_data                    = var.aws_cloudwatch_metric_alarm.treat_missing_data
  evaluate_low_sample_count_percentiles = try(var.aws_cloudwatch_metric_alarm.evaluate_low_sample_count_percentiles, null)

  tags = var.tags
}
