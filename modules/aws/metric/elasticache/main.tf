#--------------------------------------------------------------
# Module: aws/metric/elasticache
# Purpose: Provide CloudWatch metric alarms for ElastiCache (Redis) clusters across multiple performance and security dimensions.
# Notes: Unified tagging; supports multiple cluster dimensions; uses metric math for cache hit rate; supports auto-discovery of clusters.
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
  dimension_key      = "CacheClusterId"
  base_threshold     = var.threshold
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/CacheMetrics.Redis.html"

  # Use filtered results from helper module
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
}

#--------------------------------------------------------------
# For AuthenticationFailures
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "authentication_failures" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_authentication_failures
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-authentication-failures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "AuthenticationFailures"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].authentication_failures
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache authentication failures>(>= ${local.effective_thresholds[each.key].authentication_failures})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For CacheHitRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cache_hit_rate" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_cache_hit_rate
  }

  alarm_name          = "${var.name_prefix}metric-elasticache-${each.value.name}-cache-hit-rate"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.threshold.cache_hit_rate
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ElastiCache cache hit rate>(<= ${local.effective_thresholds[each.key].cache_hit_rate}%)."
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"
  metric_query {
    id          = "mq"
    expression  = "mq1 / (mq1 + mq2) * 100"
    label       = "CacheHitRate"
    return_data = true
  }
  metric_query {
    id          = "mq1"
    return_data = false
    metric {
      dimensions  = each.value.dimensions
      metric_name = "CacheHits"
      namespace   = "AWS/ElastiCache"
      period      = var.period
      stat        = "Sum"
    }
  }
  metric_query {
    id          = "mq2"
    return_data = false
    metric {
      dimensions  = each.value.dimensions
      metric_name = "CacheMisses"
      namespace   = "AWS/ElastiCache"
      period      = var.period
      stat        = "Sum"
    }
  }

  tags = var.tags
}

