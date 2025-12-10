#--------------------------------------------------------------
# Module: aws/metric/sqs/dlq
# Purpose: Provide CloudWatch metric alarms for SQS dead-letter queues (age, message count, redrive metrics).
# Notes: Unified tagging; monitors DLQ health indicators to surface processing issues.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "filter" {
  source     = "../../../_internal/auto_discovery_filter"
  is_enabled = var.is_enabled

  create_auto       = var.create_auto_dimensions
  source_list       = var.create_auto_dimensions && length(data.external.list) > 0 ? [for v in split(",", data.external.list[0].result.list) : split(":", v)[length(split(":", v)) - 1]] : []
  include_list      = var.auto_dimensions_include_list
  exclude_list      = var.auto_dimensions_exclude_list
  manual_dimensions = var.dimensions
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-available-cloudwatch-metrics.html"

  # Use filtered results from helper module
  auto_dimensions = module.filter.filtered_list
  safe_dimensions = module.filter.safe_manual_dimensions

  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : v => {
      name = v
      dimensions = {
        "QueueName" = v
      }
    }
    } : {
    for v in local.safe_dimensions : v.QueueName => {
      name       = v.QueueName
      dimensions = v
    } if v != null && try(v.QueueName, null) != null && v.QueueName != ""
  }
}


#--------------------------------------------------------------
# For ApproximateNumberOfMessagesVisible
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_visible" {
  for_each = var.is_enabled && var.threshold.enabled_approximate_number_of_messages_visible ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-visible"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "ApproximateNumberOfMessagesVisible"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.approximate_number_of_messages_visible
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS(DLQ) approximate number of messages visible>(>= ${var.threshold.approximate_number_of_messages_visible})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
