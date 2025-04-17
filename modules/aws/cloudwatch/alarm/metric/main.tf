#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "this" {
  count                                 = length(var.aws_cloudwatch_metric_alarm)
  alarm_name                            = lookup(var.aws_cloudwatch_metric_alarm[count.index], "alarm_name")
  comparison_operator                   = lookup(var.aws_cloudwatch_metric_alarm[count.index], "comparison_operator", null)
  evaluation_periods                    = lookup(var.aws_cloudwatch_metric_alarm[count.index], "evaluation_periods", null)
  metric_name                           = lookup(var.aws_cloudwatch_metric_alarm[count.index], "metric_name")
  namespace                             = lookup(var.aws_cloudwatch_metric_alarm[count.index], "namespace")
  period                                = lookup(var.aws_cloudwatch_metric_alarm[count.index], "period", null)
  statistic                             = lookup(var.aws_cloudwatch_metric_alarm[count.index], "statistic", null)
  threshold                             = lookup(var.aws_cloudwatch_metric_alarm[count.index], "threshold", null)
  threshold_metric_id                   = lookup(var.aws_cloudwatch_metric_alarm[count.index], "threshold_metric_id", null)
  actions_enabled                       = lookup(var.aws_cloudwatch_metric_alarm[count.index], "actions_enabled", null)
  alarm_actions                         = lookup(var.aws_cloudwatch_metric_alarm[count.index], "alarm_actions", null)
  alarm_description                     = lookup(var.aws_cloudwatch_metric_alarm[count.index], "alarm_description", null)
  datapoints_to_alarm                   = lookup(var.aws_cloudwatch_metric_alarm[count.index], "datapoints_to_alarm", null)
  dimensions                            = lookup(var.aws_cloudwatch_metric_alarm[count.index], "dimensions", null)
  insufficient_data_actions             = lookup(var.aws_cloudwatch_metric_alarm[count.index], "insufficient_data_actions", null)
  ok_actions                            = lookup(var.aws_cloudwatch_metric_alarm[count.index], "ok_actions", null)
  unit                                  = lookup(var.aws_cloudwatch_metric_alarm[count.index], "unit", null)
  extended_statistic                    = lookup(var.aws_cloudwatch_metric_alarm[count.index], "extended_statistic", null)
  treat_missing_data                    = lookup(var.aws_cloudwatch_metric_alarm[count.index], "treat_missing_data", null)
  evaluate_low_sample_count_percentiles = lookup(var.aws_cloudwatch_metric_alarm[count.index], "evaluate_low_sample_count_percentiles", null)
  dynamic "metric_query" {
    for_each = lookup(var.aws_cloudwatch_metric_alarm[count.index], "metric_query", [])
    content {
      id          = lookup(metric_query.value, "id", null)
      expression  = lookup(metric_query.value, "expression", null)
      label       = lookup(metric_query.value, "label", null)
      return_data = lookup(metric_query.value, "return_data", null)
      dynamic "metric" {
        for_each = lookup(metric_query.value, "metric", null)
        content {
          dimensions  = lookup(metric.value, "dimensions", null)
          metric_name = lookup(metric.value, "metric_name", null)
          namespace   = lookup(metric.value, "namespace", null)
          period      = lookup(metric.value, "period", null)
          stat        = lookup(metric.value, "stat", null)
          unit        = lookup(metric.value, "unit", null)
        }
      }
    }
  }
  tags = local.tags
}
