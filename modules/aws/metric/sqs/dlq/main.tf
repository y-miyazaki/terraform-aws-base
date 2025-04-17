#--------------------------------------------------------------
# For SQS(DLQ)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  url = "https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-available-cloudwatch-metrics.html"
  auto_dimensions = var.create_auto_dimensions ? [
    for v in split(",", data.external.list[0].result.list) : split(":", v)[length(split(":", v)) - 1] if !anytrue([for el in var.auto_dimensions_exclude_list : strcontains(v, el)])
  ] : []
  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : v => {
      name = v
      dimensions = {
        "QueueName" = v
      }
    }
    } : {
    for v in var.dimensions : v.QueueName => {
      name       = v.QueueName
      dimensions = v
    }
  }
}

#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesVisible
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_visible" {
  for_each                  = var.is_enabled && var.threshold.enabled_approximate_number_of_messages_visible ? local.list : {}
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
  tags                      = local.tags
}
