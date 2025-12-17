#--------------------------------------------------------------
# Module: aws/metric/sqs
# Purpose: Provide CloudWatch metric alarms for Amazon SQS queues (standard and FIFO, including DLQs).
# Notes: Unified tagging; monitors all queue types using QueueName dimension.
#        FIFO-only metrics (NumberOfDeduplicatedSentMessages, ApproximateNumberOfGroupsWithInflightMessages)
#        are included but will report notBreaching for standard queues.
#        Fair queue metrics (ApproximateNumberOfNoisyGroups, *InQuietGroups) are included for completeness.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Metric helper module (auto-discovery filter + threshold override)
#--------------------------------------------------------------
module "helper" {
  source     = "../../_internal/metric_helper"
  is_enabled = var.is_enabled

  create_auto        = var.create_auto_dimensions
  source_list        = var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list) : []
  include_list       = var.auto_dimensions_include_list
  exclude_list       = var.auto_dimensions_exclude_list
  manual_dimensions  = var.dimensions
  dimension_key      = "QueueName"
  base_threshold     = var.threshold
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
    if var.is_enabled && local.effective_thresholds[k].enabled_approximate_age_of_oldest_message
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-age-of-oldest-message"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "ApproximateAgeOfOldestMessage"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].approximate_age_of_oldest_message
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateAgeOfOldestMessage>(>= ${local.effective_thresholds[each.key].approximate_age_of_oldest_message}s)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateAgeOfOldestMessageInQuietGroups (Fair Queues)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_age_of_oldest_message_in_quiet_groups" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_approximate_age_of_oldest_message_in_quiet_groups
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-age-of-oldest-message-in-quiet-groups"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "ApproximateAgeOfOldestMessageInQuietGroups"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].approximate_age_of_oldest_message_in_quiet_groups
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateAgeOfOldestMessageInQuietGroups>(>= ${local.effective_thresholds[each.key].approximate_age_of_oldest_message_in_quiet_groups}s)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfGroupsWithInflightMessages (FIFO only)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_groups_with_inflight_messages" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_approximate_number_of_groups_with_inflight_messages
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-groups-with-inflight-messages"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "ApproximateNumberOfGroupsWithInflightMessages"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_groups_with_inflight_messages
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfGroupsWithInflightMessages>(>= ${local.effective_thresholds[each.key].approximate_number_of_groups_with_inflight_messages})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesDelayed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_delayed" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_approximate_number_of_messages_delayed
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-delayed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "ApproximateNumberOfMessagesDelayed"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_messages_delayed
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfMessagesDelayed>(>= ${local.effective_thresholds[each.key].approximate_number_of_messages_delayed})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesDelayedInQuietGroups (Fair Queues)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_delayed_in_quiet_groups" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_approximate_number_of_messages_delayed_in_quiet_groups
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-delayed-in-quiet-groups"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "ApproximateNumberOfMessagesDelayedInQuietGroups"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_messages_delayed_in_quiet_groups
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfMessagesDelayedInQuietGroups>(>= ${local.effective_thresholds[each.key].approximate_number_of_messages_delayed_in_quiet_groups})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesNotVisible
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_not_visible" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_approximate_number_of_messages_not_visible
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-not-visible"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "ApproximateNumberOfMessagesNotVisible"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_messages_not_visible
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfMessagesNotVisible>(>= ${local.effective_thresholds[each.key].approximate_number_of_messages_not_visible})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesNotVisibleInQuietGroups (Fair Queues)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_not_visible_in_quiet_groups" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_approximate_number_of_messages_not_visible_in_quiet_groups
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-not-visible-in-quiet-groups"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "ApproximateNumberOfMessagesNotVisibleInQuietGroups"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_messages_not_visible_in_quiet_groups
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfMessagesNotVisibleInQuietGroups>(>= ${local.effective_thresholds[each.key].approximate_number_of_messages_not_visible_in_quiet_groups})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesVisible
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_visible" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_approximate_number_of_messages_visible
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-visible"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "ApproximateNumberOfMessagesVisible"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_messages_visible
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfMessagesVisible>(>= ${local.effective_thresholds[each.key].approximate_number_of_messages_visible})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfMessagesVisibleInQuietGroups (Fair Queues)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_visible_in_quiet_groups" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_approximate_number_of_messages_visible_in_quiet_groups
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-messages-visible-in-quiet-groups"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "ApproximateNumberOfMessagesVisibleInQuietGroups"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_messages_visible_in_quiet_groups
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfMessagesVisibleInQuietGroups>(>= ${local.effective_thresholds[each.key].approximate_number_of_messages_visible_in_quiet_groups})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ApproximateNumberOfNoisyGroups (Fair Queues)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "approximate_number_of_noisy_groups" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_approximate_number_of_noisy_groups
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-approximate-number-of-noisy-groups"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "ApproximateNumberOfNoisyGroups"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].approximate_number_of_noisy_groups
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS ApproximateNumberOfNoisyGroups>(>= ${local.effective_thresholds[each.key].approximate_number_of_noisy_groups})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfDeduplicatedSentMessages (FIFO only)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_deduplicated_sent_messages" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_deduplicated_sent_messages
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-number-of-deduplicated-sent-messages"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "NumberOfDeduplicatedSentMessages"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_deduplicated_sent_messages
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS NumberOfDeduplicatedSentMessages>(>= ${local.effective_thresholds[each.key].number_of_deduplicated_sent_messages})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfEmptyReceives
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_empty_receives" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_empty_receives
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-number-of-empty-receives"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "NumberOfEmptyReceives"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_empty_receives
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS NumberOfEmptyReceives>(>= ${local.effective_thresholds[each.key].number_of_empty_receives})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfMessagesDeleted
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_messages_deleted" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_messages_deleted
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-number-of-messages-deleted"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "NumberOfMessagesDeleted"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_messages_deleted
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS NumberOfMessagesDeleted>(>= ${local.effective_thresholds[each.key].number_of_messages_deleted})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfMessagesReceived
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_messages_received" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_messages_received
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-number-of-messages-received"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "NumberOfMessagesReceived"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_messages_received
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS NumberOfMessagesReceived>(>= ${local.effective_thresholds[each.key].number_of_messages_received})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfMessagesSent
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_messages_sent" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_messages_sent
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-number-of-messages-sent"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "NumberOfMessagesSent"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_messages_sent
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS NumberOfMessagesSent>(>= ${local.effective_thresholds[each.key].number_of_messages_sent})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For SentMessageSize
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "sent_message_size" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_sent_message_size
  }

  alarm_name                = "${var.name_prefix}metric-sqs-${each.value.name}-sent-message-size"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SQS"
  metric_name               = "SentMessageSize"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].sent_message_size
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SQS SentMessageSize>(>= ${local.effective_thresholds[each.key].sent_message_size} bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
