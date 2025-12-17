#--------------------------------------------------------------
# Module: aws/metric/sns
# Purpose: Provide CloudWatch metric alarms for Amazon SNS topics (publish, delivery, filter, DLQ redrive metrics).
# Notes: Unified tagging; monitors topic-level metrics using TopicName dimension.
#        SMS metrics (SMSMonthToDateSpentUSD, SMSSuccessRate) are excluded because they use
#        different dimensions (PhoneNumber, no dimension) and are not topic-specific.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "helper" {
  source     = "../../_internal/metric_helper"
  is_enabled = var.is_enabled

  create_auto        = var.create_auto_dimensions
  source_list        = var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list) : []
  include_list       = var.auto_dimensions_include_list
  exclude_list       = var.auto_dimensions_exclude_list
  manual_dimensions  = var.dimensions
  dimension_key      = "TopicName"
  base_threshold     = var.threshold
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/sns/latest/dg/sns-monitoring-using-cloudwatch.html"

  # Use filtered results from helper module
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
}

#--------------------------------------------------------------
# For NumberOfMessagesPublished
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_messages_published" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_messages_published
  }

  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-messages-published"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SNS"
  metric_name               = "NumberOfMessagesPublished"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_messages_published
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfMessagesPublished>(>= ${local.effective_thresholds[each.key].number_of_messages_published})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsDelivered
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_delivered" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_notifications_delivered
  }

  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-delivered"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SNS"
  metric_name               = "NumberOfNotificationsDelivered"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_delivered
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsDelivered>(>= ${local.effective_thresholds[each.key].number_of_notifications_delivered})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFailed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_failed" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_notifications_failed
  }

  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SNS"
  metric_name               = "NumberOfNotificationsFailed"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_failed
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFailed>(>= ${local.effective_thresholds[each.key].number_of_notifications_failed})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFailedToRedriveToDlq
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_failed_to_redrive_to_dlq" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_notifications_failed_to_redrive_to_dlq
  }

  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-failed-to-redrive-to-dlq"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SNS"
  metric_name               = "NumberOfNotificationsFailedToRedriveToDlq"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_failed_to_redrive_to_dlq
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFailedToRedriveToDlq>(>= ${local.effective_thresholds[each.key].number_of_notifications_failed_to_redrive_to_dlq})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFilteredOut
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_filtered_out" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_notifications_filtered_out
  }

  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-filtered-out"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SNS"
  metric_name               = "NumberOfNotificationsFilteredOut"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_filtered_out
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFilteredOut>(>= ${local.effective_thresholds[each.key].number_of_notifications_filtered_out})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFilteredOut-InvalidAttributes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_filtered_out_invalid_attributes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_notifications_filtered_out_invalid_attributes
  }

  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-filtered-out-invalid-attributes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SNS"
  metric_name               = "NumberOfNotificationsFilteredOut-InvalidAttributes"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_filtered_out_invalid_attributes
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFilteredOut-InvalidAttributes>(>= ${local.effective_thresholds[each.key].number_of_notifications_filtered_out_invalid_attributes})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFilteredOut-InvalidMessageBody
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_filtered_out_invalid_message_body" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_notifications_filtered_out_invalid_message_body
  }

  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-filtered-out-invalid-message-body"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SNS"
  metric_name               = "NumberOfNotificationsFilteredOut-InvalidMessageBody"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_filtered_out_invalid_message_body
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFilteredOut-InvalidMessageBody>(>= ${local.effective_thresholds[each.key].number_of_notifications_filtered_out_invalid_message_body})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFilteredOut-MessageAttributes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_filtered_out_message_attributes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_notifications_filtered_out_message_attributes
  }

  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-filtered-out-message-attributes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SNS"
  metric_name               = "NumberOfNotificationsFilteredOut-MessageAttributes"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_filtered_out_message_attributes
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFilteredOut-MessageAttributes>(>= ${local.effective_thresholds[each.key].number_of_notifications_filtered_out_message_attributes})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFilteredOut-MessageBody
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_filtered_out_message_body" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_notifications_filtered_out_message_body
  }

  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-filtered-out-message-body"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SNS"
  metric_name               = "NumberOfNotificationsFilteredOut-MessageBody"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_filtered_out_message_body
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFilteredOut-MessageBody>(>= ${local.effective_thresholds[each.key].number_of_notifications_filtered_out_message_body})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFilteredOut-NoMessageAttributes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_filtered_out_no_message_attributes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_notifications_filtered_out_no_message_attributes
  }

  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-filtered-out-no-message-attributes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SNS"
  metric_name               = "NumberOfNotificationsFilteredOut-NoMessageAttributes"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_filtered_out_no_message_attributes
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFilteredOut-NoMessageAttributes>(>= ${local.effective_thresholds[each.key].number_of_notifications_filtered_out_no_message_attributes})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsRedrivenToDlq
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_redriven_to_dlq" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_number_of_notifications_redriven_to_dlq
  }

  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-redriven-to-dlq"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SNS"
  metric_name               = "NumberOfNotificationsRedrivenToDlq"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_redriven_to_dlq
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsRedrivenToDlq>(>= ${local.effective_thresholds[each.key].number_of_notifications_redriven_to_dlq})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PublishSize
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "publish_size" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_publish_size
  }

  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-publish-size"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SNS"
  metric_name               = "PublishSize"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].publish_size
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS PublishSize>(>= ${local.effective_thresholds[each.key].publish_size} bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# SMS Metrics are excluded from this module:
#
# - SMSMonthToDateSpentUSD: Uses no dimension (account-level metric)
# - SMSSuccessRate: Uses PhoneNumber dimension
#
# These metrics are not topic-specific and require different dimensions.
# Consider creating a separate sns_sms module if SMS monitoring is needed.
#--------------------------------------------------------------
