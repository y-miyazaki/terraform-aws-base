#--------------------------------------------------------------
# For ElastiCache
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  url   = "https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/CacheMetrics.Redis.html"
  count = length(var.dimensions) > 0 ? length(var.dimensions) : 1
  names = length(var.dimensions) > 0 ? flatten([
    for r in var.dimensions : {
      name = format("%s-", r.CacheClusterId)
    }]) : [{
    name = ""
  }]
  is_dimensions = length(var.dimensions) > 0 ? true : false
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# For AuthenticationFailures
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "authentication_failures" {
  count                     = var.is_enabled && var.threshold.enabled_authentication_failures ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-elasticache-${local.names[count.index].name}authentication-failures"
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
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For CacheHitRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cache_hit_rate" {
  count               = var.is_enabled && var.threshold.enabled_cache_hit_rate ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-elasticache-${local.names[count.index].name}cache-hit-rate"
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
      dimensions  = local.is_dimensions ? var.dimensions[count.index] : null
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
      dimensions  = local.is_dimensions ? var.dimensions[count.index] : null
      metric_name = "CacheMisses"
      namespace   = "AWS/ElastiCache"
      period      = var.period
      stat        = "Sum"
    }
  }
  tags = local.tags
}
#--------------------------------------------------------------
# For CommandAuthorizationFailures
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "command_authorization_failures" {
  count                     = var.is_enabled && var.threshold.enabled_command_authorization_failures ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-elasticache-${local.names[count.index].name}command-authorization-failures"
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
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For CurrConnections
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "curr_connections" {
  count                     = var.is_enabled && var.threshold.enabled_curr_connections ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-elasticache-${local.names[count.index].name}curr-connections"
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
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For DatabaseMemoryUsagePercentage
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "database_memory_usage_percentage" {
  count                     = var.is_enabled && var.threshold.enabled_database_memory_usage_percentage ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-elasticache-${local.names[count.index].name}database-memory-usage-percentage"
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
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For EngineCPUUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "engine_cpu_utilization" {
  count                     = var.is_enabled && var.threshold.enabled_engine_cpu_utilization ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-elasticache-${local.names[count.index].name}engine-cpu-utilization"
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
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For KeyAuthorizationFailures
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "key_authorization_failures" {
  count                     = var.is_enabled && var.threshold.enabled_key_authorization_failures ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-elasticache-${local.names[count.index].name}key-authorization-failures"
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
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For NewConnections
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "new_connections" {
  count                     = var.is_enabled && var.threshold.enabled_new_connections ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-elasticache-${local.names[count.index].name}new-connections"
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
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For SwapUsage
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "swap_usage" {
  count                     = var.is_enabled && var.threshold.enabled_swap_usage ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-elasticache-${local.names[count.index].name}swap-usage"
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
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
