#--------------------------------------------------------------
# Module: aws/metric/api_gateway
# Purpose: Provide CloudWatch metric alarms for API Gateway (errors, latency) with optional auto-discovery of APIs.
# Notes: Unified tagging applied; thresholds and dimensions configurable; auto discovery excludes patterns via exclude list.
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

  source_list        = var.create_auto_dimensions && length(data.external.list) > 0 ? [for v in split(",", data.external.list[0].result.list) : split(":", v)[length(split(":", v)) - 1]] : []
  include_list       = var.auto_dimensions_include_list
  exclude_list       = var.auto_dimensions_exclude_list
  manual_dimensions  = var.dimensions
  dimension_key      = "ApiName"
  base_threshold     = var.threshold
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-metrics-and-dimensions.html"

  # Use filtered results from helper module
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
}

#--------------------------------------------------------------
# For 4XXError
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_4xx" {
  for_each = var.is_enabled && var.threshold.enabled_error4XX ? local.list : {}

  region                    = local.region
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

  tags = var.tags
}

#--------------------------------------------------------------
# For 5XXError
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "error_5xx" {
  for_each = var.is_enabled && var.threshold.enabled_error5XX ? local.list : {}

  region                    = local.region
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

  tags = var.tags
}

#--------------------------------------------------------------
# For Latency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_latency
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-api-gateway-${each.value.name}-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApiGateway"
  metric_name               = "Latency"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|API Gateway latency>(>= ${local.effective_thresholds[each.key].latency}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For IntegrationLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "integration_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_integration_latency
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-api-gateway-${each.value.name}-integration-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApiGateway"
  metric_name               = "IntegrationLatency"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].integration_latency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|API Gateway integration latency>(>= ${local.effective_thresholds[each.key].integration_latency}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
