#--------------------------------------------------------------
# Module: aws/metric/ecs_container_insights
# Purpose: Provide CloudWatch metric alarms for ECS cluster/container utilization (CPU and Memory) via Container Insights metric math.
# Notes: Supports optional dimension-based filtering (cluster/service/task family); unified tagging applied; future improvement: add additional Container Insights metrics (e.g., network, storage) and consolidate metric math patterns.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
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
