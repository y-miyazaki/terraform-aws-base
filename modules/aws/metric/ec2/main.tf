#--------------------------------------------------------------
# Module: aws/metric/ec2
# Purpose: Provide CloudWatch metric alarms for EC2 instances with optional auto-discovery (CPU, credits, metadata token use, status checks).
# Notes: Unified tagging; auto discovery filters instances via exclude list.
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
  dimension_key      = "InstanceId"
  exclude_list       = var.auto_dimensions_exclude_list
  include_list       = var.auto_dimensions_include_list
  manual_dimensions  = var.dimensions
  source_list        = data.aws_instances.this.ids
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html"

  # Use filtered results from helper module
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
}

#--------------------------------------------------------------
# For CPUCreditBalance
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].cpu_credit_balance.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 cpu credit balance>(<= ${local.effective_thresholds[each.key].cpu_credit_balance.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-cpu-credit-balance"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].cpu_credit_balance.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].cpu_credit_balance.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CPUCreditBalance"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].cpu_credit_balance.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUCreditUsage
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_credit_usage" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].cpu_credit_usage.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 cpu credit usage>(>= ${local.effective_thresholds[each.key].cpu_credit_usage.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-cpu-credit-usage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].cpu_credit_usage.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].cpu_credit_usage.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CPUCreditUsage"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].cpu_credit_usage.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].cpu_utilization.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 cpu utilization>(>= ${local.effective_thresholds[each.key].cpu_utilization.value}%)."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].cpu_utilization.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].cpu_utilization.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].cpu_utilization.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUSurplusCreditBalance
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_surplus_credit_balance" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].cpu_surplus_credit_balance.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 cpu surplus credit balance>(>= ${local.effective_thresholds[each.key].cpu_surplus_credit_balance.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-cpu-surplus-credit-balance"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].cpu_surplus_credit_balance.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].cpu_surplus_credit_balance.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CPUSurplusCreditBalance"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].cpu_surplus_credit_balance.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUSurplusCreditsCharged
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_surplus_credits_charged" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].cpu_surplus_credits_charged.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 cpu surplus credits charged>(>= ${local.effective_thresholds[each.key].cpu_surplus_credits_charged.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-cpu-surplus-credits-charged"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].cpu_surplus_credits_charged.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].cpu_surplus_credits_charged.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CPUSurplusCreditsCharged"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].cpu_surplus_credits_charged.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For DedicatedHostCPUUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dedicated_host_cpu_utilization" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].dedicated_host_cpu_utilization.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 dedicated host cpu utilization>(>= ${local.effective_thresholds[each.key].dedicated_host_cpu_utilization.value}%)."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-dedicated-host-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].dedicated_host_cpu_utilization.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].dedicated_host_cpu_utilization.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DedicatedHostCPUUtilization"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].dedicated_host_cpu_utilization.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For DiskReadBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "disk_read_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].disk_read_bytes.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 disk read bytes>(>= ${local.effective_thresholds[each.key].disk_read_bytes.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-disk-read-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].disk_read_bytes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].disk_read_bytes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DiskReadBytes"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].disk_read_bytes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For DiskReadOps
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "disk_read_ops" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].disk_read_ops.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 disk read ops>(>= ${local.effective_thresholds[each.key].disk_read_ops.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-disk-read-ops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].disk_read_ops.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].disk_read_ops.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DiskReadOps"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].disk_read_ops.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For DiskWriteBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "disk_write_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].disk_write_bytes.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 disk write bytes>(>= ${local.effective_thresholds[each.key].disk_write_bytes.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-disk-write-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].disk_write_bytes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].disk_write_bytes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DiskWriteBytes"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].disk_write_bytes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For DiskWriteOps
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "disk_write_ops" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].disk_write_ops.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 disk write ops>(>= ${local.effective_thresholds[each.key].disk_write_ops.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-disk-write-ops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].disk_write_ops.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].disk_write_ops.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DiskWriteOps"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].disk_write_ops.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For EBSByteBalance%
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ebs_byte_balance_percent" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].ebs_byte_balance_percent.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 ebs byte balance percent>(<= ${local.effective_thresholds[each.key].ebs_byte_balance_percent.value}%)."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-ebs-byte-balance-percent"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].ebs_byte_balance_percent.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].ebs_byte_balance_percent.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "EBSByteBalance%"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Minimum"
  threshold                 = local.effective_thresholds[each.key].ebs_byte_balance_percent.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For EBSIOBalance%
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ebs_io_balance_percent" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].ebs_io_balance_percent.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 ebs io balance percent>(<= ${local.effective_thresholds[each.key].ebs_io_balance_percent.value}%)."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-ebs-io-balance-percent"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].ebs_io_balance_percent.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].ebs_io_balance_percent.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "EBSIOBalance%"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Minimum"
  threshold                 = local.effective_thresholds[each.key].ebs_io_balance_percent.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For EBSReadBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ebs_read_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].ebs_read_bytes.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 ebs read bytes>(>= ${local.effective_thresholds[each.key].ebs_read_bytes.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-ebs-read-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].ebs_read_bytes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].ebs_read_bytes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "EBSReadBytes"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].ebs_read_bytes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For EBSReadOps
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ebs_read_ops" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].ebs_read_ops.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 ebs read ops>(>= ${local.effective_thresholds[each.key].ebs_read_ops.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-ebs-read-ops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].ebs_read_ops.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].ebs_read_ops.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "EBSReadOps"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].ebs_read_ops.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For EBSWriteBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ebs_write_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].ebs_write_bytes.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 ebs write bytes>(>= ${local.effective_thresholds[each.key].ebs_write_bytes.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-ebs-write-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].ebs_write_bytes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].ebs_write_bytes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "EBSWriteBytes"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].ebs_write_bytes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For EBSWriteOps
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ebs_write_ops" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].ebs_write_ops.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 ebs write ops>(>= ${local.effective_thresholds[each.key].ebs_write_ops.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-ebs-write-ops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].ebs_write_ops.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].ebs_write_ops.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "EBSWriteOps"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].ebs_write_ops.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For MetadataNoToken
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "metadata_no_token" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].metadata_no_token.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 metadata no token>(>= ${local.effective_thresholds[each.key].metadata_no_token.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-metadata-no-token"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].metadata_no_token.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].metadata_no_token.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "MetadataNoToken"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].metadata_no_token.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For MetadataNoTokenRejected
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "metadata_no_token_rejected" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].metadata_no_token_rejected.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 metadata no token rejected>(>= ${local.effective_thresholds[each.key].metadata_no_token_rejected.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-metadata-no-token-rejected"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].metadata_no_token_rejected.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].metadata_no_token_rejected.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "MetadataNoTokenRejected"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].metadata_no_token_rejected.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkIn
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_in" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].network_in.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 network in>(>= ${local.effective_thresholds[each.key].network_in.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-network-in"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].network_in.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].network_in.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NetworkIn"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].network_in.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkOut
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_out" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].network_out.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 network out>(>= ${local.effective_thresholds[each.key].network_out.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-network-out"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].network_out.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].network_out.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NetworkOut"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].network_out.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkPacketsIn
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_packets_in" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].network_packets_in.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 network packets in>(>= ${local.effective_thresholds[each.key].network_packets_in.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-network-packets-in"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].network_packets_in.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].network_packets_in.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NetworkPacketsIn"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].network_packets_in.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkPacketsOut
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_packets_out" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].network_packets_out.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 network packets out>(>= ${local.effective_thresholds[each.key].network_packets_out.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-network-packets-out"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].network_packets_out.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].network_packets_out.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NetworkPacketsOut"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].network_packets_out.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For StatusCheckFailed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].status_check_failed.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 status check failed>(>= ${local.effective_thresholds[each.key].status_check_failed.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-status-check-failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].status_check_failed.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].status_check_failed.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].status_check_failed.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For StatusCheckFailed_AttachedEBS
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "status_check_failed_attached_ebs" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].status_check_failed_attached_ebs.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 status check failed attached ebs>(>= ${local.effective_thresholds[each.key].status_check_failed_attached_ebs.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-status-check-failed-attached-ebs"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].status_check_failed_attached_ebs.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].status_check_failed_attached_ebs.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "StatusCheckFailed_AttachedEBS"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].status_check_failed_attached_ebs.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For StatusCheckFailed_Instance
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "status_check_failed_instance" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].status_check_failed_instance.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 status check failed instance>(>= ${local.effective_thresholds[each.key].status_check_failed_instance.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-status-check-failed-instance"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].status_check_failed_instance.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].status_check_failed_instance.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "StatusCheckFailed_Instance"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].status_check_failed_instance.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For StatusCheckFailed_System
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "status_check_failed_system" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].status_check_failed_system.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 status check failed system>(>= ${local.effective_thresholds[each.key].status_check_failed_system.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-status-check-failed-system"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].status_check_failed_system.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].status_check_failed_system.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].status_check_failed_system.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For InstanceEBSIOPSExceededCheck
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "instance_ebs_iops_exceeded_check" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].instance_ebs_iops_exceeded_check.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 instance EBS IOPS exceeded>(>= ${local.effective_thresholds[each.key].instance_ebs_iops_exceeded_check.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-instance-ebs-iops-exceeded-check"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].instance_ebs_iops_exceeded_check.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].instance_ebs_iops_exceeded_check.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "InstanceEBSIOPSExceededCheck"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].instance_ebs_iops_exceeded_check.value
  treat_missing_data        = "notBreaching"
  unit                      = "None"

  tags = var.tags
}

#--------------------------------------------------------------
# For InstanceEBSThroughputExceededCheck
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "instance_ebs_throughput_exceeded_check" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].instance_ebs_throughput_exceeded_check.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 instance EBS throughput exceeded>(>= ${local.effective_thresholds[each.key].instance_ebs_throughput_exceeded_check.value})."
  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-instance-ebs-throughput-exceeded-check"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].instance_ebs_throughput_exceeded_check.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].instance_ebs_throughput_exceeded_check.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "InstanceEBSThroughputExceededCheck"
  namespace                 = "AWS/EC2"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].instance_ebs_throughput_exceeded_check.value
  treat_missing_data        = "notBreaching"
  unit                      = "None"

  tags = var.tags
}
