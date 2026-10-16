#--------------------------------------------------------------
# Module: aws/metric/redshift
# Purpose: Provide CloudWatch metric alarms for Amazon Redshift clusters (performance, storage, query, WLM, and resource utilization).
# Notes: Includes auto-discovery of clusters via external script when enabled; unified tagging pattern applied; future improvement: replace external data source with native data source when possible.
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
  dimension_key      = "ClusterIdentifier"
  exclude_list       = var.auto_dimensions_exclude_list
  include_list       = var.auto_dimensions_include_list
  manual_dimensions  = var.dimensions
  source_list        = var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list) : []
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
    if var.is_enabled && local.effective_thresholds[k].commit_queue_length.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift CommitQueueLength>(>= ${local.effective_thresholds[each.key].commit_queue_length.value})."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-commit-queue-length"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].commit_queue_length.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].commit_queue_length.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CommitQueueLength"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].commit_queue_length.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ConcurrencyScalingActiveClusters
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "concurrency_scaling_active_clusters" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].concurrency_scaling_active_clusters.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ConcurrencyScalingActiveClusters>(>= ${local.effective_thresholds[each.key].concurrency_scaling_active_clusters.value})."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-concurrency-scaling-active-clusters"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].concurrency_scaling_active_clusters.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].concurrency_scaling_active_clusters.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ConcurrencyScalingActiveClusters"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].concurrency_scaling_active_clusters.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ConcurrencyScalingSeconds
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "concurrency_scaling_seconds" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].concurrency_scaling_seconds.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ConcurrencyScalingSeconds>(>= ${local.effective_thresholds[each.key].concurrency_scaling_seconds.value}s)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-concurrency-scaling-seconds"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].concurrency_scaling_seconds.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].concurrency_scaling_seconds.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ConcurrencyScalingSeconds"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].concurrency_scaling_seconds.value
  treat_missing_data        = "notBreaching"
  unit                      = "Seconds"

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
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift CPUUtilization>(>= ${local.effective_thresholds[each.key].cpu_utilization.value}%)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].cpu_utilization.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].cpu_utilization.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].cpu_utilization.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For DatabaseConnections
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "database_connections" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].database_connections.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift DatabaseConnections>(>= ${local.effective_thresholds[each.key].database_connections.value})."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-database-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].database_connections.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].database_connections.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DatabaseConnections"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].database_connections.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HealthStatus
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "health_status" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].health_status.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift HealthStatus>(< ${local.effective_thresholds[each.key].health_status.value})."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-health-status"
  comparison_operator       = "LessThanThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].health_status.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].health_status.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HealthStatus"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Minimum"
  threshold                 = local.effective_thresholds[each.key].health_status.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For MaintenanceMode
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "maintenance_mode" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].maintenance_mode.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift MaintenanceMode>(>= ${local.effective_thresholds[each.key].maintenance_mode.value})."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-maintenance-mode"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].maintenance_mode.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].maintenance_mode.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "MaintenanceMode"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].maintenance_mode.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For MaxConfiguredConcurrencyScalingClusters
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "max_configured_concurrency_scaling_clusters" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].max_configured_concurrency_scaling_clusters.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift MaxConfiguredConcurrencyScalingClusters>(>= ${local.effective_thresholds[each.key].max_configured_concurrency_scaling_clusters.value})."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-max-configured-concurrency-scaling-clusters"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].max_configured_concurrency_scaling_clusters.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].max_configured_concurrency_scaling_clusters.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "MaxConfiguredConcurrencyScalingClusters"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].max_configured_concurrency_scaling_clusters.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkReceiveThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_receive_throughput" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].network_receive_throughput.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift NetworkReceiveThroughput>(>= ${local.effective_thresholds[each.key].network_receive_throughput.value}Bytes/Second)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-network-receive-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].network_receive_throughput.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].network_receive_throughput.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NetworkReceiveThroughput"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].network_receive_throughput.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes/Second"

  tags = var.tags
}

#--------------------------------------------------------------
# For NumExceededSchemaQuotas
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "num_exceeded_schema_quotas" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].num_exceeded_schema_quotas.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift NumExceededSchemaQuotas>(> ${local.effective_thresholds[each.key].num_exceeded_schema_quotas.value})."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-num-exceeded-schema-quotas"
  comparison_operator       = "GreaterThanThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].num_exceeded_schema_quotas.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].num_exceeded_schema_quotas.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NumExceededSchemaQuotas"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].num_exceeded_schema_quotas.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkTransmitThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_transmit_throughput" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].network_transmit_throughput.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift NetworkTransmitThroughput>(>= ${local.effective_thresholds[each.key].network_transmit_throughput.value}Bytes/Second)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-network-transmit-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].network_transmit_throughput.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].network_transmit_throughput.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NetworkTransmitThroughput"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].network_transmit_throughput.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes/Second"

  tags = var.tags
}

