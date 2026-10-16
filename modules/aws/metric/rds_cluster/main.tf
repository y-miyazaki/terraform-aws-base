#--------------------------------------------------------------
# Module: aws/metric/rds_cluster
# Purpose: Provide CloudWatch metric alarms for Amazon RDS (Aurora/MySQL/PostgreSQL) cluster performance and resource utilization.
# Notes: Supports auto-discovery of DB clusters and engine-specific metrics; unified tagging already applied; future improvement: refine memory unit consistency and add missing engine variants.
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

#--------------------------------------------------------------
# Auto-discovery metric filter module
#--------------------------------------------------------------
module "helper" {
  source = "../../_internal/metric_helper"

  is_enabled = var.is_enabled

  base_threshold     = var.threshold
  create_auto        = var.create_auto_dimensions
  dimension_key      = "DBClusterIdentifier"
  exclude_list       = var.auto_dimensions_exclude_list
  include_list       = var.auto_dimensions_include_list
  manual_dimensions  = var.dimensions
  source_list        = data.aws_rds_clusters.this.cluster_identifiers
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraMySQL.Monitoring.Metrics.html"

  # Use filtered results from helper module
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
}

#--------------------------------------------------------------
# For CommitLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "commit_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].commit_latency.enabled && var.is_aurora && (var.is_mysql || var.is_postgresql)
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS commit latency>(>= ${local.effective_thresholds[each.key].commit_latency.value}ms)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-commit-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].commit_latency.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].commit_latency.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CommitLatency"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].commit_latency.value
  treat_missing_data        = "notBreaching"
  unit                      = "Milliseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUCreditBalance
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].cpu_credit_balance.enabled && length(regexall("(t2|t3)", var.db_instance_class)) > 0
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS CPU Credit Balance>(<= ${local.effective_thresholds[each.key].cpu_credit_balance.value})."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-cpu-credit-balance"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].cpu_credit_balance.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].cpu_credit_balance.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CPUCreditBalance"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].cpu_credit_balance.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
  alarm_description         = "This is an alarm to check for <${local.url}|RDS CPU Utilization>(>= ${local.effective_thresholds[each.key].cpu_utilization.value}%)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].cpu_utilization.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].cpu_utilization.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
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
  alarm_description         = "This is an alarm to check for <${local.url}|RDS database connections>(>= ${local.effective_thresholds[each.key].database_connections.value})."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-database-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].database_connections.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].database_connections.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DatabaseConnections"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].database_connections.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For Deadlocks
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "deadlocks" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].deadlocks.enabled && var.is_aurora && (var.is_mysql || var.is_postgresql)
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS deadlocks>(>= ${local.effective_thresholds[each.key].deadlocks.value})."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-deadlocks"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].deadlocks.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].deadlocks.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Deadlocks"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].deadlocks.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count/Second"

  tags = var.tags
}

