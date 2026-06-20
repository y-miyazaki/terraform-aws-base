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

  is_enabled  = var.is_enabled
  create_auto = var.create_auto_dimensions

  source_list        = data.aws_rds_clusters.this.cluster_identifiers
  include_list       = var.auto_dimensions_include_list
  exclude_list       = var.auto_dimensions_exclude_list
  manual_dimensions  = var.dimensions
  dimension_key      = "DBClusterIdentifier"
  base_threshold     = var.threshold
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
  for_each = var.is_enabled && var.threshold.enabled_commit_latency && var.is_aurora && (var.is_mysql || var.is_postgresql) ? local.list : {}

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-commit-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "CommitLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].commit_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS commit latency>(>= ${local.effective_thresholds[each.key].commit_latency}ms)."
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

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-cpu-credit-balance"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "CPUCreditBalance"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].cpu_credit_balance
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS CPU Credit Balance>(<= ${local.effective_thresholds[each.key].cpu_credit_balance})."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_cpu_utilization
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "CPUUtilization"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].cpu_utilization
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS CPU Utilization>(>= ${local.effective_thresholds[each.key].cpu_utilization}%)."
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

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-database-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "DatabaseConnections"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].database_connections
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS database connections>(>= ${local.effective_thresholds[each.key].database_connections})."
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

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-deadlocks"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "Deadlocks"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].deadlocks
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS deadlocks>(>= ${local.effective_thresholds[each.key].deadlocks})."
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

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-delete-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "DeleteLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].delete_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS delete latency>(>= ${local.effective_thresholds[each.key].delete_latency}s)."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_disk_queue_depth
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-disk-queue-depth"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "DiskQueueDepth"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].disk_queue_depth
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS disk queue depth>(>= ${local.effective_thresholds[each.key].disk_queue_depth})."
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

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-freeable-memory"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "FreeableMemory"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].freeable_memory
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS freeable memory>(<= ${local.effective_thresholds[each.key].freeable_memory}MB)."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_read_latency
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-read-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "ReadLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].read_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS read latency>(>= ${local.effective_thresholds[each.key].read_latency}s)."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_write_latency
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-write-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "WriteLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].write_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS write latency(>= ${local.effective_thresholds[each.key].write_latency}s)."
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

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-aurora-replica-lag"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "AuroraReplicaLag"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].aurora_replica_lag
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS Aurora replica lag>(>= ${local.effective_thresholds[each.key].aurora_replica_lag}ms)."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_buffer_cache_hit_ratio
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-buffer-cache-hit-ratio"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "BufferCacheHitRatio"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].buffer_cache_hit_ratio
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS buffer cache hit ratio>(<= ${local.effective_thresholds[each.key].buffer_cache_hit_ratio}%)."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_engine_uptime
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-engine-uptime"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "EngineUptime"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].engine_uptime
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS engine uptime>(<= ${local.effective_thresholds[each.key].engine_uptime}s)."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_free_local_storage
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-free-local-storage"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "FreeLocalStorage"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].free_local_storage
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS free local storage>(<= ${local.effective_thresholds[each.key].free_local_storage}bytes)."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_network_receive_throughput
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-network-receive-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "NetworkReceiveThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].network_receive_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS network receive throughput>(>= ${local.effective_thresholds[each.key].network_receive_throughput}bytes/sec)."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_network_transmit_throughput
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-network-transmit-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "NetworkTransmitThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].network_transmit_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS network transmit throughput>(>= ${local.effective_thresholds[each.key].network_transmit_throughput}bytes/sec)."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_read_iops
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-read-iops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "ReadIOPS"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].read_iops
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS read IOPS>(>= ${local.effective_thresholds[each.key].read_iops})."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_read_throughput
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-read-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "ReadThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].read_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS read throughput>(>= ${local.effective_thresholds[each.key].read_throughput}bytes/sec)."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_write_iops
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-write-iops"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "WriteIOPS"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].write_iops
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS write IOPS>(>= ${local.effective_thresholds[each.key].write_iops})."
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
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_write_throughput
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-rds-cluster-${each.value.name}-write-throughput"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/RDS"
  metric_name               = "WriteThroughput"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].write_throughput
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|RDS write throughput>(>= ${local.effective_thresholds[each.key].write_throughput}bytes/sec)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes/Second"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
