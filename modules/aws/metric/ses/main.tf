#--------------------------------------------------------------
# Module: aws/metric/ses
# Purpose: Provide CloudWatch metric alarms for SES sending quality metrics.
# Notes: Unified tagging; supports optional dimension filtering for multiple identities.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}
module "helper" {
  source = "../../_internal/metric_helper"

  is_enabled = var.is_enabled
  region     = local.region

  base_threshold     = var.threshold
  dimension_key      = "ConfigurationSetName"
  manual_dimensions  = local.manual_dimensions
  threshold_override = var.threshold_override
}

locals {
  url = "https://docs.aws.amazon.com/ses/latest/DeveloperGuide/monitor-sending-activity.html"

  is_dimensions = length(var.dimensions) > 0
  # Without dimensions, SES account-level alarms are created under the reserved "default" key (do not use "default" as a real dimension value).
  manual_dimensions = local.is_dimensions ? var.dimensions : [{ ConfigurationSetName = "default" }]

  # Use filtered results from helper module
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
  alarm_name_infix     = { for k, v in module.helper.list : k => local.is_dimensions ? "${v.name}-" : "" }
}

#--------------------------------------------------------------
# For Reputation.BounceRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "reputation_bouncerate" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].reputation_bouncerate.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES reputation bouncerate>(>= ${local.effective_thresholds[each.key].reputation_bouncerate.value}%)."
  alarm_name                = "${var.name_prefix}metric-ses-${local.alarm_name_infix[each.key]}reputation-bouncerate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].reputation_bouncerate.datapoints_to_alarm
  dimensions                = local.is_dimensions ? each.value.dimensions : null
  evaluation_periods        = local.effective_thresholds[each.key].reputation_bouncerate.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Reputation.BounceRate"
  namespace                 = "AWS/SES"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].reputation_bouncerate.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For Reputation.ComplaintRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "reputation_complaintrate" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].reputation_complaintrate.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES reputation complaint rate>(>= ${local.effective_thresholds[each.key].reputation_complaintrate.value}%)."
  alarm_name                = "${var.name_prefix}metric-ses-${local.alarm_name_infix[each.key]}reputation-complaintrate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].reputation_complaintrate.datapoints_to_alarm
  dimensions                = local.is_dimensions ? each.value.dimensions : null
  evaluation_periods        = local.effective_thresholds[each.key].reputation_complaintrate.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Reputation.ComplaintRate"
  namespace                 = "AWS/SES"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].reputation_complaintrate.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For Reject
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "reject" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].reject.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES reject count>(>= ${local.effective_thresholds[each.key].reject.value}). ISP rejected the email."
  alarm_name                = "${var.name_prefix}metric-ses-${local.alarm_name_infix[each.key]}reject"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].reject.datapoints_to_alarm
  dimensions                = local.is_dimensions ? each.value.dimensions : null
  evaluation_periods        = local.effective_thresholds[each.key].reject.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Reject"
  namespace                 = "AWS/SES"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].reject.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For Bounce
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bounce" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].bounce.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES bounce count>(>= ${local.effective_thresholds[each.key].bounce.value}). Email bounced back."
  alarm_name                = "${var.name_prefix}metric-ses-${local.alarm_name_infix[each.key]}bounce"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].bounce.datapoints_to_alarm
  dimensions                = local.is_dimensions ? each.value.dimensions : null
  evaluation_periods        = local.effective_thresholds[each.key].bounce.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Bounce"
  namespace                 = "AWS/SES"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].bounce.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For Complaint
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "complaint" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].complaint.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES complaint count>(>= ${local.effective_thresholds[each.key].complaint.value}). Recipient marked as spam."
  alarm_name                = "${var.name_prefix}metric-ses-${local.alarm_name_infix[each.key]}complaint"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].complaint.datapoints_to_alarm
  dimensions                = local.is_dimensions ? each.value.dimensions : null
  evaluation_periods        = local.effective_thresholds[each.key].complaint.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Complaint"
  namespace                 = "AWS/SES"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].complaint.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For Send
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "send" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].send.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES send count>(>= ${local.effective_thresholds[each.key].send.value}). Total send attempts."
  alarm_name                = "${var.name_prefix}metric-ses-${local.alarm_name_infix[each.key]}send"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].send.datapoints_to_alarm
  dimensions                = local.is_dimensions ? each.value.dimensions : null
  evaluation_periods        = local.effective_thresholds[each.key].send.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Send"
  namespace                 = "AWS/SES"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].send.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For Delivery
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "delivery" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].delivery.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|SES delivery count>(>= ${local.effective_thresholds[each.key].delivery.value}). Successful deliveries."
  alarm_name                = "${var.name_prefix}metric-ses-${local.alarm_name_infix[each.key]}delivery"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].delivery.datapoints_to_alarm
  dimensions                = local.is_dimensions ? each.value.dimensions : null
  evaluation_periods        = local.effective_thresholds[each.key].delivery.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Delivery"
  namespace                 = "AWS/SES"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].delivery.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}
