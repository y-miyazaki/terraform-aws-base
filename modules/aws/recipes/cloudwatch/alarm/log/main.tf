#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  aws_cloudwatch_log_metric_filter = {
    for k, v in var.aws_cloudwatch_log_metric_filter : v.log_group_name => v
  }
  aws_cloudwatch_metric_alarm = {
    for k, v in var.aws_cloudwatch_metric_alarm : v.alarm_name => v
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
  for_each       = local.aws_cloudwatch_log_metric_filter
  name           = lookup(each.value, "name")
  pattern        = lookup(each.value, "pattern", null)
  log_group_name = lookup(each.value, "log_group_name")
  dynamic "metric_transformation" {
    for_each = lookup(each.value, "metric_transformation", [])
    content {
      name          = lookup(each.value, "name")
      namespace     = lookup(metric_transformation.value, "namespace", null)
      value         = lookup(metric_transformation.value, "value", null)
      default_value = lookup(metric_transformation.value, "default_value", null)
    }
  }
}
#--------------------------------------------------------------
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "this" {
  for_each                              = local.aws_cloudwatch_metric_alarm
  alarm_name                            = lookup(each.value, "alarm_name")
  comparison_operator                   = lookup(each.value, "comparison_operator", null)
  evaluation_periods                    = lookup(each.value, "evaluation_periods", null)
  metric_name                           = lookup(each.value, "metric_name", null)
  namespace                             = lookup(each.value, "namespace", null)
  period                                = lookup(each.value, "period", null)
  statistic                             = lookup(each.value, "statistic", null)
  threshold                             = lookup(each.value, "threshold", null)
  threshold_metric_id                   = lookup(each.value, "threshold_metric_id", null)
  actions_enabled                       = lookup(each.value, "actions_enabled", null)
  alarm_actions                         = lookup(each.value, "alarm_actions", null)
  alarm_description                     = lookup(each.value, "alarm_description", null)
  datapoints_to_alarm                   = lookup(each.value, "datapoints_to_alarm", null)
  dimensions                            = lookup(each.value, "dimensions", null)
  insufficient_data_actions             = lookup(each.value, "insufficient_data_actions", null)
  ok_actions                            = lookup(each.value, "ok_actions", null)
  unit                                  = lookup(each.value, "unit", null)
  extended_statistic                    = lookup(each.value, "extended_statistic", null)
  treat_missing_data                    = lookup(each.value, "treat_missing_data", null)
  evaluate_low_sample_count_percentiles = lookup(each.value, "evaluate_low_sample_count_percentiles", null)
  tags                                  = local.tags
}