#--------------------------------------------------------------
# For CommandAuthorizationFailures
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "command_authorization_failures" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_command_authorization_failures
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-command-authorization-failures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "CommandAuthorizationFailures"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].command_authorization_failures
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache command authentication failures>(>= ${local.effective_thresholds[each.key].command_authorization_failures})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For CurrConnections
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "curr_connections" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_curr_connections
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-curr-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "CurrConnections"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].curr_connections
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache current connections>(>= ${local.effective_thresholds[each.key].curr_connections})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DatabaseMemoryUsagePercentage
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "database_memory_usage_percentage" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_database_memory_usage_percentage
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-database-memory-usage-percentage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "DatabaseMemoryUsagePercentage"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].database_memory_usage_percentage
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache database memory usage percentage>(<= ${local.effective_thresholds[each.key].database_memory_usage_percentage}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For EngineCPUUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "engine_cpu_utilization" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_engine_cpu_utilization
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-engine-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "EngineCPUUtilization"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].engine_cpu_utilization
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache Engine CPU Utilization>(>= ${local.effective_thresholds[each.key].engine_cpu_utilization}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_error_count
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "ErrorCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].error_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache error count>(>= ${local.effective_thresholds[each.key].error_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For Evictions
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "evictions" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_evictions
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-evictions"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "Evictions"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].evictions
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache evictions>(>= ${local.effective_thresholds[each.key].evictions})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
#--------------------------------------------------------------
# For IamAuthenticationExpirations
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "iam_authentication_expirations" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_iam_authentication_expirations
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-iam-authentication-expirations"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "IamAuthenticationExpirations"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].iam_authentication_expirations
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache IAM authentication expirations>(>= ${local.effective_thresholds[each.key].iam_authentication_expirations})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For IamAuthenticationThrottling
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "iam_authentication_throttling" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_iam_authentication_throttling
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-iam-authentication-throttling"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "IamAuthenticationThrottling"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].iam_authentication_throttling
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache IAM authentication throttling>(>= ${local.effective_thresholds[each.key].iam_authentication_throttling})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For KeyAuthorizationFailures
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "key_authorization_failures" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_key_authorization_failures
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-key-authorization-failures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "KeyAuthorizationFailures"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].key_authorization_failures
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache key authorization failures>(>= ${local.effective_thresholds[each.key].key_authorization_failures})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For MemoryFragmentationRatio
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_fragmentation_ratio" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_memory_fragmentation_ratio
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-memory-fragmentation-ratio"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "MemoryFragmentationRatio"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].memory_fragmentation_ratio
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache memory fragmentation ratio>(>= ${local.effective_thresholds[each.key].memory_fragmentation_ratio})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NewConnections
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "new_connections" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_new_connections
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-new-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "NewConnections"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].new_connections
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache new connections>(>= ${local.effective_thresholds[each.key].new_connections})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ReplicationBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "replication_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_replication_bytes
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-replication-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "ReplicationBytes"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].replication_bytes
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache replication bytes>(>= ${local.effective_thresholds[each.key].replication_bytes})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ReplicationLag
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "replication_lag" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_replication_lag
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-replication-lag"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "ReplicationLag"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].replication_lag
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache replication lag>(>= ${local.effective_thresholds[each.key].replication_lag}s)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For SaveInProgress
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "save_in_progress" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_save_in_progress
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-save-in-progress"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "SaveInProgress"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].save_in_progress
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache save in progress>(>= ${local.effective_thresholds[each.key].save_in_progress})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For SuccessfulReadRequestLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "successful_read_request_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_successful_read_request_latency
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-successful-read-request-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "SuccessfulReadRequestLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].successful_read_request_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache successful read request latency>(>= ${local.effective_thresholds[each.key].successful_read_request_latency}μs)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Microseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For SuccessfulWriteRequestLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "successful_write_request_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_successful_write_request_latency
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-successful-write-request-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "SuccessfulWriteRequestLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].successful_write_request_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache successful write request latency>(>= ${local.effective_thresholds[each.key].successful_write_request_latency}μs)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Microseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For SwapUsage
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "swap_usage" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_swap_usage
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-swap-usage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "SwapUsage"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].swap_usage
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache swap usage>(>= ${local.effective_thresholds[each.key].swap_usage}Bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For TrafficManagementActive
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "traffic_management_active" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_traffic_management_active
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-traffic-management-active"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "TrafficManagementActive"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].traffic_management_active
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache traffic management active>(>= ${local.effective_thresholds[each.key].traffic_management_active})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For CPUUtilization
# Provides a CloudWatch Metric Alarm resource.
# Note: Host-level CPU utilization, recommended for instances with < 4 vCPUs
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_cpu_utilization
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "CPUUtilization"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].cpu_utilization
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache CPU Utilization (Host-level)>(>= ${local.effective_thresholds[each.key].cpu_utilization}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For BytesUsedForCache
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bytes_used_for_cache" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_bytes_used_for_cache
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-bytes-used-for-cache"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "BytesUsedForCache"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].bytes_used_for_cache
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache bytes used for cache>(>= ${local.effective_thresholds[each.key].bytes_used_for_cache} Bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For FreeableMemory
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "freeable_memory" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_freeable_memory
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-freeable-memory"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "FreeableMemory"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].freeable_memory
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache freeable memory>(<= ${local.effective_thresholds[each.key].freeable_memory} Bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For CacheHits
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cache_hits" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_cache_hits
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-cache-hits"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "CacheHits"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].cache_hits
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache cache hits>(<= ${local.effective_thresholds[each.key].cache_hits})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For CacheMisses
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cache_misses" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_cache_misses
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-cache-misses"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "CacheMisses"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].cache_misses
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache cache misses>(>= ${local.effective_thresholds[each.key].cache_misses})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For CurrItems
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "curr_items" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_curr_items
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-curr-items"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "CurrItems"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].curr_items
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache current items>(>= ${local.effective_thresholds[each.key].curr_items})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkBytesIn
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_bytes_in" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_network_bytes_in
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-network-bytes-in"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "NetworkBytesIn"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].network_bytes_in
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache network bytes in>(>= ${local.effective_thresholds[each.key].network_bytes_in} Bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkBytesOut
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_bytes_out" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_network_bytes_out
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-network-bytes-out"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "NetworkBytesOut"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].network_bytes_out
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache network bytes out>(>= ${local.effective_thresholds[each.key].network_bytes_out} Bytes)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DatabaseCapacityUsagePercentage
# Provides a CloudWatch Metric Alarm resource.
# Note: Redis-only metric
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "database_capacity_usage_percentage" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_database_capacity_usage_percentage
  }

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-database-capacity-usage-percentage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "DatabaseCapacityUsagePercentage"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].database_capacity_usage_percentage
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache database capacity usage percentage>(>= ${local.effective_thresholds[each.key].database_capacity_usage_percentage}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
