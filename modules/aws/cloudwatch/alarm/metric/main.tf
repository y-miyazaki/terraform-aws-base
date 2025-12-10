#--------------------------------------------------------------
# Module: aws/cloudwatch/alarm/metric
# Purpose: Provision generic CloudWatch metric alarms from a list input supporting dimensions, metric math, and extended settings.
# Notes: Wrapper for multiple alarms using count; unified tagging applied; future improvement: migrate to for_each keyed by alarm_name to avoid index drift.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "this" {
  count = length(var.aws_cloudwatch_metric_alarm)

  alarm_name                            = try(var.aws_cloudwatch_metric_alarm[count.index].alarm_name)
  comparison_operator                   = try(var.aws_cloudwatch_metric_alarm[count.index].comparison_operator, null)
  evaluation_periods                    = try(var.aws_cloudwatch_metric_alarm[count.index].evaluation_periods, null)
  metric_name                           = try(var.aws_cloudwatch_metric_alarm[count.index].metric_name)
  namespace                             = try(var.aws_cloudwatch_metric_alarm[count.index].namespace)
  period                                = try(var.aws_cloudwatch_metric_alarm[count.index].period, null)
  statistic                             = try(var.aws_cloudwatch_metric_alarm[count.index].statistic, null)
  threshold                             = try(var.aws_cloudwatch_metric_alarm[count.index].threshold, null)
  threshold_metric_id                   = try(var.aws_cloudwatch_metric_alarm[count.index].threshold_metric_id, null)
  actions_enabled                       = try(var.aws_cloudwatch_metric_alarm[count.index].actions_enabled, null)
  alarm_actions                         = try(var.aws_cloudwatch_metric_alarm[count.index].alarm_actions, null)
  alarm_description                     = try(var.aws_cloudwatch_metric_alarm[count.index].alarm_description, null)
  datapoints_to_alarm                   = try(var.aws_cloudwatch_metric_alarm[count.index].datapoints_to_alarm, null)
  dimensions                            = try(var.aws_cloudwatch_metric_alarm[count.index].dimensions, null)
  insufficient_data_actions             = try(var.aws_cloudwatch_metric_alarm[count.index].insufficient_data_actions, null)
  ok_actions                            = try(var.aws_cloudwatch_metric_alarm[count.index].ok_actions, null)
  unit                                  = try(var.aws_cloudwatch_metric_alarm[count.index].unit, null)
  extended_statistic                    = try(var.aws_cloudwatch_metric_alarm[count.index].extended_statistic, null)
  treat_missing_data                    = try(var.aws_cloudwatch_metric_alarm[count.index].treat_missing_data, null)
  evaluate_low_sample_count_percentiles = try(var.aws_cloudwatch_metric_alarm[count.index].evaluate_low_sample_count_percentiles, null)
  dynamic "metric_query" {
    for_each = try(var.aws_cloudwatch_metric_alarm[count.index].metric_query, [])

    content {
      id          = try(metric_query.value.id, null)
      expression  = try(metric_query.value.expression, null)
      label       = try(metric_query.value.label, null)
      return_data = try(metric_query.value.return_data, null)
      dynamic "metric" {
        for_each = try(metric_query.value.metric, null)

        content {
          dimensions  = try(metric.value.dimensions, null)
          metric_name = try(metric.value.metric_name, null)
          namespace   = try(metric.value.namespace, null)
          period      = try(metric.value.period, null)
          stat        = try(metric.value.stat, null)
          unit        = try(metric.value.unit, null)
        }
      }
    }
  }

  tags = var.tags
}
