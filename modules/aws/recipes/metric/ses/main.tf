#--------------------------------------------------------------
# For SES
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  url           = "https://docs.aws.amazon.com/ses/latest/DeveloperGuide/reputationdashboard-cloudwatch-alarm.html"
  count         = length(var.dimensions) > 0 ? length(var.dimensions) : 1
  is_dimensions = length(var.dimensions) > 0 ? true : false
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# For Reputation.BounceRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "reputation_bouncerate" {
  count                     = var.is_enabled && var.threshold.enabled_reputation_bouncerate ? local.count : 0
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
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For Reputation.ComplaintRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "reputation_complaintrate" {
  count                     = var.is_enabled && var.threshold.enabled_reputation_complaintrate ? local.count : 0
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
  alarm_description         = "This is an alarm to check for <${local.url}|SES reputation complaintrate>(>= ${var.threshold.reputation_complaintrate}%)."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
