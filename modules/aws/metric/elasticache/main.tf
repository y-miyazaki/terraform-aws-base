#--------------------------------------------------------------
# Module: aws/metric/elasticache
# Purpose: Provide CloudWatch metric alarms for ElastiCache (Redis) clusters across multiple performance and security dimensions.
# Notes: Unified tagging; supports multiple cluster dimensions; uses metric math for cache hit rate; supports auto-discovery of clusters.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "filter" {
  source     = "../../_internal/auto_discovery_filter"
  is_enabled = var.is_enabled

  create_auto       = var.create_auto_dimensions
  source_list       = var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list) : []
  include_list      = var.auto_dimensions_include_list
  exclude_list      = var.auto_dimensions_exclude_list
  manual_dimensions = var.dimensions
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/CacheMetrics.Redis.html"

  # Use filtered results from helper module
  auto_dimensions = module.filter.filtered_list
  safe_dimensions = module.filter.safe_manual_dimensions

  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : v => {
      name = v
      dimensions = {
        "CacheClusterId" = v
      }
    }
    } : {
    for v in local.safe_dimensions : v.CacheClusterId => {
      name       = v.CacheClusterId
      dimensions = v
    } if v != null && try(v.CacheClusterId, null) != null && v.CacheClusterId != ""
  }
}

#--------------------------------------------------------------
# For AuthenticationFailures
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "authentication_failures" {
  for_each = var.is_enabled && var.threshold.enabled_authentication_failures ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-authentication-failures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "AuthenticationFailures"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.authentication_failures
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache authentication failures>(>= ${var.threshold.authentication_failures})."
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
  for_each = var.is_enabled && var.threshold.enabled_cache_hit_rate ? local.list : {}

  alarm_name          = "${var.name_prefix}metric-elasticache-${each.value.name}-cache-hit-rate"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.threshold.cache_hit_rate
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ElastiCache cache hit rate>(<= ${var.threshold.cache_hit_rate}%)."
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
  for_each = var.is_enabled && var.threshold.enabled_command_authorization_failures ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-command-authorization-failures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "CommandAuthorizationFailures"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.command_authorization_failures
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache command authentication failures>(>= ${var.threshold.command_authorization_failures})."
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
  for_each = var.is_enabled && var.threshold.enabled_curr_connections ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-curr-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "CurrConnections"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.curr_connections
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache current connections>(>= ${var.threshold.curr_connections})."
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
  for_each = var.is_enabled && var.threshold.enabled_database_memory_usage_percentage ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-database-memory-usage-percentage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "DatabaseMemoryUsagePercentage"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.database_memory_usage_percentage
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache database memory usage percentage>(<= ${var.threshold.database_memory_usage_percentage}%)."
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
  for_each = var.is_enabled && var.threshold.enabled_engine_cpu_utilization ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-engine-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "EngineCPUUtilization"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.engine_cpu_utilization
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache Engine CPU Utilization>(>= ${var.threshold.engine_cpu_utilization}%)."
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
  for_each = var.is_enabled && var.threshold.enabled_error_count ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "ErrorCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.error_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache error count>(>= ${var.threshold.error_count})."
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
  for_each = var.is_enabled && var.threshold.enabled_evictions ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-evictions"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "Evictions"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.evictions
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache evictions>(>= ${var.threshold.evictions})."
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
  for_each = var.is_enabled && var.threshold.enabled_iam_authentication_expirations ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-iam-authentication-expirations"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "IamAuthenticationExpirations"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.iam_authentication_expirations
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache IAM authentication expirations>(>= ${var.threshold.iam_authentication_expirations})."
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
  for_each = var.is_enabled && var.threshold.enabled_iam_authentication_throttling ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-iam-authentication-throttling"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "IamAuthenticationThrottling"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.iam_authentication_throttling
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache IAM authentication throttling>(>= ${var.threshold.iam_authentication_throttling})."
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
  for_each = var.is_enabled && var.threshold.enabled_key_authorization_failures ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-key-authorization-failures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "KeyAuthorizationFailures"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.key_authorization_failures
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache key authorization failures>(>= ${var.threshold.key_authorization_failures})."
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
  for_each = var.is_enabled && var.threshold.enabled_memory_fragmentation_ratio ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-memory-fragmentation-ratio"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "MemoryFragmentationRatio"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.memory_fragmentation_ratio
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache memory fragmentation ratio>(>= ${var.threshold.memory_fragmentation_ratio})."
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
  for_each = var.is_enabled && var.threshold.enabled_new_connections ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-new-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "NewConnections"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.new_connections
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache new connections>(>= ${var.threshold.new_connections})."
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
  for_each = var.is_enabled && var.threshold.enabled_replication_bytes ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-replication-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "ReplicationBytes"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.replication_bytes
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache replication bytes>(>= ${var.threshold.replication_bytes})."
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
  for_each = var.is_enabled && var.threshold.enabled_replication_lag ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-replication-lag"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "ReplicationLag"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.replication_lag
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache replication lag>(>= ${var.threshold.replication_lag}s)."
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
  for_each = var.is_enabled && var.threshold.enabled_save_in_progress ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-save-in-progress"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "SaveInProgress"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.save_in_progress
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache save in progress>(>= ${var.threshold.save_in_progress})."
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
  for_each = var.is_enabled && var.threshold.enabled_successful_read_request_latency ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-successful-read-request-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "SuccessfulReadRequestLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.successful_read_request_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache successful read request latency>(>= ${var.threshold.successful_read_request_latency}μs)."
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
  for_each = var.is_enabled && var.threshold.enabled_successful_write_request_latency ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-successful-write-request-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "SuccessfulWriteRequestLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.successful_write_request_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache successful write request latency>(>= ${var.threshold.successful_write_request_latency}μs)."
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
  for_each = var.is_enabled && var.threshold.enabled_swap_usage ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-swap-usage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "SwapUsage"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.swap_usage
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache swap usage>(>= ${var.threshold.swap_usage}Bytes)."
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
  for_each = var.is_enabled && var.threshold.enabled_traffic_management_active ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-traffic-management-active"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ElastiCache"
  metric_name               = "TrafficManagementActive"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.traffic_management_active
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache traffic management active>(>= ${var.threshold.traffic_management_active})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
