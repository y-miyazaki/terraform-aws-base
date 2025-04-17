#--------------------------------------------------------------
# For Redshift
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  url = "https://docs.aws.amazon.com/ja_jp/redshift/latest/mgmt/metrics-listing.html"
  auto_dimensions = var.create_auto_dimensions ? [
    for v in split(",", data.external.list[0].result.list) : v if !anytrue([for el in var.auto_dimensions_exclude_list : strcontains(v, el)])
  ] : []
  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : v => {
      name = v
      dimensions = {
        "ClusterIdentifier" = v
      }
    }
    } : {
    for v in var.dimensions : v.ClusterIdentifier => {
      name       = v.ClusterIdentifier
      dimensions = v
    }
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# For CommitQueueLength
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "commit_queue_length" {
  for_each                  = var.is_enabled && var.threshold.enabled_commit_queue_length ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-commit-queue-length"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "CommitQueueLength"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.commit_queue_length
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift CommitQueueLength>(>= ${var.threshold.commit_queue_length})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}

#--------------------------------------------------------------
# For ConcurrencyScalingActiveClusters
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "concurrency_scaling_active_clusters" {
  for_each                  = var.is_enabled && var.threshold.enabled_concurrency_scaling_active_clusters ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-concurrency-scaling-active-clusters"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "ConcurrencyScalingActiveClusters"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.concurrency_scaling_active_clusters
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ConcurrencyScalingActiveClusters>(>= ${var.threshold.concurrency_scaling_active_clusters})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For ConcurrencyScalingSeconds
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "concurrency_scaling_seconds" {
  for_each                  = var.is_enabled && var.threshold.enabled_concurrency_scaling_seconds ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-concurrency-scaling-seconds"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "ConcurrencyScalingSeconds"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.concurrency_scaling_seconds
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ConcurrencyScalingSeconds>(>= ${var.threshold.concurrency_scaling_seconds})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For CPUUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  for_each                  = var.is_enabled && var.threshold.enabled_cpu_utilization ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "CPUUtilization"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.cpu_utilization
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift CPUUtilization>(>= ${var.threshold.cpu_utilization}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For DatabaseConnections
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "database_connections" {
  for_each                  = var.is_enabled && var.threshold.enabled_database_connections ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-database-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "DatabaseConnections"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.database_connections
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift DatabaseConnections>(>= ${var.threshold.database_connections})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For HealthStatus
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "health_status" {
  for_each                  = var.is_enabled && var.threshold.enabled_health_status ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-health-status"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "HealthStatus"
  period                    = var.period
  statistic                 = "Minimum"
  threshold                 = var.threshold.health_status
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift HealthStatus>(< ${var.threshold.health_status})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For MaintenanceMode
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "maintenance_mode" {
  for_each                  = var.is_enabled && var.threshold.enabled_maintenance_mode ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-maintenance-mode"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "MaintenanceMode"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.maintenance_mode
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift MaintenanceMode>(>= ${var.threshold.maintenance_mode})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For MaxConfiguredConcurrencyScalingClusters
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "max_configured_concurrency_scaling_clusters" {
  for_each                  = var.is_enabled && var.threshold.enabled_max_configured_concurrency_scaling_clusters ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-max-configured-concurrency-scaling-clusters"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "MaxConfiguredConcurrencyScalingClusters"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.max_configured_concurrency_scaling_clusters
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift MaxConfiguredConcurrencyScalingClusters>(>= ${var.threshold.max_configured_concurrency_scaling_clusters})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For NetworkReceiveThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_receive_throughput" {
  for_each                  = var.is_enabled && var.threshold.enabled_network_receive_throughput ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-network-receive-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "NetworkReceiveThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.network_receive_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift NetworkReceiveThroughput>(>= ${var.threshold.network_receive_throughput}Bytes/Second)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For NetworkTransmitThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_transmit_throughput" {
  for_each                  = var.is_enabled && var.threshold.enabled_network_transmit_throughput ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-network-transmit-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "NetworkTransmitThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.network_transmit_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift NetworkTransmitThroughput>(>= ${var.threshold.network_transmit_throughput}Bytes/Second)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For PercentageDiskSpaceUsed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "percentage_disk_space_used" {
  for_each                  = var.is_enabled && var.threshold.enabled_percentage_disk_space_used ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-percentage-disk-space-used"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "PercentageDiskSpaceUsed"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.percentage_disk_space_used
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift PercentageDiskSpaceUsed>(>= ${var.threshold.percentage_disk_space_used}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For QueriesCompletedPerSecond
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "queries_completed_per_second" {
  for_each                  = var.is_enabled && var.threshold.enabled_queries_completed_per_second ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-queries-completed-per-second"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "QueriesCompletedPerSecond"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.queries_completed_per_second
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift QueriesCompletedPerSecond>(>= ${var.threshold.queries_completed_per_second})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For QueryDuration
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "query_duration" {
  for_each                  = var.is_enabled && var.threshold.enabled_query_duration ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-query-duration"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "QueryDuration"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.query_duration
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift QueryDuration>(>= ${var.threshold.query_duration}Microseconds)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Microseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For QueryRuntimeBreakdown
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "query_runtime_breakdown" {
  for_each                  = var.is_enabled && var.threshold.enabled_query_runtime_breakdown ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-query-runtime-breakdown"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "QueryRuntimeBreakdown"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.query_runtime_breakdown
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift QueryRuntimeBreakdown>(>= ${var.threshold.query_runtime_breakdown}Microseconds)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Microseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For ReadIOPS
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_iops" {
  for_each                  = var.is_enabled && var.threshold.enabled_read_iops ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-read-iops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "ReadIOPS"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.read_iops
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ReadIOPS>(>= ${var.threshold.read_iops})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For ReadLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_latency" {
  for_each                  = var.is_enabled && var.threshold.enabled_read_latency ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-read-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "ReadLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.read_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ReadLatency>(>= ${var.threshold.read_latency}Seconds)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For ReadThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_throughput" {
  for_each                  = var.is_enabled && var.threshold.enabled_read_throughput ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-read-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "ReadThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.read_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ReadThroughput>(>= ${var.threshold.read_throughput}Bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For RedshiftManagedStorageTotalCapacity
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "redshift_managed_storage_total_capacity" {
  for_each                  = var.is_enabled && var.threshold.enabled_redshift_managed_storage_total_capacity ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-redshift-managed-storage-total-capacity"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "RedshiftManagedStorageTotalCapacity"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.redshift_managed_storage_total_capacity
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift RedshiftManagedStorageTotalCapacity>(>= ${var.threshold.redshift_managed_storage_total_capacity}Megabytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Megabytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For TotalTableCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "total_table_count" {
  for_each                  = var.is_enabled && var.threshold.enabled_total_table_count ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-total-table-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "TotalTableCount"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.total_table_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift TotalTableCount>(>= ${var.threshold.total_table_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For WLMQueueLength
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_queue_length" {
  for_each                  = var.is_enabled && var.threshold.enabled_wlm_queue_length ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-wlm-queue-length"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WLMQueueLength"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.wlm_queue_length
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WLMQueueLength>(>= ${var.threshold.wlm_queue_length})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })
  tags = local.tags
}
#--------------------------------------------------------------
# For WLMQueueWaitTime
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_queue_wait_time" {
  for_each                  = var.is_enabled && var.threshold.enabled_wlm_queue_wait_time ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-wlm-queue-wait-time"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WLMQueueWaitTime"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.wlm_queue_wait_time
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WLMQueueWaitTime>(>= ${var.threshold.wlm_queue_wait_time}Milliseconds)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })
  tags = local.tags
}
#--------------------------------------------------------------
# For WLMQueriesCompletedPerSecond
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_queries_completed_per_second" {
  for_each                  = var.is_enabled && var.threshold.enabled_wlm_queries_completed_per_second ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-enabled-wlm-queries-completed-per-second"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WLMQueriesCompletedPerSecond"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.wlm_queries_completed_per_second
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WLMQueriesCompletedPerSecond>(>= ${var.threshold.wlm_queries_completed_per_second})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count/Second"
  treat_missing_data        = "notBreaching"
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })
  tags = local.tags
}
#--------------------------------------------------------------
# For WLMQueryDuration
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_query_duration" {
  for_each                  = var.is_enabled && var.threshold.enabled_wlm_query_duration ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-wlm-query-duration"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WLMQueryDuration"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.wlm_query_duration
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WLMQueryDuration>(>= ${var.threshold.wlm_query_duration}Microseconds)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Microseconds"
  treat_missing_data        = "notBreaching"
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })
  tags = local.tags
}
#--------------------------------------------------------------
# For WLMRunningQueries
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_running_queries" {
  for_each                  = var.is_enabled && var.threshold.enabled_wlm_running_queries ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-wlm-running-queries"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WLMRunningQueries"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.wlm_running_queries
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WLMRunningQueries>(>= ${var.threshold.wlm_running_queries})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })
  tags = local.tags
}
#--------------------------------------------------------------
# For WriteIOPS
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_iops" {
  for_each                  = var.is_enabled && var.threshold.enabled_write_iops ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-write-iops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WriteIOPS"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.write_iops
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WriteIOPS>(>= ${var.threshold.write_iops})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For WriteLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_latency" {
  for_each                  = var.is_enabled && var.threshold.enabled_write_latency ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-write-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WriteLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.write_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WriteLatency>(>= ${var.threshold.write_latency}Seconds)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For WriteThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_throughput" {
  for_each                  = var.is_enabled && var.threshold.enabled_write_throughput ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-write-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WriteThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.write_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WriteThroughput>(>= ${var.threshold.write_throughput}Bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For SchemaQuota
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "schema_quota" {
  for_each                  = var.is_enabled && var.threshold.enabled_schema_quota ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-schema-quota"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "SchemaQuota"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.schema_quota
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift SchemaQuota>(>= ${var.threshold.schema_quota}Megabytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Megabytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For NumExceededSchemaQuotas
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "num_exceeded_schema_quotas" {
  for_each                  = var.is_enabled && var.threshold.enabled_num_exceeded_schema_quotas ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-num-exceeded-schema-quotas"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "NumExceededSchemaQuotas"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.num_exceeded_schema_quotas
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift NumExceededSchemaQuotas>(> ${var.threshold.num_exceeded_schema_quotas})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For StorageUsed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "storage_used" {
  for_each                  = var.is_enabled && var.threshold.enabled_storage_used ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-commit-queue-length"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "StorageUsed"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.storage_used
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift StorageUsed>(>= ${var.threshold.storage_used}Megabytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Megabytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
#--------------------------------------------------------------
# For PercentageQuotaUsed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "percentage_quota_used" {
  for_each                  = var.is_enabled && var.threshold.enabled_percentage_quota_used ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-percentage-quota-used"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "PercentageQuotaUsed"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.percentage_quota_used
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift PercentageQuotaUsed>(>= ${var.threshold.percentage_quota_used}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
