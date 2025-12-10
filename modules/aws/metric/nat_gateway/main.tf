#--------------------------------------------------------------
# Module: aws/metric/nat_gateway
# Purpose: Provide CloudWatch metric alarms for NAT Gateways with optional auto-discovery (bytes, packets, connections, errors).
# Notes: Unified tagging; auto discovery filters NAT Gateways via exclude/include list.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "filter" {
  source     = "../../_internal/auto_discovery_filter"
  is_enabled = var.is_enabled

  create_auto       = var.create_auto_dimensions
  source_list       = data.aws_nat_gateways.this.ids
  include_list      = var.auto_dimensions_include_list
  exclude_list      = var.auto_dimensions_exclude_list
  manual_dimensions = var.dimensions
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/vpc/latest/userguide/metrics-dimensions-nat-gateway.html"

  # Use filtered results from helper module
  auto_dimensions = module.filter.filtered_list
  safe_dimensions = module.filter.safe_manual_dimensions

  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : v => {
      name = v
      dimensions = {
        "NatGatewayId" = v
      }
    }
    } : {
    for v in local.safe_dimensions : v.NatGatewayId => {
      name       = v.NatGatewayId
      dimensions = v
    } if v != null && try(v.NatGatewayId, null) != null && v.NatGatewayId != ""
  }
}

#--------------------------------------------------------------
# For ActiveConnectionCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "active_connection_count" {
  for_each = var.is_enabled && var.threshold.enabled_active_connection_count ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-active-connection-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "ActiveConnectionCount"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.active_connection_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway active connection count>(>= ${var.threshold.active_connection_count})."
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
  for_each = var.is_enabled && var.threshold.enabled_bytes_out_to_destination ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-bytes-out-to-destination"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "BytesOutToDestination"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.bytes_out_to_destination
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway bytes out to destination>(>= ${var.threshold.bytes_out_to_destination} bytes)."
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
  for_each = var.is_enabled && var.threshold.enabled_bytes_in_from_source ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-bytes-in-from-source"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "BytesInFromSource"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.bytes_in_from_source
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway bytes in from source>(>= ${var.threshold.bytes_in_from_source} bytes)."
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
  for_each = var.is_enabled && var.threshold.enabled_bytes_in_from_destination ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-bytes-in-from-destination"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "BytesInFromDestination"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.bytes_in_from_destination
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway bytes in from destination>(>= ${var.threshold.bytes_in_from_destination} bytes)."
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
  for_each = var.is_enabled && var.threshold.enabled_bytes_out_to_source ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-bytes-out-to-source"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "BytesOutToSource"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.bytes_out_to_source
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway bytes out to source>(>= ${var.threshold.bytes_out_to_source} bytes)."
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
  for_each = var.is_enabled && var.threshold.enabled_connection_attempt_count ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-connection-attempt-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "ConnectionAttemptCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.connection_attempt_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway connection attempt count>(>= ${var.threshold.connection_attempt_count})."
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
  for_each = var.is_enabled && var.threshold.enabled_connection_established_count ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-connection-established-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "ConnectionEstablishedCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.connection_established_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway connection established count>(>= ${var.threshold.connection_established_count})."
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
  for_each = var.is_enabled && var.threshold.enabled_error_port_allocation ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-error-port-allocation"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "ErrorPortAllocation"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.error_port_allocation
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway error port allocation>(>= ${var.threshold.error_port_allocation})."
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
  for_each = var.is_enabled && var.threshold.enabled_idle_timeout_count ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-idle-timeout-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "IdleTimeoutCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.idle_timeout_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway idle timeout count>(>= ${var.threshold.idle_timeout_count})."
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
  for_each = var.is_enabled && var.threshold.enabled_packets_drop_count ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-drop-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PacketsDropCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.packets_drop_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets drop count>(>= ${var.threshold.packets_drop_count})."
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
  for_each = var.is_enabled && var.threshold.enabled_packets_in_from_destination ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-in-from-destination"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PacketsInFromDestination"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.packets_in_from_destination
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets in from destination>(>= ${var.threshold.packets_in_from_destination})."
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
  for_each = var.is_enabled && var.threshold.enabled_packets_in_from_source ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-in-from-source"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PacketsInFromSource"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.packets_in_from_source
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets in from source>(>= ${var.threshold.packets_in_from_source})."
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
  for_each = var.is_enabled && var.threshold.enabled_packets_out_to_destination ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-out-to-destination"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PacketsOutToDestination"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.packets_out_to_destination
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets out to destination>(>= ${var.threshold.packets_out_to_destination})."
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
  for_each = var.is_enabled && var.threshold.enabled_packets_out_to_source ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-packets-out-to-source"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PacketsOutToSource"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.packets_out_to_source
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway packets out to source>(>= ${var.threshold.packets_out_to_source})."
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
  for_each = var.is_enabled && var.threshold.enabled_peak_bytes_per_second ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-peak-bytes-per-second"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PeakBytesPerSecond"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.peak_bytes_per_second
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway peak bytes per second>(>= ${var.threshold.peak_bytes_per_second} bytes/sec)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "None"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PeakPacketsPerSecond
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "peak_packets_per_second" {
  for_each = var.is_enabled && var.threshold.enabled_peak_packets_per_second ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-nat-gateway-${each.value.name}-peak-packets-per-second"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/NATGateway"
  metric_name               = "PeakPacketsPerSecond"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.peak_packets_per_second
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|NAT Gateway peak packets per second>(>= ${var.threshold.peak_packets_per_second} packets/sec)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "None"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
