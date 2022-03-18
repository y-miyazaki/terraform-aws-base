#--------------------------------------------------------------
# For API Gateway
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  url   = "https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-metrics-and-dimensions.html"
  count = length(var.dimensions) > 0 ? length(var.dimensions) : 1
  names = length(var.dimensions) > 0 ? flatten([
    for r in var.dimensions : {
      name = format("%s-", r.ApiName)
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
# For 4XXError
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_4xx" {
  count               = var.is_enabled && var.threshold.enabled_error4XX ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-api-gateway-${local.names[count.index].name}4xx-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.threshold.error4XX
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|API Gateway 4XX errors>(>= ${var.threshold.error4XX}%)."
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"
  metric_query {
    id          = "mq"
    expression  = "mq1 / mq2 * 100"
    label       = "4XXError"
    return_data = true
  }
  metric_query {
    id          = "mq1"
    return_data = false
    metric {
      dimensions  = local.is_dimensions ? var.dimensions[count.index] : null
      metric_name = "4XXError"
      namespace   = "AWS/ApiGateway"
      period      = var.period
      stat        = "Sum"
      unit        = "Count"
    }
  }
  metric_query {
    id          = "mq2"
    return_data = false
    metric {
      dimensions  = local.is_dimensions ? var.dimensions[count.index] : null
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = var.period
      stat        = "Sum"
      unit        = "Count"
    }
  }
  tags = local.tags
}
#--------------------------------------------------------------
# For 5XXError
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_5xx" {
  count               = var.is_enabled && var.threshold.enabled_error5XX ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-api-gateway-${local.names[count.index].name}5xx-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.threshold.error5XX
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|API Gateway 5XX errors>(>= ${var.threshold.error5XX}%)."
  ok_actions          = var.ok_actions
  treat_missing_data  = "notBreaching"
  metric_query {
    id          = "mq"
    expression  = "mq1 / mq2 * 100"
    label       = "5XXError"
    return_data = true
  }
  metric_query {
    id          = "mq1"
    return_data = false
    metric {
      dimensions  = local.is_dimensions ? var.dimensions[count.index] : null
      metric_name = "5XXError"
      namespace   = "AWS/ApiGateway"
      period      = var.period
      stat        = "Sum"
      unit        = "Count"
    }
  }
  metric_query {
    id          = "mq2"
    return_data = false
    metric {
      dimensions  = local.is_dimensions ? var.dimensions[count.index] : null
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = var.period
      stat        = "Sum"
      unit        = "Count"
    }
  }
  tags = local.tags
}

#--------------------------------------------------------------
# For Latency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "latency" {
  count               = var.is_enabled && var.threshold.enabled_latency ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-api-gateway-${local.names[count.index].name}latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/ApiGateway"
  metric_name         = "Latency"
  period              = var.period
  statistic           = "Maximum"
  threshold           = var.threshold.latency
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|API Gateway latency>(>= ${var.threshold.latency}msec)."
  ok_actions          = var.ok_actions
  unit                = "Milliseconds"
  treat_missing_data  = "notBreaching"
  dimensions          = local.is_dimensions ? var.dimensions[count.index] : null
  tags                = local.tags
}
