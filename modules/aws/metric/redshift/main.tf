#--------------------------------------------------------------
# Module: aws/metric/redshift
# Purpose: Provide CloudWatch metric alarms for Amazon Redshift clusters (performance, storage, query, WLM, and resource utilization).
# Notes: Includes auto-discovery of clusters via external script when enabled; unified tagging pattern applied; future improvement: replace external data source with native data source when possible.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "helper" {
  source     = "../../_internal/metric_helper"
  is_enabled = var.is_enabled

  create_auto        = var.create_auto_dimensions
  source_list        = var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list) : []
  include_list       = var.auto_dimensions_include_list
  exclude_list       = var.auto_dimensions_exclude_list
  manual_dimensions  = var.dimensions
  dimension_key      = "ClusterIdentifier"
  base_threshold     = var.threshold
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/ja_jp/redshift/latest/mgmt/metrics-listing.html"

  # Use filtered results from helper module
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
}

#--------------------------------------------------------------
# For CommitQueueLength
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "commit_queue_length" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_commit_queue_length
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-commit-queue-length"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "CommitQueueLength"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].commit_queue_length
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift CommitQueueLength>(>= ${local.effective_thresholds[each.key].commit_queue_length})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ConcurrencyScalingActiveClusters
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "concurrency_scaling_active_clusters" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_concurrency_scaling_active_clusters
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-concurrency-scaling-active-clusters"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "ConcurrencyScalingActiveClusters"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].concurrency_scaling_active_clusters
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ConcurrencyScalingActiveClusters>(>= ${local.effective_thresholds[each.key].concurrency_scaling_active_clusters})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ConcurrencyScalingSeconds
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "concurrency_scaling_seconds" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_concurrency_scaling_seconds
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-concurrency-scaling-seconds"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "ConcurrencyScalingSeconds"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].concurrency_scaling_seconds
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ConcurrencyScalingSeconds>(>= ${local.effective_thresholds[each.key].concurrency_scaling_seconds}s)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_cpu_utilization
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "CPUUtilization"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].cpu_utilization
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift CPUUtilization>(>= ${local.effective_thresholds[each.key].cpu_utilization}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DatabaseConnections
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "database_connections" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_database_connections
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-database-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "DatabaseConnections"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].database_connections
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift DatabaseConnections>(>= ${local.effective_thresholds[each.key].database_connections})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For HealthStatus
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "health_status" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_health_status
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-health-status"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "HealthStatus"
  period                    = var.period
  statistic                 = "Minimum"
  threshold                 = local.effective_thresholds[each.key].health_status
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift HealthStatus>(< ${local.effective_thresholds[each.key].health_status})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For MaintenanceMode
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "maintenance_mode" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_maintenance_mode
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-maintenance-mode"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "MaintenanceMode"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].maintenance_mode
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift MaintenanceMode>(>= ${local.effective_thresholds[each.key].maintenance_mode})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For MaxConfiguredConcurrencyScalingClusters
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "max_configured_concurrency_scaling_clusters" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_max_configured_concurrency_scaling_clusters
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-max-configured-concurrency-scaling-clusters"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "MaxConfiguredConcurrencyScalingClusters"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].max_configured_concurrency_scaling_clusters
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift MaxConfiguredConcurrencyScalingClusters>(>= ${local.effective_thresholds[each.key].max_configured_concurrency_scaling_clusters})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkReceiveThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_receive_throughput" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_network_receive_throughput
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-network-receive-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "NetworkReceiveThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].network_receive_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift NetworkReceiveThroughput>(>= ${local.effective_thresholds[each.key].network_receive_throughput}Bytes/Second)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NumExceededSchemaQuotas
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "num_exceeded_schema_quotas" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_num_exceeded_schema_quotas
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-num-exceeded-schema-quotas"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "NumExceededSchemaQuotas"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].num_exceeded_schema_quotas
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift NumExceededSchemaQuotas>(> ${local.effective_thresholds[each.key].num_exceeded_schema_quotas})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkTransmitThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_transmit_throughput" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_network_transmit_throughput
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-network-transmit-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "NetworkTransmitThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].network_transmit_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift NetworkTransmitThroughput>(>= ${local.effective_thresholds[each.key].network_transmit_throughput}Bytes/Second)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PercentageDiskSpaceUsed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "percentage_disk_space_used" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_percentage_disk_space_used
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-percentage-disk-space-used"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "PercentageDiskSpaceUsed"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].percentage_disk_space_used
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift PercentageDiskSpaceUsed>(>= ${local.effective_thresholds[each.key].percentage_disk_space_used}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PercentageQuotaUsed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "percentage_quota_used" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_percentage_quota_used
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-percentage-quota-used"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "PercentageQuotaUsed"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].percentage_quota_used
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift PercentageQuotaUsed>(>= ${local.effective_thresholds[each.key].percentage_quota_used}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For QueriesCompletedPerSecond
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "queries_completed_per_second" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_queries_completed_per_second
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-queries-completed-per-second"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "QueriesCompletedPerSecond"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].queries_completed_per_second
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift QueriesCompletedPerSecond>(>= ${local.effective_thresholds[each.key].queries_completed_per_second})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For QueryDuration
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "query_duration" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_query_duration
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-query-duration"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "QueryDuration"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].query_duration
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift QueryDuration>(>= ${local.effective_thresholds[each.key].query_duration}Microseconds)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Microseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For QueryRuntimeBreakdown
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "query_runtime_breakdown" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_query_runtime_breakdown
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-query-runtime-breakdown"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "QueryRuntimeBreakdown"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].query_runtime_breakdown
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift QueryRuntimeBreakdown>(>= ${local.effective_thresholds[each.key].query_runtime_breakdown}Microseconds)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Microseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ReadIOPS
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_iops" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_read_iops
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-read-iops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "ReadIOPS"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].read_iops
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ReadIOPS>(>= ${local.effective_thresholds[each.key].read_iops})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ReadLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_read_latency
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-read-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "ReadLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].read_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ReadLatency>(>= ${local.effective_thresholds[each.key].read_latency}s)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ReadThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_throughput" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_read_throughput
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-read-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "ReadThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].read_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ReadThroughput>(>= ${local.effective_thresholds[each.key].read_throughput}Bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For RedshiftManagedStorageTotalCapacity
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "redshift_managed_storage_total_capacity" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_redshift_managed_storage_total_capacity
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-redshift-managed-storage-total-capacity"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "RedshiftManagedStorageTotalCapacity"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].redshift_managed_storage_total_capacity
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift RedshiftManagedStorageTotalCapacity>(>= ${local.effective_thresholds[each.key].redshift_managed_storage_total_capacity}Megabytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Megabytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For SchemaQuota
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "schema_quota" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_schema_quota
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-schema-quota"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "SchemaQuota"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].schema_quota
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift SchemaQuota>(>= ${local.effective_thresholds[each.key].schema_quota}Megabytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Megabytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For StorageUsed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "storage_used" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_storage_used
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-storage-used"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "StorageUsed"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].storage_used
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift StorageUsed>(>= ${local.effective_thresholds[each.key].storage_used}Megabytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Megabytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For TotalTableCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "total_table_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_total_table_count
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-total-table-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "TotalTableCount"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].total_table_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift TotalTableCount>(>= ${local.effective_thresholds[each.key].total_table_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For WLMQueueLength
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_queue_length" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_wlm_queue_length
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-wlm-queue-length"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WLMQueueLength"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].wlm_queue_length
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WLMQueueLength>(>= ${local.effective_thresholds[each.key].wlm_queue_length})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })

  tags = var.tags
}

#--------------------------------------------------------------
# For WLMQueueWaitTime
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_queue_wait_time" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_wlm_queue_wait_time
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-wlm-queue-wait-time"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WLMQueueWaitTime"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].wlm_queue_wait_time
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WLMQueueWaitTime>(>= ${local.effective_thresholds[each.key].wlm_queue_wait_time}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })

  tags = var.tags
}