#--------------------------------------------------------------
# For DeleteLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "delete_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].delete_latency.enabled && var.is_aurora && var.is_mysql
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS delete latency>(>= ${local.effective_thresholds[each.key].delete_latency.value}s)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-delete-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].delete_latency.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].delete_latency.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DeleteLatency"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].delete_latency.value
  treat_missing_data        = "notBreaching"
  unit                      = "Seconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For DiskQueueDepth
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "disk_queue_depth" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].disk_queue_depth.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS disk queue depth>(>= ${local.effective_thresholds[each.key].disk_queue_depth.value})."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-disk-queue-depth"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].disk_queue_depth.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].disk_queue_depth.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DiskQueueDepth"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].disk_queue_depth.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For FreeableMemory
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "freeable_memory" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].freeable_memory.enabled && var.is_aurora && (var.is_mysql || var.is_postgresql)
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS freeable memory>(<= ${local.effective_thresholds[each.key].freeable_memory.value}MB)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-freeable-memory"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].freeable_memory.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].freeable_memory.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "FreeableMemory"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].freeable_memory.value * 1024 * 1024 # input is MB, metric is Bytes
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

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
  alarm_description         = "This is an alarm to check for <${local.url}|RDS read latency>(>= ${local.effective_thresholds[each.key].read_latency.value}s)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-read-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].read_latency.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].read_latency.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ReadLatency"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].read_latency.value
  treat_missing_data        = "notBreaching"
  unit                      = "Seconds"

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
  alarm_description         = "This is an alarm to check for <${local.url}|RDS write latency(>= ${local.effective_thresholds[each.key].write_latency.value}s)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-write-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].write_latency.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].write_latency.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "WriteLatency"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].write_latency.value
  treat_missing_data        = "notBreaching"
  unit                      = "Seconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For AuroraReplicaLag
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "aurora_replica_lag" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].aurora_replica_lag.enabled && var.is_aurora
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS Aurora replica lag>(>= ${local.effective_thresholds[each.key].aurora_replica_lag.value}ms)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-aurora-replica-lag"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].aurora_replica_lag.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].aurora_replica_lag.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "AuroraReplicaLag"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].aurora_replica_lag.value
  treat_missing_data        = "notBreaching"
  unit                      = "Milliseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For BufferCacheHitRatio
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "buffer_cache_hit_ratio" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].buffer_cache_hit_ratio.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS buffer cache hit ratio>(<= ${local.effective_thresholds[each.key].buffer_cache_hit_ratio.value}%)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-buffer-cache-hit-ratio"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].buffer_cache_hit_ratio.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].buffer_cache_hit_ratio.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "BufferCacheHitRatio"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].buffer_cache_hit_ratio.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For EngineUptime
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "engine_uptime" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].engine_uptime.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS engine uptime>(<= ${local.effective_thresholds[each.key].engine_uptime.value}s)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-engine-uptime"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].engine_uptime.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].engine_uptime.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "EngineUptime"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].engine_uptime.value
  treat_missing_data        = "notBreaching"
  unit                      = "Seconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For FreeLocalStorage
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "free_local_storage" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].free_local_storage.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS free local storage>(<= ${local.effective_thresholds[each.key].free_local_storage.value}bytes)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-free-local-storage"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].free_local_storage.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].free_local_storage.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "FreeLocalStorage"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].free_local_storage.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

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
  alarm_description         = "This is an alarm to check for <${local.url}|RDS network receive throughput>(>= ${local.effective_thresholds[each.key].network_receive_throughput.value}bytes/sec)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-network-receive-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].network_receive_throughput.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].network_receive_throughput.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NetworkReceiveThroughput"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].network_receive_throughput.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes/Second"

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
  alarm_description         = "This is an alarm to check for <${local.url}|RDS network transmit throughput>(>= ${local.effective_thresholds[each.key].network_transmit_throughput.value}bytes/sec)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-network-transmit-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].network_transmit_throughput.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].network_transmit_throughput.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NetworkTransmitThroughput"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].network_transmit_throughput.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes/Second"

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
  alarm_description         = "This is an alarm to check for <${local.url}|RDS read IOPS>(>= ${local.effective_thresholds[each.key].read_iops.value})."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-read-iops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].read_iops.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].read_iops.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ReadIOPS"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].read_iops.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count/Second"

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
  alarm_description         = "This is an alarm to check for <${local.url}|RDS read throughput>(>= ${local.effective_thresholds[each.key].read_throughput.value}bytes/sec)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-read-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].read_throughput.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].read_throughput.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ReadThroughput"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].read_throughput.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes/Second"

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
  alarm_description         = "This is an alarm to check for <${local.url}|RDS write IOPS>(>= ${local.effective_thresholds[each.key].write_iops.value})."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-write-iops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].write_iops.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].write_iops.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "WriteIOPS"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].write_iops.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count/Second"

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
  alarm_description         = "This is an alarm to check for <${local.url}|RDS write throughput>(>= ${local.effective_thresholds[each.key].write_throughput.value}bytes/sec)."
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-write-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].write_throughput.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].write_throughput.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "WriteThroughput"
  namespace                 = "AWS/RDS"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].write_throughput.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes/Second"

  tags = var.tags
}
