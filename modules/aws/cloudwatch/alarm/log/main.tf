#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  auto_log_group_names = var.create_auto_log_group_names ? [
    for v in data.aws_cloudwatch_log_groups.this.log_group_names : v if !anytrue([for el in var.auto_log_group_names_exclude_list : strcontains(v, el)])
  ] : []
  list = var.create_auto_log_group_names ? {
    for v in local.auto_log_group_names : v => {
      metric_filter_name = "${var.name_prefix}${var.aws_cloudwatch_log_metric_filter.name}-${replace(replace(v, "/", "-"), "/^-/", "")}"
      metric_alarm_name  = "${var.name_prefix}${var.aws_cloudwatch_metric_alarm.alarm_name}-${replace(replace(v, "/", "-"), "/^-/", "")}"
    }
    } : {
    for v in var.log_group_names : v => {
      metric_filter_name = "${var.name_prefix}${var.aws_cloudwatch_log_metric_filter.name}-${replace(replace(v, "/", "-"), "/^-/", "")}"
      metric_alarm_name  = "${var.name_prefix}${var.aws_cloudwatch_metric_alarm.alarm_name}-${replace(replace(v, "/", "-"), "/^-/", "")}"
    }
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each       = local.list
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
  for_each                              = local.list
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
  tags                                  = local.tags
}
