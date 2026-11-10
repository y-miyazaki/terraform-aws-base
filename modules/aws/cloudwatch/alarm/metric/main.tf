#--------------------------------------------------------------
# Module: aws/cloudwatch/alarm/metric
# Purpose: Provision generic CloudWatch metric alarms from a list input supporting dimensions, metric math, and extended settings.
# Notes: Wrapper for multiple alarms using for_each keyed by alarm_name; unified tagging applied.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

#--------------------------------------------------------------
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "this" {
  # Keyed by alarm_name so reordering var.aws_cloudwatch_metric_alarm does not recreate alarms.
  for_each = { for a in var.aws_cloudwatch_metric_alarm : a.alarm_name => a }

  region                                = local.region
  actions_enabled                       = try(each.value.actions_enabled, null)
  alarm_actions                         = try(each.value.alarm_actions, null)
  alarm_description                     = try(each.value.alarm_description, null)
  alarm_name                            = try(each.value.alarm_name)
  comparison_operator                   = try(each.value.comparison_operator, null)
  datapoints_to_alarm                   = try(each.value.datapoints_to_alarm, null)
  dimensions                            = try(each.value.dimensions, null)
  evaluate_low_sample_count_percentiles = try(each.value.evaluate_low_sample_count_percentiles, null)
  evaluation_periods                    = try(each.value.evaluation_periods, null)
  extended_statistic                    = try(each.value.extended_statistic, null)
  insufficient_data_actions             = try(each.value.insufficient_data_actions, null)
  metric_name                           = try(each.value.metric_name)
  namespace                             = try(each.value.namespace)
  ok_actions                            = try(each.value.ok_actions, null)
  period                                = try(each.value.period, null)
  statistic                             = try(each.value.statistic, null)
  threshold                             = try(each.value.threshold, null)
  threshold_metric_id                   = try(each.value.threshold_metric_id, null)
  treat_missing_data                    = try(each.value.treat_missing_data, null)
  unit                                  = try(each.value.unit, null)

  dynamic "metric_query" {
    for_each = try(each.value.metric_query, [])

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
