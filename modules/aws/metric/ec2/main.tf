#--------------------------------------------------------------
# For EC2
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  url = "https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html"
  auto_dimensions = var.create_auto_dimensions ? [
    for v in data.aws_instances.this.ids : v if !anytrue([for el in var.auto_dimensions_exclude_list : strcontains(v, el)])
  ] : []
  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : v => {
      name = v
      dimensions = {
        "InstanceId" = v
      }
    }
    } : {
    for v in var.dimensions : v.InstanceId => {
      name       = v.InstanceId
      dimensions = v
    }
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# For CPUUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  for_each                  = var.is_enabled && var.threshold.enabled_cpu_utilization ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "CPUUtilization"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.cpu_utilization
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 cpu utilization>(>= ${var.threshold.cpu_utilization}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For MetadataNoToken
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "metadata_no_token" {
  for_each                  = var.is_enabled && var.threshold.enabled_metadata_no_token ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-metadata-no-token"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "MetadataNoToken"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.metadata_no_token
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 metadata no token>(>= ${var.threshold.metadata_no_token})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For CPUCreditUsage
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_credit_usage" {
  for_each                  = var.is_enabled && var.threshold.enabled_cpu_credit_usage ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-cpu-credit-usage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "CPUCreditUsage"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.cpu_credit_usage
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 cpu credit usage>(>= ${var.threshold.cpu_credit_usage})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For StatusCheckFailed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  for_each                  = var.is_enabled && var.threshold.enabled_status_check_failed ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-status-check-failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "StatusCheckFailed"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.status_check_failed
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 status check failed>(>= ${var.threshold.status_check_failed})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
