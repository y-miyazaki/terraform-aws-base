#--------------------------------------------------------------
# Module: aws/metric/ses
# Purpose: Provide CloudWatch metric alarms for SES sending quality metrics.
# Notes: Unified tagging; supports optional dimension filtering for multiple identities.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url           = "https://docs.aws.amazon.com/ses/latest/DeveloperGuide/monitor-sending-activity.html"
  count         = length(var.dimensions) > 0 ? length(var.dimensions) : 1
  is_dimensions = length(var.dimensions) > 0 ? true : false
}

#--------------------------------------------------------------
# For Reputation.BounceRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "reputation_bouncerate" {
  count = var.is_enabled && var.threshold.enabled_reputation_bouncerate ? local.count : 0

  alarm_name                = "${var.name_prefix}metric-ses-reputation-bouncerate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SES"
  metric_name               = "Reputation.BounceRate"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.reputation_bouncerate
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES reputation bouncerate>(>= ${var.threshold.reputation_bouncerate}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null

  tags = var.tags
}

#--------------------------------------------------------------
# For Reputation.ComplaintRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "reputation_complaintrate" {
  count = var.is_enabled && var.threshold.enabled_reputation_complaintrate ? local.count : 0

  alarm_name                = "${var.name_prefix}metric-ses-reputation-complaintrate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SES"
  metric_name               = "Reputation.ComplaintRate"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.reputation_complaintrate
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES reputation complaint rate>(>= ${var.threshold.reputation_complaintrate}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null

  tags = var.tags
}

#--------------------------------------------------------------
# For Reject
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "reject" {
  count = var.is_enabled && var.threshold.enabled_reject ? local.count : 0

  alarm_name                = "${var.name_prefix}metric-ses-reject"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SES"
  metric_name               = "Reject"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.reject
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES reject count>(>= ${var.threshold.reject}). ISP rejected the email."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null

  tags = var.tags
}

#--------------------------------------------------------------
# For Bounce
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bounce" {
  count = var.is_enabled && var.threshold.enabled_bounce ? local.count : 0

  alarm_name                = "${var.name_prefix}metric-ses-bounce"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SES"
  metric_name               = "Bounce"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.bounce
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES bounce count>(>= ${var.threshold.bounce}). Email bounced back."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null

  tags = var.tags
}

#--------------------------------------------------------------
# For Complaint
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "complaint" {
  count = var.is_enabled && var.threshold.enabled_complaint ? local.count : 0

  alarm_name                = "${var.name_prefix}metric-ses-complaint"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SES"
  metric_name               = "Complaint"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.complaint
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES complaint count>(>= ${var.threshold.complaint}). Recipient marked as spam."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null

  tags = var.tags
}

#--------------------------------------------------------------
# For Send
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "send" {
  count = var.is_enabled && var.threshold.enabled_send ? local.count : 0

  alarm_name                = "${var.name_prefix}metric-ses-send"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SES"
  metric_name               = "Send"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.send
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES send count>(>= ${var.threshold.send}). Total send attempts."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null

  tags = var.tags
}

#--------------------------------------------------------------
# For Delivery
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "delivery" {
  count = var.is_enabled && var.threshold.enabled_delivery ? local.count : 0

  alarm_name                = "${var.name_prefix}metric-ses-delivery"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/SES"
  metric_name               = "Delivery"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.delivery
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES delivery count>(>= ${var.threshold.delivery}). Successful deliveries."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null

  tags = var.tags
}