#--------------------------------------------------------------
# For PercentageDiskSpaceUsed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "percentage_disk_space_used" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].percentage_disk_space_used.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift PercentageDiskSpaceUsed>(>= ${local.effective_thresholds[each.key].percentage_disk_space_used.value}%)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-percentage-disk-space-used"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].percentage_disk_space_used.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].percentage_disk_space_used.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "PercentageDiskSpaceUsed"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].percentage_disk_space_used.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For PercentageQuotaUsed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "percentage_quota_used" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].percentage_quota_used.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift PercentageQuotaUsed>(>= ${local.effective_thresholds[each.key].percentage_quota_used.value}%)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-percentage-quota-used"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].percentage_quota_used.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].percentage_quota_used.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "PercentageQuotaUsed"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].percentage_quota_used.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For QueriesCompletedPerSecond
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "queries_completed_per_second" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].queries_completed_per_second.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift QueriesCompletedPerSecond>(>= ${local.effective_thresholds[each.key].queries_completed_per_second.value})."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-queries-completed-per-second"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].queries_completed_per_second.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].queries_completed_per_second.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "QueriesCompletedPerSecond"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].queries_completed_per_second.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count/Second"

  tags = var.tags
}

#--------------------------------------------------------------
# For QueryDuration
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "query_duration" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].query_duration.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift QueryDuration>(>= ${local.effective_thresholds[each.key].query_duration.value}Microseconds)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-query-duration"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].query_duration.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].query_duration.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "QueryDuration"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].query_duration.value
  treat_missing_data        = "notBreaching"
  unit                      = "Microseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For QueryRuntimeBreakdown
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "query_runtime_breakdown" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].query_runtime_breakdown.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift QueryRuntimeBreakdown>(>= ${local.effective_thresholds[each.key].query_runtime_breakdown.value}Microseconds)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-query-runtime-breakdown"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].query_runtime_breakdown.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].query_runtime_breakdown.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "QueryRuntimeBreakdown"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].query_runtime_breakdown.value
  treat_missing_data        = "notBreaching"
  unit                      = "Microseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For ReadIOPS
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_iops" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].read_iops.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ReadIOPS>(>= ${local.effective_thresholds[each.key].read_iops.value})."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-read-iops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].read_iops.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].read_iops.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ReadIOPS"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].read_iops.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count/Second"

  tags = var.tags
}

