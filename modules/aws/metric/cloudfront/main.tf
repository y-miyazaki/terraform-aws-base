#--------------------------------------------------------------
# Module: aws/metric/cloudfront
# Purpose: Provide CloudWatch metric alarms for CloudFront distributions (error rates, cache performance, latency) with optional auto-discovery.
# Notes: Unified tagging; auto discovery gathers distributions & domains; uses local-exec for realtime metrics subscription lifecycle.
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
  dimension_key      = "DistributionId"
  exclude_list       = var.auto_dimensions_exclude_list
  include_list       = var.auto_dimensions_include_list
  manual_dimensions  = var.dimensions
  source_list        = var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list_distribution) : []
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url              = "https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/programming-cloudwatch-metrics.html"
  distribution_ids = var.is_enabled && var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list_distribution) : []
  domains          = var.is_enabled && var.create_auto_dimensions && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list_domain) : []
  # Domains are paired with IDs before filtering; the filtered list has different positions than the unfiltered one.
  domain_by_distribution_id = zipmap(local.distribution_ids, local.domains)

  # Use filtered results from helper module and combine with domains
  filtered_distributions = module.helper.filtered_list
  auto_dimensions = [
    for v in local.filtered_distributions : "${v}/${lookup(local.domain_by_distribution_id, v, "")}"
  ]
  safe_dimensions = module.helper.safe_manual_dimensions

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
      name = v.DistributionId
      # Domain is only used for the alarm description; default it to the distribution ID when omitted.
      dimensions = merge({ Domain = v.DistributionId }, v)
    } if v != null && try(v.DistributionId, null) != null && v.DistributionId != ""
  }

  # Effective thresholds from helper module
  effective_thresholds = module.helper.effective_thresholds
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

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront cache hit rate>(<= ${local.effective_thresholds[each.key].cache_hit_rate.value}%)."
  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-cache-hit-rate"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].cache_hit_rate.datapoints_to_alarm
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }
  evaluation_periods        = local.effective_thresholds[each.key].cache_hit_rate.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "CacheHitRate"
  namespace                 = "AWS/CloudFront"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].cache_hit_rate.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For 404ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_401_rate" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].error_401_rate.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront 401 Error Rate>(>= ${local.effective_thresholds[each.key].error_401_rate.value}%)."
  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-error-401-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].error_401_rate.datapoints_to_alarm
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }
  evaluation_periods        = local.effective_thresholds[each.key].error_401_rate.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "401ErrorRate"
  namespace                 = "AWS/CloudFront"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].error_401_rate.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For 403ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_403_rate" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].error_403_rate.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront 403 Error Rate>(>= ${local.effective_thresholds[each.key].error_403_rate.value}%)."
  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-error-403-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].error_403_rate.datapoints_to_alarm
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }
  evaluation_periods        = local.effective_thresholds[each.key].error_403_rate.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "403ErrorRate"
  namespace                 = "AWS/CloudFront"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].error_403_rate.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For 404ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_404_rate" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].error_404_rate.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront 404 Error Rate>(>= ${local.effective_thresholds[each.key].error_404_rate.value}%)."
  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-error-404-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].error_404_rate.datapoints_to_alarm
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }
  evaluation_periods        = local.effective_thresholds[each.key].error_404_rate.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "404ErrorRate"
  namespace                 = "AWS/CloudFront"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].error_404_rate.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For 502ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_502_rate" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].error_502_rate.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront 502 Error Rate>(>= ${local.effective_thresholds[each.key].error_502_rate.value}%)."
  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-error-502-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].error_502_rate.datapoints_to_alarm
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }
  evaluation_periods        = local.effective_thresholds[each.key].error_502_rate.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "502ErrorRate"
  namespace                 = "AWS/CloudFront"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].error_502_rate.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For 503ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_503_rate" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].error_503_rate.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront 503 Error Rate>(>= ${local.effective_thresholds[each.key].error_503_rate.value}%)."
  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-error-503-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].error_503_rate.datapoints_to_alarm
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }
  evaluation_periods        = local.effective_thresholds[each.key].error_503_rate.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "503ErrorRate"
  namespace                 = "AWS/CloudFront"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].error_503_rate.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For 504ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_504_rate" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].error_504_rate.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront 504 Error Rate>(>= ${local.effective_thresholds[each.key].error_504_rate.value}%)."
  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-error-504-rate"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].error_504_rate.datapoints_to_alarm
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }
  evaluation_periods        = local.effective_thresholds[each.key].error_504_rate.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "504ErrorRate"
  namespace                 = "AWS/CloudFront"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].error_504_rate.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For OriginLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "origin_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].origin_latency.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for ${each.value.dimensions.Domain} <${local.url}|CloudFront origin latency>(>= ${local.effective_thresholds[each.key].origin_latency.value}ms)."
  alarm_name                = "${var.name_prefix}metric-cloudfront-${each.value.name}-origin-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].origin_latency.datapoints_to_alarm
  dimensions                = { for k, v in each.value.dimensions : k => v if k != "Domain" }
  evaluation_periods        = local.effective_thresholds[each.key].origin_latency.evaluation_periods
  extended_statistic        = "p90"
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "OriginLatency"
  namespace                 = "AWS/CloudFront"
  ok_actions                = var.ok_actions
  period                    = var.period
  threshold                 = local.effective_thresholds[each.key].origin_latency.value
  treat_missing_data        = "notBreaching"
  unit                      = "Milliseconds"

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
