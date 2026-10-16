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
module "helper" {
  source = "../../_internal/metric_helper"

  is_enabled = var.is_enabled
  region     = local.region

  base_threshold     = var.threshold
  dimension_key      = "TaskDefinitionFamily"
  manual_dimensions  = local.manual_dimensions
  threshold_override = var.threshold_override
}

locals {
  url = "https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/Container-Insights-metrics-ECS.html"

  is_dimensions = length(var.dimensions) > 0
  # Without dimensions, a single alarm set is created under the reserved "default" key (do not use "default" as a real dimension value).
  manual_dimensions = local.is_dimensions ? var.dimensions : [{ TaskDefinitionFamily = "default" }]

  # Use filtered results from helper module
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
  alarm_name_infix     = { for k, v in module.helper.list : k => local.is_dimensions ? "${v.name}-" : "" }
}

#--------------------------------------------------------------
# For CPU Utilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].cpu_utilization.enabled
  }

  region              = local.region
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ECS ContainerInsights Cpu Utilization>(>= ${local.effective_thresholds[each.key].cpu_utilization.value})."
  alarm_name          = "${var.name_prefix}metric-ecs-container-insights-${local.alarm_name_infix[each.key]}cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = local.effective_thresholds[each.key].cpu_utilization.datapoints_to_alarm
  evaluation_periods  = local.effective_thresholds[each.key].cpu_utilization.evaluation_periods
  ok_actions          = var.ok_actions
  threshold           = local.effective_thresholds[each.key].cpu_utilization.value
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
      dimensions  = local.is_dimensions ? each.value.dimensions : null
    }
  }
  metric_query {
    id = "m2"
    metric {
      metric_name = "CpuUtilized"
      namespace   = "ECS/ContainerInsights"
      period      = var.period
      stat        = "Average"
      dimensions  = local.is_dimensions ? each.value.dimensions : null
    }
  }

  tags = var.tags
}

#--------------------------------------------------------------
# For Memory Utilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].memory_utilization.enabled
  }

  region              = local.region
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ECS ContainerInsights Memory Utilization>(>= ${local.effective_thresholds[each.key].memory_utilization.value})."
  alarm_name          = "${var.name_prefix}metric-ecs-container-insights-${local.alarm_name_infix[each.key]}memory-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = local.effective_thresholds[each.key].memory_utilization.datapoints_to_alarm
  evaluation_periods  = local.effective_thresholds[each.key].memory_utilization.evaluation_periods
  ok_actions          = var.ok_actions
  threshold           = local.effective_thresholds[each.key].memory_utilization.value
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
      dimensions  = local.is_dimensions ? each.value.dimensions : null
    }
  }
  metric_query {
    id = "m2"
    metric {
      metric_name = "MemoryUtilized"
      namespace   = "ECS/ContainerInsights"
      period      = var.period
      stat        = "Average"
      dimensions  = local.is_dimensions ? each.value.dimensions : null
    }
  }

  tags = var.tags
}

#--------------------------------------------------------------
# For Network Rx Bytes (Ingress)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_rx_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].network_rx_bytes.enabled
  }

  region              = local.region
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ECS ContainerInsights Network Rx Bytes>(>= ${local.effective_thresholds[each.key].network_rx_bytes.value} Bytes/Second)."
  alarm_name          = "${var.name_prefix}metric-ecs-container-insights-${local.alarm_name_infix[each.key]}network-rx-bytes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = local.effective_thresholds[each.key].network_rx_bytes.datapoints_to_alarm
  dimensions          = local.is_dimensions ? each.value.dimensions : null
  evaluation_periods  = local.effective_thresholds[each.key].network_rx_bytes.evaluation_periods
  metric_name         = "NetworkRxBytes"
  namespace           = "ECS/ContainerInsights"
  ok_actions          = var.ok_actions
  period              = var.period
  statistic           = "Sum"
  threshold           = local.effective_thresholds[each.key].network_rx_bytes.value
  treat_missing_data  = "notBreaching"
  unit                = "Bytes/Second"

  tags = var.tags
}

#--------------------------------------------------------------
# For Network Tx Bytes (Egress)
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_tx_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].network_tx_bytes.enabled
  }

  region              = local.region
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ECS ContainerInsights Network Tx Bytes>(>= ${local.effective_thresholds[each.key].network_tx_bytes.value} Bytes/Second)."
  alarm_name          = "${var.name_prefix}metric-ecs-container-insights-${local.alarm_name_infix[each.key]}network-tx-bytes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = local.effective_thresholds[each.key].network_tx_bytes.datapoints_to_alarm
  dimensions          = local.is_dimensions ? each.value.dimensions : null
  evaluation_periods  = local.effective_thresholds[each.key].network_tx_bytes.evaluation_periods
  metric_name         = "NetworkTxBytes"
  namespace           = "ECS/ContainerInsights"
  ok_actions          = var.ok_actions
  period              = var.period
  statistic           = "Sum"
  threshold           = local.effective_thresholds[each.key].network_tx_bytes.value
  treat_missing_data  = "notBreaching"
  unit                = "Bytes/Second"

  tags = var.tags
}

#--------------------------------------------------------------
# For Storage Read Bytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "storage_read_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].storage_read_bytes.enabled
  }

  region              = local.region
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ECS ContainerInsights Storage Read Bytes>(>= ${local.effective_thresholds[each.key].storage_read_bytes.value} Bytes)."
  alarm_name          = "${var.name_prefix}metric-ecs-container-insights-${local.alarm_name_infix[each.key]}storage-read-bytes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = local.effective_thresholds[each.key].storage_read_bytes.datapoints_to_alarm
  dimensions          = local.is_dimensions ? each.value.dimensions : null
  evaluation_periods  = local.effective_thresholds[each.key].storage_read_bytes.evaluation_periods
  metric_name         = "StorageReadBytes"
  namespace           = "ECS/ContainerInsights"
  ok_actions          = var.ok_actions
  period              = var.period
  statistic           = "Sum"
  threshold           = local.effective_thresholds[each.key].storage_read_bytes.value
  treat_missing_data  = "notBreaching"
  unit                = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For Storage Write Bytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "storage_write_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].storage_write_bytes.enabled
  }

  region              = local.region
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ECS ContainerInsights Storage Write Bytes>(>= ${local.effective_thresholds[each.key].storage_write_bytes.value} Bytes)."
  alarm_name          = "${var.name_prefix}metric-ecs-container-insights-${local.alarm_name_infix[each.key]}storage-write-bytes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = local.effective_thresholds[each.key].storage_write_bytes.datapoints_to_alarm
  dimensions          = local.is_dimensions ? each.value.dimensions : null
  evaluation_periods  = local.effective_thresholds[each.key].storage_write_bytes.evaluation_periods
  metric_name         = "StorageWriteBytes"
  namespace           = "ECS/ContainerInsights"
  ok_actions          = var.ok_actions
  period              = var.period
  statistic           = "Sum"
  threshold           = local.effective_thresholds[each.key].storage_write_bytes.value
  treat_missing_data  = "notBreaching"
  unit                = "Bytes"

  tags = var.tags
}
