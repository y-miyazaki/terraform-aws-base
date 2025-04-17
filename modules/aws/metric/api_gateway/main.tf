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
  url = "https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-metrics-and-dimensions.html"
  auto_dimensions = var.create_auto_dimensions ? [
    for v in split(",", data.external.list[0].result.list) : split(":", v)[length(split(":", v)) - 1] if !anytrue([for el in var.auto_dimensions_exclude_list : strcontains(v, el)])
  ] : []
  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : v => {
      name = v
      dimensions = {
        "ApiName" = v
      }
    }
    } : {
    for v in var.dimensions : v.ApiName => {
      name       = v.ApiName
      dimensions = v
    }
  }
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
  for_each                  = var.is_enabled && var.threshold.enabled_error4XX ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-api-gateway-${each.value.name}-4xx-error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  threshold                 = var.threshold.error4XX
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|API Gateway 4XX errors>(>= ${var.threshold.error4XX}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  treat_missing_data        = "notBreaching"
  metric_query {
    id          = "e1"
    expression  = "m1 / m2 * 100"
    label       = "4XXError"
    return_data = true
  }
  metric_query {
    id          = "m1"
    return_data = false
    metric {
      dimensions  = each.value.dimensions
      metric_name = "4XXError"
      namespace   = "AWS/ApiGateway"
      period      = var.period
      stat        = "Sum"
      unit        = "Count"
    }
  }
  metric_query {
    id          = "m2"
    return_data = false
    metric {
      dimensions  = each.value.dimensions
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
  for_each                  = var.is_enabled && var.threshold.enabled_error5XX ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-api-gateway-${each.value.name}-5xx-error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  threshold                 = var.threshold.error5XX
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|API Gateway 5XX errors>(>= ${var.threshold.error5XX}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  treat_missing_data        = "notBreaching"
  metric_query {
    id          = "e1"
    expression  = "m1 / m2 * 100"
    label       = "5XXError"
    return_data = true
  }
  metric_query {
    id          = "m1"
    return_data = false
    metric {
      dimensions  = each.value.dimensions
      metric_name = "5XXError"
      namespace   = "AWS/ApiGateway"
      period      = var.period
      stat        = "Sum"
      unit        = "Count"
    }
  }
  metric_query {
    id          = "m2"
    return_data = false
    metric {
      dimensions  = each.value.dimensions
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
  for_each                  = var.is_enabled && var.threshold.enabled_latency ? local.list : {}
  alarm_name                = "${var.name_prefix}metric-api-gateway-${each.value.name}-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApiGateway"
  metric_name               = "Latency"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|API Gateway latency>(>= ${var.threshold.latency}msec)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions
  tags                      = local.tags
}
