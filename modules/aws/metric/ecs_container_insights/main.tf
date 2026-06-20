#--------------------------------------------------------------
# Module: aws/metric/ecs_container_insights
# Purpose: Provide CloudWatch metric alarms for ECS cluster/container utilization (CPU, Memory, Network, Storage) via Container Insights.
# Notes: Supports optional dimension-based filtering (cluster/service/task family); unified tagging applied. Network metrics require awsvpc or bridge network mode.
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
locals {
  url   = "https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/Container-Insights-metrics-ECS.html"
  count = length(var.dimensions) > 0 ? length(var.dimensions) : 1

  names = length(var.dimensions) > 0 ? flatten([
    for r in var.dimensions : {
      name = format("%s-", r.TaskDefinitionFamily)
    }]) : [{
    name = ""
  }]
  is_dimensions = length(var.dimensions) > 0 ? true : false
}

#--------------------------------------------------------------
# For CPU Utilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count = var.is_enabled && var.threshold.enabled_cpu_utilization ? local.count : 0

  region              = local.region
  alarm_name          = "${var.name_prefix}metric-ecs-container-insights-${local.names[count.index].name}cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.threshold.cpu_utilization
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ECS ContainerInsights Cpu Utilization>(>= ${var.threshold.cpu_utilization})."
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"
  metric_query {
    id          = "e1"
    expression  = "m2 / m1 * 100"
    label       = "CPU Utilization (%)"
    return_data = "true"
  }
  metric_query {
    id = "m1"
    metric {
      metric_name = "CpuReserved"
      namespace   = "ECS/ContainerInsights"
      period      = var.period
      stat        = "Average"
      dimensions  = local.is_dimensions ? var.dimensions[count.index] : null
    }
  }
  metric_query {
    id = "m2"
    metric {
      metric_name = "CpuUtilized"
      namespace   = "ECS/ContainerInsights"
      period      = var.period
      stat        = "Average"
      dimensions  = local.is_dimensions ? var.dimensions[count.index] : null
    }
  }

  tags = var.tags
}

#--------------------------------------------------------------
# For Memory Utilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  count = var.is_enabled && var.threshold.enabled_memory_utilization ? local.count : 0

  region              = local.region
  alarm_name          = "${var.name_prefix}metric-ecs-container-insights-${local.names[count.index].name}memory-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.threshold.memory_utilization
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ECS ContainerInsights Memory Utilization>(>= ${var.threshold.memory_utilization})."
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"
  metric_query {
    id          = "e1"
    expression  = "m2 / m1 * 100"
    label       = "Memory Utilization (%)"
    return_data = "true"
  }
  metric_query {
    id = "m1"
    metric {
      metric_name = "MemoryReserved"
      namespace   = "ECS/ContainerInsights"
      period      = var.period
      stat        = "Average"
      dimensions  = local.is_dimensions ? var.dimensions[count.index] : null
    }
  }
  metric_query {
    id = "m2"
    metric {
      metric_name = "MemoryUtilized"
      namespace   = "ECS/ContainerInsights"
      period      = var.period
      stat        = "Average"
      dimensions  = local.is_dimensions ? var.dimensions[count.index] : null
    }
  }

  tags = var.tags
}

#--------------------------------------------------------------
# For Network Rx Bytes (Ingress)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_rx_bytes" {
  count = var.is_enabled && var.threshold.enabled_network_rx_bytes ? local.count : 0

  region              = local.region
  alarm_name          = "${var.name_prefix}metric-ecs-container-insights-${local.names[count.index].name}network-rx-bytes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkRxBytes"
  namespace           = "ECS/ContainerInsights"
  period              = var.period
  statistic           = "Sum"
  threshold           = var.threshold.network_rx_bytes
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ECS ContainerInsights Network Rx Bytes>(>= ${var.threshold.network_rx_bytes} Bytes/Second)."
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? var.dimensions[count.index] : null
  unit                = "Bytes/Second"

  tags = var.tags
}

#--------------------------------------------------------------
# For Network Tx Bytes (Egress)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_tx_bytes" {
  count = var.is_enabled && var.threshold.enabled_network_tx_bytes ? local.count : 0

  region              = local.region
  alarm_name          = "${var.name_prefix}metric-ecs-container-insights-${local.names[count.index].name}network-tx-bytes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NetworkTxBytes"
  namespace           = "ECS/ContainerInsights"
  period              = var.period
  statistic           = "Sum"
  threshold           = var.threshold.network_tx_bytes
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ECS ContainerInsights Network Tx Bytes>(>= ${var.threshold.network_tx_bytes} Bytes/Second)."
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? var.dimensions[count.index] : null
  unit                = "Bytes/Second"

  tags = var.tags
}

#--------------------------------------------------------------
# For Storage Read Bytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "storage_read_bytes" {
  count = var.is_enabled && var.threshold.enabled_storage_read_bytes ? local.count : 0

  region              = local.region
  alarm_name          = "${var.name_prefix}metric-ecs-container-insights-${local.names[count.index].name}storage-read-bytes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "StorageReadBytes"
  namespace           = "ECS/ContainerInsights"
  period              = var.period
  statistic           = "Sum"
  threshold           = var.threshold.storage_read_bytes
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ECS ContainerInsights Storage Read Bytes>(>= ${var.threshold.storage_read_bytes} Bytes)."
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? var.dimensions[count.index] : null
  unit                = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For Storage Write Bytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "storage_write_bytes" {
  count = var.is_enabled && var.threshold.enabled_storage_write_bytes ? local.count : 0

  region              = local.region
  alarm_name          = "${var.name_prefix}metric-ecs-container-insights-${local.names[count.index].name}storage-write-bytes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "StorageWriteBytes"
  namespace           = "ECS/ContainerInsights"
  period              = var.period
  statistic           = "Sum"
  threshold           = var.threshold.storage_write_bytes
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ECS ContainerInsights Storage Write Bytes>(>= ${var.threshold.storage_write_bytes} Bytes)."
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? var.dimensions[count.index] : null
  unit                = "Bytes"

  tags = var.tags
}