#--------------------------------------------------------------
# For ReadLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].read_latency.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ReadLatency>(>= ${local.effective_thresholds[each.key].read_latency.value}s)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-read-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].read_latency.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].read_latency.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ReadLatency"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].read_latency.value
  treat_missing_data        = "notBreaching"
  unit                      = "Seconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For ReadThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_throughput" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].read_throughput.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift ReadThroughput>(>= ${local.effective_thresholds[each.key].read_throughput.value}Bytes)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-read-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].read_throughput.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].read_throughput.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ReadThroughput"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].read_throughput.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For RedshiftManagedStorageTotalCapacity
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "redshift_managed_storage_total_capacity" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].redshift_managed_storage_total_capacity.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift RedshiftManagedStorageTotalCapacity>(>= ${local.effective_thresholds[each.key].redshift_managed_storage_total_capacity.value}Megabytes)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-redshift-managed-storage-total-capacity"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].redshift_managed_storage_total_capacity.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].redshift_managed_storage_total_capacity.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "RedshiftManagedStorageTotalCapacity"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].redshift_managed_storage_total_capacity.value
  treat_missing_data        = "notBreaching"
  unit                      = "Megabytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For SchemaQuota
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "schema_quota" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].schema_quota.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift SchemaQuota>(>= ${local.effective_thresholds[each.key].schema_quota.value}Megabytes)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-schema-quota"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].schema_quota.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].schema_quota.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "SchemaQuota"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].schema_quota.value
  treat_missing_data        = "notBreaching"
  unit                      = "Megabytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For StorageUsed
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "storage_used" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].storage_used.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift StorageUsed>(>= ${local.effective_thresholds[each.key].storage_used.value}Megabytes)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-storage-used"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].storage_used.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].storage_used.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "StorageUsed"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].storage_used.value
  treat_missing_data        = "notBreaching"
  unit                      = "Megabytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For TotalTableCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "total_table_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].total_table_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift TotalTableCount>(>= ${local.effective_thresholds[each.key].total_table_count.value})."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-total-table-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].total_table_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].total_table_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TotalTableCount"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].total_table_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For WLMQueueLength
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_queue_length" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].wlm_queue_length.enabled
  }

  region              = local.region
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|Redshift WLMQueueLength>(>= ${local.effective_thresholds[each.key].wlm_queue_length.value})."
  alarm_name          = "${var.name_prefix}metric-redshift-${each.value.name}-wlm-queue-length"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = local.effective_thresholds[each.key].wlm_queue_length.datapoints_to_alarm
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })
  evaluation_periods        = local.effective_thresholds[each.key].wlm_queue_length.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "WLMQueueLength"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].wlm_queue_length.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For WLMQueueWaitTime
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_queue_wait_time" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].wlm_queue_wait_time.enabled
  }

  region              = local.region
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|Redshift WLMQueueWaitTime>(>= ${local.effective_thresholds[each.key].wlm_queue_wait_time.value}ms)."
  alarm_name          = "${var.name_prefix}metric-redshift-${each.value.name}-wlm-queue-wait-time"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = local.effective_thresholds[each.key].wlm_queue_wait_time.datapoints_to_alarm
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })
  evaluation_periods        = local.effective_thresholds[each.key].wlm_queue_wait_time.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "WLMQueueWaitTime"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].wlm_queue_wait_time.value
  treat_missing_data        = "notBreaching"
  unit                      = "Milliseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For WLMQueriesCompletedPerSecond
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_queries_completed_per_second" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].wlm_queries_completed_per_second.enabled
  }

  region              = local.region
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|Redshift WLMQueriesCompletedPerSecond>(>= ${local.effective_thresholds[each.key].wlm_queries_completed_per_second.value})."
  alarm_name          = "${var.name_prefix}metric-redshift-${each.value.name}-enabled-wlm-queries-completed-per-second"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = local.effective_thresholds[each.key].wlm_queries_completed_per_second.datapoints_to_alarm
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })
  evaluation_periods        = local.effective_thresholds[each.key].wlm_queries_completed_per_second.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "WLMQueriesCompletedPerSecond"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].wlm_queries_completed_per_second.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count/Second"

  tags = var.tags
}

#--------------------------------------------------------------
# For WLMQueryDuration
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_query_duration" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].wlm_query_duration.enabled
  }

  region              = local.region
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|Redshift WLMQueryDuration>(>= ${local.effective_thresholds[each.key].wlm_query_duration.value}Microseconds)."
  alarm_name          = "${var.name_prefix}metric-redshift-${each.value.name}-wlm-query-duration"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = local.effective_thresholds[each.key].wlm_query_duration.datapoints_to_alarm
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })
  evaluation_periods        = local.effective_thresholds[each.key].wlm_query_duration.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "WLMQueryDuration"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].wlm_query_duration.value
  treat_missing_data        = "notBreaching"
  unit                      = "Microseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For WLMRunningQueries
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "wlm_running_queries" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].wlm_running_queries.enabled
  }

  region              = local.region
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|Redshift WLMRunningQueries>(>= ${local.effective_thresholds[each.key].wlm_running_queries.value})."
  alarm_name          = "${var.name_prefix}metric-redshift-${each.value.name}-wlm-running-queries"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = local.effective_thresholds[each.key].wlm_running_queries.datapoints_to_alarm
  dimensions = merge(each.value.dimensions, {
    QueueName = "Default queue"
  })
  evaluation_periods        = local.effective_thresholds[each.key].wlm_running_queries.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "WLMRunningQueries"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].wlm_running_queries.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For WriteIOPS
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_iops" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].write_iops.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WriteIOPS>(>= ${local.effective_thresholds[each.key].write_iops.value})."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-write-iops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].write_iops.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].write_iops.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "WriteIOPS"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].write_iops.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count/Second"

  tags = var.tags
}

#--------------------------------------------------------------
# For WriteLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].write_latency.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WriteLatency>(>= ${local.effective_thresholds[each.key].write_latency.value}s)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-write-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].write_latency.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].write_latency.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "WriteLatency"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].write_latency.value
  treat_missing_data        = "notBreaching"
  unit                      = "Seconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For WriteThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_throughput" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].write_throughput.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Redshift WriteThroughput>(>= ${local.effective_thresholds[each.key].write_throughput.value}Bytes)."
  alarm_name                = "${var.name_prefix}metric-redshift-${each.value.name}-write-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].write_throughput.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].write_throughput.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "WriteThroughput"
  namespace                 = "AWS/Redshift"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].write_throughput.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}
