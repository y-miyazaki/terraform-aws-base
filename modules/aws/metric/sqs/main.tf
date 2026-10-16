#--------------------------------------------------------------
# Module: aws/metric/sqs
# Purpose: Provide CloudWatch metric alarms for Amazon SQS queues (standard and FIFO, including DLQs).
# Notes: Unified tagging; monitors all queue types using QueueName dimension.
#        FIFO-only metrics (NumberOfDeduplicatedSentMessages, ApproximateNumberOfGroupsWithInflightMessages)
#        are included but will report notBreaching for standard queues.
#        Fair queue metrics (ApproximateNumberOfNoisyGroups, *InQuietGroups) are included for completeness.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

#--------------------------------------------------------------
# Auto-discovery metric filter module
#--------------------------------------------------------------
module "helper" {
  source = "../../_internal/metric_helper"

  is_enabled = var.is_enabled

  base_threshold     = var.threshold
  create_auto        = var.create_auto_dimensions
  dimension_key      = "QueueName"
  exclude_list       = var.auto_dimensions_exclude_list
  include_list       = var.auto_dimensions_include_list
  manual_dimensions  = var.dimensions
  source_list        = var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list) : []
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-available-cloudwatch-metrics.html"

  # Use helper module outputs
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
}

#--------------------------------------------------------------
# For ApproximateAgeOfOldestMessage
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_age_of_oldest_message" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].approximate_age_of_oldest_message.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateAgeOfOldestMessage>(>= ${local.effective_thresholds[each.key].approximate_age_of_oldest_message.value}s)."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-age-of-oldest-message"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].approximate_age_of_oldest_message.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].approximate_age_of_oldest_message.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ApproximateAgeOfOldestMessage"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].approximate_age_of_oldest_message.value
  treat_missing_data        = "notBreaching"
  unit                      = "Seconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateAgeOfOldestMessageInQuietGroups (Fair Queues)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_age_of_oldest_message_in_quiet_groups" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].approximate_age_of_oldest_message_in_quiet_groups.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateAgeOfOldestMessageInQuietGroups>(>= ${local.effective_thresholds[each.key].approximate_age_of_oldest_message_in_quiet_groups.value}s)."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-age-of-oldest-message-in-quiet-groups"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].approximate_age_of_oldest_message_in_quiet_groups.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].approximate_age_of_oldest_message_in_quiet_groups.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ApproximateAgeOfOldestMessageInQuietGroups"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].approximate_age_of_oldest_message_in_quiet_groups.value
  treat_missing_data        = "notBreaching"
  unit                      = "Seconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfGroupsWithInflightMessages (FIFO only)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_groups_with_inflight_messages" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].approximate_number_of_groups_with_inflight_messages.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfGroupsWithInflightMessages>(>= ${local.effective_thresholds[each.key].approximate_number_of_groups_with_inflight_messages.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-groups-with-inflight-messages"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].approximate_number_of_groups_with_inflight_messages.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].approximate_number_of_groups_with_inflight_messages.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ApproximateNumberOfGroupsWithInflightMessages"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_groups_with_inflight_messages.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesDelayed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_delayed" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].approximate_number_of_messages_delayed.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfMessagesDelayed>(>= ${local.effective_thresholds[each.key].approximate_number_of_messages_delayed.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-delayed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].approximate_number_of_messages_delayed.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].approximate_number_of_messages_delayed.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ApproximateNumberOfMessagesDelayed"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_messages_delayed.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesDelayedInQuietGroups (Fair Queues)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_delayed_in_quiet_groups" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].approximate_number_of_messages_delayed_in_quiet_groups.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfMessagesDelayedInQuietGroups>(>= ${local.effective_thresholds[each.key].approximate_number_of_messages_delayed_in_quiet_groups.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-delayed-in-quiet-groups"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].approximate_number_of_messages_delayed_in_quiet_groups.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].approximate_number_of_messages_delayed_in_quiet_groups.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ApproximateNumberOfMessagesDelayedInQuietGroups"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_messages_delayed_in_quiet_groups.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesNotVisible
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_not_visible" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].approximate_number_of_messages_not_visible.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfMessagesNotVisible>(>= ${local.effective_thresholds[each.key].approximate_number_of_messages_not_visible.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-not-visible"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].approximate_number_of_messages_not_visible.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].approximate_number_of_messages_not_visible.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ApproximateNumberOfMessagesNotVisible"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_messages_not_visible.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesNotVisibleInQuietGroups (Fair Queues)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_not_visible_in_quiet_groups" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].approximate_number_of_messages_not_visible_in_quiet_groups.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfMessagesNotVisibleInQuietGroups>(>= ${local.effective_thresholds[each.key].approximate_number_of_messages_not_visible_in_quiet_groups.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-not-visible-in-quiet-groups"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].approximate_number_of_messages_not_visible_in_quiet_groups.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].approximate_number_of_messages_not_visible_in_quiet_groups.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ApproximateNumberOfMessagesNotVisibleInQuietGroups"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_messages_not_visible_in_quiet_groups.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesVisible
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_visible" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].approximate_number_of_messages_visible.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfMessagesVisible>(>= ${local.effective_thresholds[each.key].approximate_number_of_messages_visible.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-visible"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].approximate_number_of_messages_visible.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].approximate_number_of_messages_visible.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ApproximateNumberOfMessagesVisible"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_messages_visible.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesVisibleInQuietGroups (Fair Queues)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_visible_in_quiet_groups" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].approximate_number_of_messages_visible_in_quiet_groups.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfMessagesVisibleInQuietGroups>(>= ${local.effective_thresholds[each.key].approximate_number_of_messages_visible_in_quiet_groups.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-visible-in-quiet-groups"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].approximate_number_of_messages_visible_in_quiet_groups.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].approximate_number_of_messages_visible_in_quiet_groups.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ApproximateNumberOfMessagesVisibleInQuietGroups"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_messages_visible_in_quiet_groups.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfNoisyGroups (Fair Queues)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_noisy_groups" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].approximate_number_of_noisy_groups.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfNoisyGroups>(>= ${local.effective_thresholds[each.key].approximate_number_of_noisy_groups.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-noisy-groups"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].approximate_number_of_noisy_groups.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].approximate_number_of_noisy_groups.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ApproximateNumberOfNoisyGroups"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_noisy_groups.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfDeduplicatedSentMessages (FIFO only)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_deduplicated_sent_messages" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_deduplicated_sent_messages.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS NumberOfDeduplicatedSentMessages>(>= ${local.effective_thresholds[each.key].number_of_deduplicated_sent_messages.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-number-of-deduplicated-sent-messages"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_deduplicated_sent_messages.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_deduplicated_sent_messages.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfDeduplicatedSentMessages"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_deduplicated_sent_messages.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfEmptyReceives
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_empty_receives" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_empty_receives.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS NumberOfEmptyReceives>(>= ${local.effective_thresholds[each.key].number_of_empty_receives.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-number-of-empty-receives"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_empty_receives.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_empty_receives.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfEmptyReceives"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_empty_receives.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfMessagesDeleted
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_messages_deleted" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_messages_deleted.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS NumberOfMessagesDeleted>(>= ${local.effective_thresholds[each.key].number_of_messages_deleted.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-number-of-messages-deleted"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_messages_deleted.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_messages_deleted.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfMessagesDeleted"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_messages_deleted.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfMessagesReceived
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_messages_received" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_messages_received.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS NumberOfMessagesReceived>(>= ${local.effective_thresholds[each.key].number_of_messages_received.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-number-of-messages-received"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_messages_received.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_messages_received.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfMessagesReceived"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_messages_received.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfMessagesSent
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_messages_sent" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_messages_sent.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS NumberOfMessagesSent>(>= ${local.effective_thresholds[each.key].number_of_messages_sent.value})."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-number-of-messages-sent"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_messages_sent.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_messages_sent.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfMessagesSent"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_messages_sent.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For SentMessageSize
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "sent_message_size" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].sent_message_size.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS SentMessageSize>(>= ${local.effective_thresholds[each.key].sent_message_size.value} bytes)."
  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-sent-message-size"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].sent_message_size.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].sent_message_size.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "SentMessageSize"
  namespace                 = "AWS/SQS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].sent_message_size.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}
