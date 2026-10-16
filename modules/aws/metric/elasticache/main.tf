#--------------------------------------------------------------
# Module: aws/metric/elasticache
# Purpose: Provide CloudWatch metric alarms for ElastiCache (Redis) clusters across multiple performance and security dimensions.
# Notes: Unified tagging; supports multiple cluster dimensions; uses metric math for cache hit rate; supports auto-discovery of clusters.
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
  dimension_key      = "CacheClusterId"
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
    if var.is_enabled && local.effective_thresholds[k].authentication_failures.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache authentication failures>(>= ${local.effective_thresholds[each.key].authentication_failures.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-authentication-failures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].authentication_failures.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].authentication_failures.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "AuthenticationFailures"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].authentication_failures.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For CacheHitRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cache_hit_rate" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].cache_hit_rate.enabled
  }

  region              = local.region
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|ElastiCache cache hit rate>(<= ${local.effective_thresholds[each.key].cache_hit_rate.value}%)."
  alarm_name          = "${var.name_prefix}metric-elasticache-${each.value.name}-cache-hit-rate"
  comparison_operator = "LessThanOrEqualToThreshold"
  datapoints_to_alarm = local.effective_thresholds[each.key].cache_hit_rate.datapoints_to_alarm
  evaluation_periods  = local.effective_thresholds[each.key].cache_hit_rate.evaluation_periods
  ok_actions          = var.ok_actions
  threshold           = local.effective_thresholds[each.key].cache_hit_rate.value
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
    if var.is_enabled && local.effective_thresholds[k].command_authorization_failures.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache command authentication failures>(>= ${local.effective_thresholds[each.key].command_authorization_failures.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-command-authorization-failures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].command_authorization_failures.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].command_authorization_failures.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CommandAuthorizationFailures"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].command_authorization_failures.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For CurrConnections
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "curr_connections" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].curr_connections.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache current connections>(>= ${local.effective_thresholds[each.key].curr_connections.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-curr-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].curr_connections.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].curr_connections.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CurrConnections"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].curr_connections.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For DatabaseMemoryUsagePercentage
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "database_memory_usage_percentage" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].database_memory_usage_percentage.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache database memory usage percentage>(<= ${local.effective_thresholds[each.key].database_memory_usage_percentage.value}%)."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-database-memory-usage-percentage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].database_memory_usage_percentage.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].database_memory_usage_percentage.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DatabaseMemoryUsagePercentage"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].database_memory_usage_percentage.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For EngineCPUUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "engine_cpu_utilization" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].engine_cpu_utilization.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache Engine CPU Utilization>(>= ${local.effective_thresholds[each.key].engine_cpu_utilization.value}%)."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-engine-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].engine_cpu_utilization.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].engine_cpu_utilization.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "EngineCPUUtilization"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].engine_cpu_utilization.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For ErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].error_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache error count>(>= ${local.effective_thresholds[each.key].error_count.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].error_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].error_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ErrorCount"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].error_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For Evictions
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "evictions" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].evictions.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache evictions>(>= ${local.effective_thresholds[each.key].evictions.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-evictions"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].evictions.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].evictions.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Evictions"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].evictions.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}
#--------------------------------------------------------------
# For IamAuthenticationExpirations
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "iam_authentication_expirations" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].iam_authentication_expirations.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache IAM authentication expirations>(>= ${local.effective_thresholds[each.key].iam_authentication_expirations.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-iam-authentication-expirations"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].iam_authentication_expirations.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].iam_authentication_expirations.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "IamAuthenticationExpirations"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].iam_authentication_expirations.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For IamAuthenticationThrottling
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "iam_authentication_throttling" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].iam_authentication_throttling.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache IAM authentication throttling>(>= ${local.effective_thresholds[each.key].iam_authentication_throttling.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-iam-authentication-throttling"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].iam_authentication_throttling.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].iam_authentication_throttling.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "IamAuthenticationThrottling"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].iam_authentication_throttling.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For KeyAuthorizationFailures
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "key_authorization_failures" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].key_authorization_failures.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache key authorization failures>(>= ${local.effective_thresholds[each.key].key_authorization_failures.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-key-authorization-failures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].key_authorization_failures.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].key_authorization_failures.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "KeyAuthorizationFailures"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].key_authorization_failures.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For MemoryFragmentationRatio
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_fragmentation_ratio" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].memory_fragmentation_ratio.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache memory fragmentation ratio>(>= ${local.effective_thresholds[each.key].memory_fragmentation_ratio.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-memory-fragmentation-ratio"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].memory_fragmentation_ratio.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].memory_fragmentation_ratio.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "MemoryFragmentationRatio"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].memory_fragmentation_ratio.value
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# For NewConnections
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "new_connections" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].new_connections.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache new connections>(>= ${local.effective_thresholds[each.key].new_connections.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-new-connections"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].new_connections.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].new_connections.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NewConnections"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].new_connections.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ReplicationBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "replication_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].replication_bytes.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache replication bytes>(>= ${local.effective_thresholds[each.key].replication_bytes.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-replication-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].replication_bytes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].replication_bytes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ReplicationBytes"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].replication_bytes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For ReplicationLag
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "replication_lag" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].replication_lag.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache replication lag>(>= ${local.effective_thresholds[each.key].replication_lag.value}s)."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-replication-lag"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].replication_lag.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].replication_lag.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ReplicationLag"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].replication_lag.value
  treat_missing_data        = "notBreaching"
  unit                      = "Seconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For SaveInProgress
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "save_in_progress" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].save_in_progress.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache save in progress>(>= ${local.effective_thresholds[each.key].save_in_progress.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-save-in-progress"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].save_in_progress.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].save_in_progress.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "SaveInProgress"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].save_in_progress.value
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# For SuccessfulReadRequestLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "successful_read_request_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].successful_read_request_latency.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache successful read request latency>(>= ${local.effective_thresholds[each.key].successful_read_request_latency.value}μs)."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-successful-read-request-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].successful_read_request_latency.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].successful_read_request_latency.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "SuccessfulReadRequestLatency"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].successful_read_request_latency.value
  treat_missing_data        = "notBreaching"
  unit                      = "Microseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For SuccessfulWriteRequestLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "successful_write_request_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].successful_write_request_latency.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache successful write request latency>(>= ${local.effective_thresholds[each.key].successful_write_request_latency.value}μs)."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-successful-write-request-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].successful_write_request_latency.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].successful_write_request_latency.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "SuccessfulWriteRequestLatency"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].successful_write_request_latency.value
  treat_missing_data        = "notBreaching"
  unit                      = "Microseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For SwapUsage
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "swap_usage" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].swap_usage.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache swap usage>(>= ${local.effective_thresholds[each.key].swap_usage.value}Bytes)."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-swap-usage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].swap_usage.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].swap_usage.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "SwapUsage"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].swap_usage.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For TrafficManagementActive
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "traffic_management_active" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].traffic_management_active.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache traffic management active>(>= ${local.effective_thresholds[each.key].traffic_management_active.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-traffic-management-active"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].traffic_management_active.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].traffic_management_active.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TrafficManagementActive"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].traffic_management_active.value
  treat_missing_data        = "notBreaching"

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
    if var.is_enabled && local.effective_thresholds[k].cpu_utilization.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache CPU Utilization (Host-level)>(>= ${local.effective_thresholds[each.key].cpu_utilization.value}%)."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].cpu_utilization.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].cpu_utilization.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].cpu_utilization.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For BytesUsedForCache
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bytes_used_for_cache" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].bytes_used_for_cache.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache bytes used for cache>(>= ${local.effective_thresholds[each.key].bytes_used_for_cache.value} Bytes)."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-bytes-used-for-cache"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].bytes_used_for_cache.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].bytes_used_for_cache.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "BytesUsedForCache"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].bytes_used_for_cache.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For FreeableMemory
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "freeable_memory" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].freeable_memory.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache freeable memory>(<= ${local.effective_thresholds[each.key].freeable_memory.value} Bytes)."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-freeable-memory"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].freeable_memory.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].freeable_memory.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "FreeableMemory"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].freeable_memory.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For CacheHits
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cache_hits" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].cache_hits.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache cache hits>(<= ${local.effective_thresholds[each.key].cache_hits.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-cache-hits"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].cache_hits.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].cache_hits.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CacheHits"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].cache_hits.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For CacheMisses
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cache_misses" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].cache_misses.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache cache misses>(>= ${local.effective_thresholds[each.key].cache_misses.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-cache-misses"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].cache_misses.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].cache_misses.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CacheMisses"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].cache_misses.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For CurrItems
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "curr_items" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].curr_items.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache current items>(>= ${local.effective_thresholds[each.key].curr_items.value})."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-curr-items"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].curr_items.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].curr_items.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CurrItems"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].curr_items.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkBytesIn
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_bytes_in" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].network_bytes_in.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache network bytes in>(>= ${local.effective_thresholds[each.key].network_bytes_in.value} Bytes)."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-network-bytes-in"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].network_bytes_in.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].network_bytes_in.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NetworkBytesIn"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].network_bytes_in.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}

#--------------------------------------------------------------
# For NetworkBytesOut
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "network_bytes_out" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].network_bytes_out.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache network bytes out>(>= ${local.effective_thresholds[each.key].network_bytes_out.value} Bytes)."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-network-bytes-out"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].network_bytes_out.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].network_bytes_out.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "NetworkBytesOut"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].network_bytes_out.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

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
    if var.is_enabled && local.effective_thresholds[k].database_capacity_usage_percentage.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ElastiCache database capacity usage percentage>(>= ${local.effective_thresholds[each.key].database_capacity_usage_percentage.value}%)."
  alarm_name                = "${var.name_prefix}metric-elasticache-${each.value.name}-database-capacity-usage-percentage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].database_capacity_usage_percentage.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].database_capacity_usage_percentage.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DatabaseCapacityUsagePercentage"
  namespace                 = "AWS/ElastiCache"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].database_capacity_usage_percentage.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}
