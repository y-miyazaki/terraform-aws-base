#--------------------------------------------------------------
# Module: aws/metric/cloudfront
# Purpose: Provide CloudWatch metric alarms for CloudFront distributions (error rates, cache performance, latency) with optional auto-discovery.
# Notes: Unified tagging; auto discovery gathers distributions & domains; uses local-exec for realtime metrics subscription lifecycle.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "filter" {
  source     = "../../_internal/auto_discovery_filter"
  is_enabled = var.is_enabled

  create_auto       = var.create_auto_dimensions
  source_list       = var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list_distribution) : []
  include_list      = var.auto_dimensions_include_list
  exclude_list      = var.auto_dimensions_exclude_list
  manual_dimensions = var.dimensions
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url     = "https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/programming-cloudwatch-metrics.html"
  domains = var.is_enabled && var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list_domain) : []

  # Use filtered results from helper module and combine with domains
  filtered_distributions = module.filter.filtered_list
  auto_dimensions = [
    for k, v in local.filtered_distributions : "${v}/${local.domains[k]}"
  ]
  safe_dimensions = module.filter.safe_manual_dimensions

  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : split("/", v)[0] => {
      name = split("/", v)[0]
      dimensions = {
        "DistributionId" = split("/", v)[0]
        "Region"         = "Global"
        "Domain"         = split("/", v)[1]
      }
    }
    } : {
    for v in local.safe_dimensions : v.DistributionId => {
      name       = v.DistributionId
      dimensions = v
    } if v != null && try(v.DistributionId, null) != null && v.DistributionId != ""
  }
}

#--------------------------------------------------------------
# For CacheHitRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cache_hit_rate" {
  for_each = var.is_enabled && var.threshold.enabled_cache_hit_rate ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-cache-hit-rate"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/CloudFront"
  metric_name               = "CacheHitRate"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.cache_hit_rate
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront cache hit rate>(<= ${var.threshold.cache_hit_rate}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }

  tags = var.tags
}

#--------------------------------------------------------------
# For 404ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_401_rate" {
  for_each = var.is_enabled && var.threshold.enabled_error_401_rate ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-error-401-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/CloudFront"
  metric_name               = "401ErrorRate"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.error_401_rate
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront 401 Error Rate>(>= ${var.threshold.error_401_rate}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }

  tags = var.tags
}

#--------------------------------------------------------------
# For 403ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_403_rate" {
  for_each = var.is_enabled && var.threshold.enabled_error_403_rate ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-error-403-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/CloudFront"
  metric_name               = "403ErrorRate"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.error_403_rate
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront 403 Error Rate>(>= ${var.threshold.error_403_rate}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }

  tags = var.tags
}

#--------------------------------------------------------------
# For 404ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_404_rate" {
  for_each = var.is_enabled && var.threshold.enabled_error_404_rate ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-error-404-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/CloudFront"
  metric_name               = "404ErrorRate"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.error_404_rate
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront 404 Error Rate>(>= ${var.threshold.error_404_rate}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }

  tags = var.tags
}

#--------------------------------------------------------------
# For 502ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_502_rate" {
  for_each = var.is_enabled && var.threshold.enabled_error_502_rate ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-error-502-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/CloudFront"
  metric_name               = "502ErrorRate"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.error_502_rate
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront 502 Error Rate>(>= ${var.threshold.error_502_rate}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }

  tags = var.tags
}

#--------------------------------------------------------------
# For 503ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_503_rate" {
  for_each = var.is_enabled && var.threshold.enabled_error_503_rate ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-error-503-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/CloudFront"
  metric_name               = "503ErrorRate"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.error_503_rate
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront 503 Error Rate>(>= ${var.threshold.error_503_rate}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }

  tags = var.tags
}

#--------------------------------------------------------------
# For 504ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_504_rate" {
  for_each = var.is_enabled && var.threshold.enabled_error_504_rate ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-error-504-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/CloudFront"
  metric_name               = "504ErrorRate"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.error_504_rate
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront 504 Error Rate>(>= ${var.threshold.error_504_rate}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Percent"
  treat_missing_data        = "notBreaching"
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }

  tags = var.tags
}

#--------------------------------------------------------------
# For OriginLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "origin_latency" {
  for_each = var.is_enabled && var.threshold.enabled_origin_latency ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-origin-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/CloudFront"
  metric_name               = "OriginLatency"
  period                    = var.period
  extended_statistic        = "p90"
  threshold                 = var.threshold.origin_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront origin latency>(>= ${var.threshold.origin_latency}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }

  tags = var.tags
}

#--------------------------------------------------------------
# For CloudFront create monitoring subscription
#--------------------------------------------------------------
resource "null_resource" "this" {
  for_each = var.is_enabled ? local.list : {}

  triggers = {
    name = each.value.dimensions.DistributionId
  }
  provisioner "local-exec" {
    # https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/viewing-cloudfront-metrics.html#monitoring-console.distributions-additional
    command = "aws cloudfront create-monitoring-subscription --distribution-id ${self.triggers.name} --monitoring-subscription RealtimeMetricsSubscriptionConfig={RealtimeMetricsSubscriptionStatus=Enabled}"
  }
  provisioner "local-exec" {
    when = destroy
    # https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/viewing-cloudfront-metrics.html#monitoring-console.distributions-additional
    command = "aws cloudfront delete-monitoring-subscription --distribution-id ${self.triggers.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
