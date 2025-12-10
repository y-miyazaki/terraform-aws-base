#--------------------------------------------------------------
# Module: aws/metric/ec2
# Purpose: Provide CloudWatch metric alarms for EC2 instances with optional auto-discovery (CPU, credits, metadata token use, status checks).
# Notes: Unified tagging; auto discovery filters instances via exclude list.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "filter" {
  source     = "../../_internal/auto_discovery_filter"
  is_enabled = var.is_enabled

  create_auto       = var.create_auto_dimensions
  source_list       = data.aws_instances.this.ids
  include_list      = var.auto_dimensions_include_list
  exclude_list      = var.auto_dimensions_exclude_list
  manual_dimensions = var.dimensions
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html"

  # Use filtered results from helper module
  auto_dimensions = module.filter.filtered_list
  safe_dimensions = module.filter.safe_manual_dimensions

  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : v => {
      name = v
      dimensions = {
        "InstanceId" = v
      }
    }
    } : {
    for v in local.safe_dimensions : v.InstanceId => {
      name       = v.InstanceId
      dimensions = v
    } if v != null && try(v.InstanceId, null) != null && v.InstanceId != ""
  }
}

#--------------------------------------------------------------
# For CPUCreditBalance
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance" {
  for_each = var.is_enabled && var.threshold.enabled_cpu_credit_balance ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-cpu-credit-balance"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "CPUCreditBalance"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.cpu_credit_balance
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 cpu credit balance>(<= ${var.threshold.cpu_credit_balance})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUCreditUsage
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_credit_usage" {
  for_each = var.is_enabled && var.threshold.enabled_cpu_credit_usage ? local.list : {}

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

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  for_each = var.is_enabled && var.threshold.enabled_cpu_utilization ? local.list : {}

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

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUSurplusCreditBalance
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_surplus_credit_balance" {
  for_each = var.is_enabled && var.threshold.enabled_cpu_surplus_credit_balance ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-cpu-surplus-credit-balance"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "CPUSurplusCreditBalance"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.cpu_surplus_credit_balance
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 cpu surplus credit balance>(>= ${var.threshold.cpu_surplus_credit_balance})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUSurplusCreditsCharged
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_surplus_credits_charged" {
  for_each = var.is_enabled && var.threshold.enabled_cpu_surplus_credits_charged ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-cpu-surplus-credits-charged"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "CPUSurplusCreditsCharged"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.cpu_surplus_credits_charged
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 cpu surplus credits charged>(>= ${var.threshold.cpu_surplus_credits_charged})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DedicatedHostCPUUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dedicated_host_cpu_utilization" {
  for_each = var.is_enabled && var.threshold.enabled_dedicated_host_cpu_utilization ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-dedicated-host-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "DedicatedHostCPUUtilization"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.dedicated_host_cpu_utilization
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 dedicated host cpu utilization>(>= ${var.threshold.dedicated_host_cpu_utilization}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DiskReadBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "disk_read_bytes" {
  for_each = var.is_enabled && var.threshold.enabled_disk_read_bytes ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-disk-read-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "DiskReadBytes"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.disk_read_bytes
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 disk read bytes>(>= ${var.threshold.disk_read_bytes})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DiskReadOps
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "disk_read_ops" {
  for_each = var.is_enabled && var.threshold.enabled_disk_read_ops ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-disk-read-ops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "DiskReadOps"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.disk_read_ops
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 disk read ops>(>= ${var.threshold.disk_read_ops})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DiskWriteBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "disk_write_bytes" {
  for_each = var.is_enabled && var.threshold.enabled_disk_write_bytes ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-disk-write-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "DiskWriteBytes"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.disk_write_bytes
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 disk write bytes>(>= ${var.threshold.disk_write_bytes})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DiskWriteOps
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "disk_write_ops" {
  for_each = var.is_enabled && var.threshold.enabled_disk_write_ops ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-disk-write-ops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "DiskWriteOps"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.disk_write_ops
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 disk write ops>(>= ${var.threshold.disk_write_ops})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For EBSByteBalance%
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ebs_byte_balance_percent" {
  for_each = var.is_enabled && var.threshold.enabled_ebs_byte_balance_percent ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-ebs-byte-balance-percent"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "EBSByteBalance%"
  period                    = var.period
  statistic                 = "Minimum"
  threshold                 = var.threshold.ebs_byte_balance_percent
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 ebs byte balance percent>(<= ${var.threshold.ebs_byte_balance_percent}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For EBSIOBalance%
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ebs_io_balance_percent" {
  for_each = var.is_enabled && var.threshold.enabled_ebs_io_balance_percent ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-ebs-io-balance-percent"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "EBSIOBalance%"
  period                    = var.period
  statistic                 = "Minimum"
  threshold                 = var.threshold.ebs_io_balance_percent
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 ebs io balance percent>(<= ${var.threshold.ebs_io_balance_percent}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For EBSReadBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ebs_read_bytes" {
  for_each = var.is_enabled && var.threshold.enabled_ebs_read_bytes ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-ebs-read-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "EBSReadBytes"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.ebs_read_bytes
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 ebs read bytes>(>= ${var.threshold.ebs_read_bytes})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For EBSReadOps
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ebs_read_ops" {
  for_each = var.is_enabled && var.threshold.enabled_ebs_read_ops ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-ebs-read-ops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "EBSReadOps"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.ebs_read_ops
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 ebs read ops>(>= ${var.threshold.ebs_read_ops})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For EBSWriteBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ebs_write_bytes" {
  for_each = var.is_enabled && var.threshold.enabled_ebs_write_bytes ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-ebs-write-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "EBSWriteBytes"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.ebs_write_bytes
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 ebs write bytes>(>= ${var.threshold.ebs_write_bytes})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For EBSWriteOps
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ebs_write_ops" {
  for_each = var.is_enabled && var.threshold.enabled_ebs_write_ops ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-ebs-write-ops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "EBSWriteOps"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.ebs_write_ops
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 ebs write ops>(>= ${var.threshold.ebs_write_ops})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For MetadataNoToken
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "metadata_no_token" {
  for_each = var.is_enabled && var.threshold.enabled_metadata_no_token ? local.list : {}

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

  tags = var.tags
}

#--------------------------------------------------------------
# For MetadataNoTokenRejected
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "metadata_no_token_rejected" {
  for_each = var.is_enabled && var.threshold.enabled_metadata_no_token_rejected ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-metadata-no-token-rejected"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "MetadataNoTokenRejected"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.metadata_no_token_rejected
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 metadata no token rejected>(>= ${var.threshold.metadata_no_token_rejected})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkIn
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_in" {
  for_each = var.is_enabled && var.threshold.enabled_network_in ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-network-in"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "NetworkIn"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.network_in
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 network in>(>= ${var.threshold.network_in})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkOut
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_out" {
  for_each = var.is_enabled && var.threshold.enabled_network_out ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-network-out"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "NetworkOut"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.network_out
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 network out>(>= ${var.threshold.network_out})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkPacketsIn
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_packets_in" {
  for_each = var.is_enabled && var.threshold.enabled_network_packets_in ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-network-packets-in"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "NetworkPacketsIn"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.network_packets_in
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 network packets in>(>= ${var.threshold.network_packets_in})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkPacketsOut
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_packets_out" {
  for_each = var.is_enabled && var.threshold.enabled_network_packets_out ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-network-packets-out"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "NetworkPacketsOut"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.network_packets_out
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 network packets out>(>= ${var.threshold.network_packets_out})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For StatusCheckFailed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  for_each = var.is_enabled && var.threshold.enabled_status_check_failed ? local.list : {}

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

  tags = var.tags
}

#--------------------------------------------------------------
# For StatusCheckFailed_AttachedEBS
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "status_check_failed_attached_ebs" {
  for_each = var.is_enabled && var.threshold.enabled_status_check_failed_attached_ebs ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-status-check-failed-attached-ebs"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "StatusCheckFailed_AttachedEBS"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.status_check_failed_attached_ebs
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 status check failed attached ebs>(>= ${var.threshold.status_check_failed_attached_ebs})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For StatusCheckFailed_Instance
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "status_check_failed_instance" {
  for_each = var.is_enabled && var.threshold.enabled_status_check_failed_instance ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-status-check-failed-instance"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "StatusCheckFailed_Instance"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.status_check_failed_instance
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 status check failed instance>(>= ${var.threshold.status_check_failed_instance})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For StatusCheckFailed_System
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "status_check_failed_system" {
  for_each = var.is_enabled && var.threshold.enabled_status_check_failed_system ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-ec2-${each.value.name}-status-check-failed-system"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/EC2"
  metric_name               = "StatusCheckFailed_System"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.status_check_failed_system
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|EC2 status check failed system>(>= ${var.threshold.status_check_failed_system})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
