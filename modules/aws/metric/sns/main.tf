#--------------------------------------------------------------
# Module: aws/metric/sns
# Purpose: Provide CloudWatch metric alarms for Amazon SNS topics (publish, delivery, filter, DLQ redrive metrics).
# Notes: Unified tagging; monitors topic-level metrics using TopicName dimension.
#        SMS metrics (SMSMonthToDateSpentUSD, SMSSuccessRate) are excluded because they use
#        different dimensions (PhoneNumber, no dimension) and are not topic-specific.
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
  dimension_key      = "TopicName"
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
    if var.is_enabled && local.effective_thresholds[k].number_of_messages_published.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfMessagesPublished>(>= ${local.effective_thresholds[each.key].number_of_messages_published.value})."
  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-messages-published"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_messages_published.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_messages_published.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfMessagesPublished"
  namespace                 = "AWS/SNS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_messages_published.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsDelivered
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_delivered" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_notifications_delivered.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsDelivered>(>= ${local.effective_thresholds[each.key].number_of_notifications_delivered.value})."
  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-delivered"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_notifications_delivered.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_notifications_delivered.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfNotificationsDelivered"
  namespace                 = "AWS/SNS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_delivered.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFailed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_failed" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_notifications_failed.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFailed>(>= ${local.effective_thresholds[each.key].number_of_notifications_failed.value})."
  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_notifications_failed.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_notifications_failed.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfNotificationsFailed"
  namespace                 = "AWS/SNS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_failed.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFailedToRedriveToDlq
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_failed_to_redrive_to_dlq" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_notifications_failed_to_redrive_to_dlq.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFailedToRedriveToDlq>(>= ${local.effective_thresholds[each.key].number_of_notifications_failed_to_redrive_to_dlq.value})."
  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-failed-to-redrive-to-dlq"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_notifications_failed_to_redrive_to_dlq.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_notifications_failed_to_redrive_to_dlq.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfNotificationsFailedToRedriveToDlq"
  namespace                 = "AWS/SNS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_failed_to_redrive_to_dlq.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFilteredOut
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_filtered_out" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_notifications_filtered_out.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFilteredOut>(>= ${local.effective_thresholds[each.key].number_of_notifications_filtered_out.value})."
  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-filtered-out"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_notifications_filtered_out.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_notifications_filtered_out.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfNotificationsFilteredOut"
  namespace                 = "AWS/SNS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_filtered_out.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFilteredOut-InvalidAttributes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_filtered_out_invalid_attributes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_notifications_filtered_out_invalid_attributes.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFilteredOut-InvalidAttributes>(>= ${local.effective_thresholds[each.key].number_of_notifications_filtered_out_invalid_attributes.value})."
  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-filtered-out-invalid-attributes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_notifications_filtered_out_invalid_attributes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_notifications_filtered_out_invalid_attributes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfNotificationsFilteredOut-InvalidAttributes"
  namespace                 = "AWS/SNS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_filtered_out_invalid_attributes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFilteredOut-InvalidMessageBody
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_filtered_out_invalid_message_body" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_notifications_filtered_out_invalid_message_body.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFilteredOut-InvalidMessageBody>(>= ${local.effective_thresholds[each.key].number_of_notifications_filtered_out_invalid_message_body.value})."
  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-filtered-out-invalid-message-body"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_notifications_filtered_out_invalid_message_body.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_notifications_filtered_out_invalid_message_body.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfNotificationsFilteredOut-InvalidMessageBody"
  namespace                 = "AWS/SNS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_filtered_out_invalid_message_body.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFilteredOut-MessageAttributes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_filtered_out_message_attributes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_notifications_filtered_out_message_attributes.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFilteredOut-MessageAttributes>(>= ${local.effective_thresholds[each.key].number_of_notifications_filtered_out_message_attributes.value})."
  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-filtered-out-message-attributes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_notifications_filtered_out_message_attributes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_notifications_filtered_out_message_attributes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfNotificationsFilteredOut-MessageAttributes"
  namespace                 = "AWS/SNS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_filtered_out_message_attributes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFilteredOut-MessageBody
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_filtered_out_message_body" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_notifications_filtered_out_message_body.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFilteredOut-MessageBody>(>= ${local.effective_thresholds[each.key].number_of_notifications_filtered_out_message_body.value})."
  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-filtered-out-message-body"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_notifications_filtered_out_message_body.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_notifications_filtered_out_message_body.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfNotificationsFilteredOut-MessageBody"
  namespace                 = "AWS/SNS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_filtered_out_message_body.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsFilteredOut-NoMessageAttributes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_filtered_out_no_message_attributes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_notifications_filtered_out_no_message_attributes.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsFilteredOut-NoMessageAttributes>(>= ${local.effective_thresholds[each.key].number_of_notifications_filtered_out_no_message_attributes.value})."
  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-filtered-out-no-message-attributes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_notifications_filtered_out_no_message_attributes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_notifications_filtered_out_no_message_attributes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfNotificationsFilteredOut-NoMessageAttributes"
  namespace                 = "AWS/SNS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_filtered_out_no_message_attributes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumberOfNotificationsRedrivenToDlq
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "number_of_notifications_redriven_to_dlq" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].number_of_notifications_redriven_to_dlq.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS NumberOfNotificationsRedrivenToDlq>(>= ${local.effective_thresholds[each.key].number_of_notifications_redriven_to_dlq.value})."
  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-number-of-notifications-redriven-to-dlq"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].number_of_notifications_redriven_to_dlq.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].number_of_notifications_redriven_to_dlq.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumberOfNotificationsRedrivenToDlq"
  namespace                 = "AWS/SNS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].number_of_notifications_redriven_to_dlq.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For PublishSize
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "publish_size" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].publish_size.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SNS PublishSize>(>= ${local.effective_thresholds[each.key].publish_size.value} bytes)."
  alarm_name                = "${var.name_prefix}metric-sns-${each.value.name}-publish-size"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].publish_size.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].publish_size.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "PublishSize"
  namespace                 = "AWS/SNS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].publish_size.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

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