#--------------------------------------------------------------
# For WLMQueriesCompletedPerSecond
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_queries_completed_per_second" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_wlm_queries_completed_per_second
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-enabled-wlm-queries-completed-per-second"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WLMQueriesCompletedPerSecond"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].wlm_queries_completed_per_second
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WLMQueriesCompletedPerSecond>(>= ${local.effective_thresholds[each.key].wlm_queries_completed_per_second})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count/Second"
  treat_missing_data        = "notBreaching"
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })

  tags = var.tags
}

#--------------------------------------------------------------
# For WLMQueryDuration
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_query_duration" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_wlm_query_duration
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-wlm-query-duration"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WLMQueryDuration"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].wlm_query_duration
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WLMQueryDuration>(>= ${local.effective_thresholds[each.key].wlm_query_duration}Microseconds)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Microseconds"
  treat_missing_data        = "notBreaching"
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })

  tags = var.tags
}

#--------------------------------------------------------------
# For WLMRunningQueries
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_running_queries" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_wlm_running_queries
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-wlm-running-queries"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WLMRunningQueries"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].wlm_running_queries
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WLMRunningQueries>(>= ${local.effective_thresholds[each.key].wlm_running_queries})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })

  tags = var.tags
}

#--------------------------------------------------------------
# For WriteIOPS
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_iops" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_write_iops
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-write-iops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WriteIOPS"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].write_iops
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WriteIOPS>(>= ${local.effective_thresholds[each.key].write_iops})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For WriteLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_write_latency
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-write-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WriteLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].write_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WriteLatency>(>= ${local.effective_thresholds[each.key].write_latency}s)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For WriteThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_throughput" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_write_throughput
  }

  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-write-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Redshift"
  metric_name               = "WriteThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].write_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WriteThroughput>(>= ${local.effective_thresholds[each.key].write_throughput}Bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
