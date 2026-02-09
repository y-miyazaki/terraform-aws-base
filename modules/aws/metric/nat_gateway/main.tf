#--------------------------------------------------------------
# Module: aws/metric/nat_gateway
# Purpose: Provide CloudWatch metric alarms for NAT Gateways with optional auto-discovery (bytes, packets, connections, errors).
# Notes: Unified tagging; auto discovery filters NAT Gateways via exclude/include list.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "helper" {
  source     = "../../_internal/metric_helper"
  is_enabled = var.is_enabled

  create_auto        = var.create_auto_dimensions
  source_list        = data.aws_nat_gateways.this.ids
  include_list       = var.auto_dimensions_include_list
  exclude_list       = var.auto_dimensions_exclude_list
  manual_dimensions  = var.dimensions
  dimension_key      = "NatGatewayId"
  base_threshold     = var.threshold
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
    if var.is_enabled && local.effective_thresholds[k].enabled_active_connection_count
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-active-connection-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "ActiveConnectionCount"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].active_connection_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway active connection count>(>= ${local.effective_thresholds[each.key].active_connection_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For BytesOutToDestination
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bytes_out_to_destination" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_bytes_out_to_destination
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-bytes-out-to-destination"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "BytesOutToDestination"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].bytes_out_to_destination
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway bytes out to destination>(>= ${local.effective_thresholds[each.key].bytes_out_to_destination} bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For BytesInFromSource
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bytes_in_from_source" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_bytes_in_from_source
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-bytes-in-from-source"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "BytesInFromSource"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].bytes_in_from_source
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway bytes in from source>(>= ${local.effective_thresholds[each.key].bytes_in_from_source} bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For BytesInFromDestination
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bytes_in_from_destination" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_bytes_in_from_destination
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-bytes-in-from-destination"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "BytesInFromDestination"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].bytes_in_from_destination
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway bytes in from destination>(>= ${local.effective_thresholds[each.key].bytes_in_from_destination} bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For BytesOutToSource
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bytes_out_to_source" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_bytes_out_to_source
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-bytes-out-to-source"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "BytesOutToSource"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].bytes_out_to_source
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway bytes out to source>(>= ${local.effective_thresholds[each.key].bytes_out_to_source} bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ConnectionAttemptCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "connection_attempt_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_connection_attempt_count
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-connection-attempt-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "ConnectionAttemptCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].connection_attempt_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway connection attempt count>(>= ${local.effective_thresholds[each.key].connection_attempt_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ConnectionEstablishedCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "connection_established_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_connection_established_count
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-connection-established-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "ConnectionEstablishedCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].connection_established_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway connection established count>(>= ${local.effective_thresholds[each.key].connection_established_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ErrorPortAllocation
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_port_allocation" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_error_port_allocation
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-error-port-allocation"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "ErrorPortAllocation"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].error_port_allocation
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway error port allocation>(>= ${local.effective_thresholds[each.key].error_port_allocation})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For IdleTimeoutCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "idle_timeout_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_idle_timeout_count
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-idle-timeout-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "IdleTimeoutCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].idle_timeout_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway idle timeout count>(>= ${local.effective_thresholds[each.key].idle_timeout_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PacketsDropCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "packets_drop_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_packets_drop_count
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-drop-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PacketsDropCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].packets_drop_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets drop count>(>= ${local.effective_thresholds[each.key].packets_drop_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PacketsInFromDestination
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "packets_in_from_destination" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_packets_in_from_destination
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-in-from-destination"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PacketsInFromDestination"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].packets_in_from_destination
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets in from destination>(>= ${local.effective_thresholds[each.key].packets_in_from_destination})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PacketsInFromSource
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "packets_in_from_source" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_packets_in_from_source
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-in-from-source"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PacketsInFromSource"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].packets_in_from_source
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets in from source>(>= ${local.effective_thresholds[each.key].packets_in_from_source})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PacketsOutToDestination
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "packets_out_to_destination" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_packets_out_to_destination
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-out-to-destination"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PacketsOutToDestination"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].packets_out_to_destination
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets out to destination>(>= ${local.effective_thresholds[each.key].packets_out_to_destination})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PacketsOutToSource
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "packets_out_to_source" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_packets_out_to_source
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-out-to-source"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PacketsOutToSource"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].packets_out_to_source
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets out to source>(>= ${local.effective_thresholds[each.key].packets_out_to_source})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PeakBytesPerSecond
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "peak_bytes_per_second" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_peak_bytes_per_second
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-peak-bytes-per-second"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PeakBytesPerSecond"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].peak_bytes_per_second
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway peak bytes per second>(>= ${local.effective_thresholds[each.key].peak_bytes_per_second} bytes/sec)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PeakPacketsPerSecond
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "peak_packets_per_second" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_peak_packets_per_second
  }

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-peak-packets-per-second"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PeakPacketsPerSecond"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].peak_packets_per_second
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway peak packets per second>(>= ${local.effective_thresholds[each.key].peak_packets_per_second} packets/sec)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
