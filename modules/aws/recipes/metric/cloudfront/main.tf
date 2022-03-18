#--------------------------------------------------------------
# For CloudFront
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  url   = "https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/programming-cloudwatch-metrics.html"
  count = length(var.dimensions) > 0 ? length(var.dimensions) : 1
  names = length(var.dimensions) > 0 ? flatten([
    for r in var.dimensions : {
      name = format("%s-", r.DistributionId)
    }]) : [{
    name = ""
  }]
  is_dimensions = length(var.dimensions) > 0 ? true : false
  dimensions = length(var.dimensions) > 0 ? flatten([
    for r in var.dimensions : {
      DistributionId = r.DistributionId
      Region         = r.Region
    }]) : [{
  }]
  domains = length(var.dimensions) > 0 ? flatten([
    for r in var.dimensions : {
      Domain = r.Domain
    }]) : [{
  }]
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# For 404ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_401_rate" {
  count               = var.is_enabled && var.threshold.enabled_error_401_rate ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-cloudfront-${local.names[count.index].name}error-401-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/CloudFront"
  metric_name         = "401ErrorRate"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.error_401_rate
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for ${local.domains[count.index].Domain} <${local.url}|CloudFront 401 Error Rate>(>= ${var.threshold.error_401_rate}%)."
  ok_actions          = var.ok_actions
  unit                = "Percent"
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? local.dimensions[count.index] : null
  tags                = local.tags
}
#--------------------------------------------------------------
# For 403ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_403_rate" {
  count               = var.is_enabled && var.threshold.enabled_error_403_rate ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-cloudfront-${local.names[count.index].name}error-403-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/CloudFront"
  metric_name         = "403ErrorRate"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.error_403_rate
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for ${local.domains[count.index].Domain} <${local.url}|CloudFront 403 Error Rate>(>= ${var.threshold.error_403_rate}%)."
  ok_actions          = var.ok_actions
  unit                = "Percent"
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? local.dimensions[count.index] : null
  tags                = local.tags
}
#--------------------------------------------------------------
# For 404ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_404_rate" {
  count               = var.is_enabled && var.threshold.enabled_error_404_rate ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-cloudfront-${local.names[count.index].name}error-404-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/CloudFront"
  metric_name         = "404ErrorRate"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.error_404_rate
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for ${local.domains[count.index].Domain} <${local.url}|CloudFront 404 Error Rate>(>= ${var.threshold.error_404_rate}%)."
  ok_actions          = var.ok_actions
  unit                = "Percent"
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? local.dimensions[count.index] : null
  tags                = local.tags
}

#--------------------------------------------------------------
# For 502ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_502_rate" {
  count               = var.is_enabled && var.threshold.enabled_error_502_rate ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-cloudfront-${local.names[count.index].name}error-502-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/CloudFront"
  metric_name         = "502ErrorRate"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.error_502_rate
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for ${local.domains[count.index].Domain} <${local.url}|CloudFront 502 Error Rate>(>= ${var.threshold.error_502_rate}%)."
  ok_actions          = var.ok_actions
  unit                = "Percent"
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? local.dimensions[count.index] : null
  tags                = local.tags
}
#--------------------------------------------------------------
# For 503ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_503_rate" {
  count               = var.is_enabled && var.threshold.enabled_error_503_rate ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-cloudfront-${local.names[count.index].name}error-503-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/CloudFront"
  metric_name         = "503ErrorRate"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.error_503_rate
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for ${local.domains[count.index].Domain} <${local.url}|CloudFront 503 Error Rate>(>= ${var.threshold.error_503_rate}%)."
  ok_actions          = var.ok_actions
  unit                = "Percent"
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? local.dimensions[count.index] : null
  tags                = local.tags
}
#--------------------------------------------------------------
# For 504ErrorRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_504_rate" {
  count               = var.is_enabled && var.threshold.enabled_error_504_rate ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-cloudfront-${local.names[count.index].name}error-504-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/CloudFront"
  metric_name         = "504ErrorRate"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.error_504_rate
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for ${local.domains[count.index].Domain} <${local.url}|CloudFront 504 Error Rate>(>= ${var.threshold.error_504_rate}%)."
  ok_actions          = var.ok_actions
  unit                = "Percent"
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? local.dimensions[count.index] : null
  tags                = local.tags
}
#--------------------------------------------------------------
# For CacheHitRate
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cache_hit_rate" {
  count               = var.is_enabled && var.threshold.enabled_cache_hit_rate ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-cloudfront-${local.names[count.index].name}cache-hit-rate"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/CloudFront"
  metric_name         = "CacheHitRate"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.cache_hit_rate
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for ${local.domains[count.index].Domain} <${local.url}|CloudFront cache hit rate>(<= ${var.threshold.cache_hit_rate}%)."
  ok_actions          = var.ok_actions
  unit                = "Percent"
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? local.dimensions[count.index] : null
  tags                = local.tags
}
#--------------------------------------------------------------
# For OriginLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "origin_latency" {
  count               = var.is_enabled && var.threshold.enabled_origin_latency ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-cloudfront-${local.names[count.index].name}origin-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/CloudFront"
  metric_name         = "OriginLatency"
  period              = var.period
  extended_statistic  = "p90"
  threshold           = var.threshold.origin_latency
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for ${local.domains[count.index].Domain} <${local.url}|CloudFront origin latency>(>= ${var.threshold.origin_latency}msec)."
  ok_actions          = var.ok_actions
  unit                = "Milliseconds"
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? local.dimensions[count.index] : null
  tags                = local.tags
}

#--------------------------------------------------------------
# For CloudFront create monitoring subscription
#--------------------------------------------------------------
resource "null_resource" "this" {
  count = var.is_enabled ? local.count : 0
  triggers = {
    name = var.dimensions[count.index].DistributionId
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
