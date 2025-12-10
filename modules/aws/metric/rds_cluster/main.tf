#--------------------------------------------------------------
# Module: aws/metric/rds_cluster
# Purpose: Provide CloudWatch metric alarms for Amazon RDS (Aurora/MySQL/PostgreSQL) cluster performance and resource utilization.
# Notes: Supports auto-discovery of DB clusters and engine-specific metrics; unified tagging already applied; future improvement: refine memory unit consistency and add missing engine variants.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "filter" {
  source     = "../../_internal/auto_discovery_filter"
  is_enabled = var.is_enabled

  create_auto       = var.create_auto_dimensions
  source_list       = data.aws_rds_clusters.this.cluster_identifiers
  include_list      = var.auto_dimensions_include_list
  exclude_list      = var.auto_dimensions_exclude_list
  manual_dimensions = var.dimensions
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraMySQL.Monitoring.Metrics.html"

  # Use filtered results from helper module
  auto_dimensions = module.filter.filtered_list
  safe_dimensions = module.filter.safe_manual_dimensions

  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : v => {
      name = v
      dimensions = {
        "DBClusterIdentifier" = v
      }
    }
    } : {
    for v in local.safe_dimensions : v.DBClusterIdentifier => {
      name       = v.DBClusterIdentifier
      dimensions = v
    } if v != null && try(v.DBClusterIdentifier, null) != null && v.DBClusterIdentifier != ""
  }
}

#--------------------------------------------------------------
# For CommitLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "commit_latency" {
  for_each = var.is_enabled && var.threshold.enabled_commit_latency && var.is_aurora && (var.is_mysql || var.is_postgresql) ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-commit-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "CommitLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.commit_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS commit latency>(>= ${var.threshold.commit_latency}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUCreditBalance
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance" {
  for_each = var.is_enabled && var.threshold.enabled_cpu_credit_balance && length(regexall("(t2|t3)", var.db_instance_class)) > 0 ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-cpu-credit-balance"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "CPUCreditBalance"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.cpu_credit_balance
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS CPU Credit Balance>(<= ${var.threshold.cpu_credit_balance})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  for_each = var.is_enabled && var.threshold.enabled_cpu_utilization ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "CPUUtilization"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.cpu_utilization
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS CPU Utilization>(>= ${var.threshold.cpu_utilization}%)."
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
  for_each = var.is_enabled && var.threshold.enabled_database_connections ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-database-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "DatabaseConnections"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.database_connections
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS database connections>(>= ${var.threshold.database_connections})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For Deadlocks
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "deadlocks" {
  for_each = var.is_enabled && var.threshold.enabled_deadlocks && var.is_aurora && (var.is_mysql || var.is_postgresql) ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-deadlocks"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "Deadlocks"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.deadlocks
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS deadlocks>(>= ${var.threshold.deadlocks})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DeleteLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "delete_latency" {
  for_each = var.is_enabled && var.threshold.enabled_delete_latency && var.is_aurora && var.is_mysql ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-delete-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "DeleteLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.delete_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS delete latency>(>= ${var.threshold.delete_latency}s)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DiskQueueDepth
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "disk_queue_depth" {
  for_each = var.is_enabled && var.threshold.enabled_disk_queue_depth ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-disk-queue-depth"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "DiskQueueDepth"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.disk_queue_depth
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS disk queue depth>(>= ${var.threshold.disk_queue_depth})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For FreeableMemory
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "freeable_memory" {
  for_each = var.is_enabled && var.threshold.enabled_freeable_memory && var.is_aurora && var.is_mysql ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-freeable-memory"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "FreeableMemory"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.freeable_memory
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS freeable memory>(<= ${var.threshold.freeable_memory}MB)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Megabits"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ReadLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_latency" {
  for_each = var.is_enabled && var.threshold.enabled_read_latency ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-read-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "ReadLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.read_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS read latency>(>= ${var.threshold.read_latency}s)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For WriteLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_latency" {
  for_each = var.is_enabled && var.threshold.enabled_write_latency ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-write-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "WriteLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.write_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS write latency(>= ${var.threshold.write_latency}s)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For AuroraReplicaLag
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "aurora_replica_lag" {
  for_each = var.is_enabled && var.threshold.enabled_aurora_replica_lag && var.is_aurora ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-aurora-replica-lag"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "AuroraReplicaLag"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.aurora_replica_lag
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS Aurora replica lag>(>= ${var.threshold.aurora_replica_lag}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For BufferCacheHitRatio
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "buffer_cache_hit_ratio" {
  for_each = var.is_enabled && var.threshold.enabled_buffer_cache_hit_ratio ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-buffer-cache-hit-ratio"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "BufferCacheHitRatio"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.buffer_cache_hit_ratio
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS buffer cache hit ratio>(<= ${var.threshold.buffer_cache_hit_ratio}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For EngineUptime
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "engine_uptime" {
  for_each = var.is_enabled && var.threshold.enabled_engine_uptime ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-engine-uptime"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "EngineUptime"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.engine_uptime
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS engine uptime>(<= ${var.threshold.engine_uptime}s)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For FreeLocalStorage
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "free_local_storage" {
  for_each = var.is_enabled && var.threshold.enabled_free_local_storage ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-free-local-storage"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "FreeLocalStorage"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.free_local_storage
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS free local storage>(<= ${var.threshold.free_local_storage}bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkReceiveThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_receive_throughput" {
  for_each = var.is_enabled && var.threshold.enabled_network_receive_throughput ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-network-receive-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "NetworkReceiveThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.network_receive_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS network receive throughput>(>= ${var.threshold.network_receive_throughput}bytes/sec)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkTransmitThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_transmit_throughput" {
  for_each = var.is_enabled && var.threshold.enabled_network_transmit_throughput ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-network-transmit-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "NetworkTransmitThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.network_transmit_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS network transmit throughput>(>= ${var.threshold.network_transmit_throughput}bytes/sec)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ReadIOPS
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_iops" {
  for_each = var.is_enabled && var.threshold.enabled_read_iops ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-read-iops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "ReadIOPS"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.read_iops
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS read IOPS>(>= ${var.threshold.read_iops})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ReadThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_throughput" {
  for_each = var.is_enabled && var.threshold.enabled_read_throughput ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-read-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "ReadThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.read_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS read throughput>(>= ${var.threshold.read_throughput}bytes/sec)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For WriteIOPS
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_iops" {
  for_each = var.is_enabled && var.threshold.enabled_write_iops ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-write-iops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "WriteIOPS"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.write_iops
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS write IOPS>(>= ${var.threshold.write_iops})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For WriteThroughput
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_throughput" {
  for_each = var.is_enabled && var.threshold.enabled_write_throughput ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-write-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "WriteThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.write_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS write throughput>(>= ${var.threshold.write_throughput}bytes/sec)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
