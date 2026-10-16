#--------------------------------------------------------------
# Module: aws/metric/nat_gateway
# Purpose: Provide CloudWatch metric alarms for NAT Gateways with optional auto-discovery (bytes, packets, connections, errors).
# Notes: Unified tagging; auto discovery filters NAT Gateways via exclude/include list.
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
  dimension_key      = "NatGatewayId"
  exclude_list       = var.auto_dimensions_exclude_list
  include_list       = var.auto_dimensions_include_list
  manual_dimensions  = var.dimensions
  source_list        = data.aws_nat_gateways.this.ids
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/vpc/latest/userguide/metrics-dimensions-nat-gateway.html"

  # Use filtered results from helper module
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
}

#--------------------------------------------------------------
# For ActiveConnectionCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "active_connection_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].active_connection_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway active connection count>(>= ${local.effective_thresholds[each.key].active_connection_count.value})."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-active-connection-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].active_connection_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].active_connection_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ActiveConnectionCount"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].active_connection_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For BytesOutToDestination
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bytes_out_to_destination" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].bytes_out_to_destination.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway bytes out to destination>(>= ${local.effective_thresholds[each.key].bytes_out_to_destination.value} bytes)."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-bytes-out-to-destination"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].bytes_out_to_destination.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].bytes_out_to_destination.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "BytesOutToDestination"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].bytes_out_to_destination.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For BytesInFromSource
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bytes_in_from_source" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].bytes_in_from_source.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway bytes in from source>(>= ${local.effective_thresholds[each.key].bytes_in_from_source.value} bytes)."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-bytes-in-from-source"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].bytes_in_from_source.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].bytes_in_from_source.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "BytesInFromSource"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].bytes_in_from_source.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For BytesInFromDestination
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bytes_in_from_destination" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].bytes_in_from_destination.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway bytes in from destination>(>= ${local.effective_thresholds[each.key].bytes_in_from_destination.value} bytes)."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-bytes-in-from-destination"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].bytes_in_from_destination.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].bytes_in_from_destination.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "BytesInFromDestination"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].bytes_in_from_destination.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For BytesOutToSource
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bytes_out_to_source" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].bytes_out_to_source.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway bytes out to source>(>= ${local.effective_thresholds[each.key].bytes_out_to_source.value} bytes)."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-bytes-out-to-source"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].bytes_out_to_source.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].bytes_out_to_source.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "BytesOutToSource"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].bytes_out_to_source.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For ConnectionAttemptCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "connection_attempt_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].connection_attempt_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway connection attempt count>(>= ${local.effective_thresholds[each.key].connection_attempt_count.value})."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-connection-attempt-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].connection_attempt_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].connection_attempt_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ConnectionAttemptCount"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].connection_attempt_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ConnectionEstablishedCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "connection_established_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].connection_established_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway connection established count>(>= ${local.effective_thresholds[each.key].connection_established_count.value})."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-connection-established-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].connection_established_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].connection_established_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ConnectionEstablishedCount"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].connection_established_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ErrorPortAllocation
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_port_allocation" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].error_port_allocation.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway error port allocation>(>= ${local.effective_thresholds[each.key].error_port_allocation.value})."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-error-port-allocation"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].error_port_allocation.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].error_port_allocation.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ErrorPortAllocation"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].error_port_allocation.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For IdleTimeoutCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "idle_timeout_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].idle_timeout_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway idle timeout count>(>= ${local.effective_thresholds[each.key].idle_timeout_count.value})."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-idle-timeout-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].idle_timeout_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].idle_timeout_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "IdleTimeoutCount"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].idle_timeout_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For PacketsDropCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "packets_drop_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].packets_drop_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets drop count>(>= ${local.effective_thresholds[each.key].packets_drop_count.value})."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-drop-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].packets_drop_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].packets_drop_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "PacketsDropCount"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].packets_drop_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For PacketsInFromDestination
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "packets_in_from_destination" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].packets_in_from_destination.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets in from destination>(>= ${local.effective_thresholds[each.key].packets_in_from_destination.value})."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-in-from-destination"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].packets_in_from_destination.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].packets_in_from_destination.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "PacketsInFromDestination"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].packets_in_from_destination.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For PacketsInFromSource
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "packets_in_from_source" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].packets_in_from_source.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets in from source>(>= ${local.effective_thresholds[each.key].packets_in_from_source.value})."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-in-from-source"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].packets_in_from_source.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].packets_in_from_source.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "PacketsInFromSource"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].packets_in_from_source.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For PacketsOutToDestination
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "packets_out_to_destination" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].packets_out_to_destination.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets out to destination>(>= ${local.effective_thresholds[each.key].packets_out_to_destination.value})."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-out-to-destination"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].packets_out_to_destination.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].packets_out_to_destination.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "PacketsOutToDestination"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].packets_out_to_destination.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For PacketsOutToSource
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "packets_out_to_source" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].packets_out_to_source.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets out to source>(>= ${local.effective_thresholds[each.key].packets_out_to_source.value})."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-out-to-source"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].packets_out_to_source.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].packets_out_to_source.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "PacketsOutToSource"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].packets_out_to_source.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For PeakBytesPerSecond
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "peak_bytes_per_second" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].peak_bytes_per_second.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway peak bytes per second>(>= ${local.effective_thresholds[each.key].peak_bytes_per_second.value} bytes/sec)."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-peak-bytes-per-second"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].peak_bytes_per_second.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].peak_bytes_per_second.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "PeakBytesPerSecond"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].peak_bytes_per_second.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes/Second"

  tags = var.tags
}

#--------------------------------------------------------------
# For PeakPacketsPerSecond
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "peak_packets_per_second" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].peak_packets_per_second.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway peak packets per second>(>= ${local.effective_thresholds[each.key].peak_packets_per_second.value} packets/sec)."
  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-peak-packets-per-second"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].peak_packets_per_second.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].peak_packets_per_second.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "PeakPacketsPerSecond"
  namespace                 = "AWS/NATGateway"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].peak_packets_per_second.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count/Second"

  tags = var.tags
}
