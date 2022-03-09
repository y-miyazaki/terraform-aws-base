#--------------------------------------------------------------
# For ALB
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  url   = "https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html"
  count = length(var.dimensions) > 0 ? length(var.dimensions) : 1
  names = length(var.dimensions) > 0 ? flatten([
    for r in var.dimensions : {
      name = format("%s-", r.LoadBalancer)
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
# For ActiveConnectionCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "active_connection_count" {
  count                     = var.is_enabled && var.threshold.enabled_active_connection_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-alb-${local.names[count.index].name}active-connection-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "ActiveConnectionCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.active_connection_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB active connection count>(>= ${var.threshold.active_connection_count}%)."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For ClientTLSNegotiationErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "client_tls_negotiation_error_count" {
  count                     = var.is_enabled && var.threshold.enabled_client_tls_negotiation_error_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-alb-${local.names[count.index].name}client-tls-negotiation-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "ClientTLSNegotiationErrorCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.client_tls_negotiation_error_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB client tls negotiation error count>(>= ${var.threshold.client_tls_negotiation_error_count})."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For ConsumedLCUs
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "consumed_lcus" {
  count                     = var.is_enabled && var.threshold.enabled_consumed_lcus ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-alb-${local.names[count.index].name}consumed-lcus"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "ConsumedLCUs"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.consumed_lcus
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB cunsumed lcus>(>= ${var.threshold.consumed_lcus})."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For HTTPCode_4XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_4xx_count" {
  count                     = var.is_enabled && var.threshold.enabled_httpcode_4xx_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-alb-${local.names[count.index].name}httpcode-4xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "HTTPCode_4XX_Count"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.httpcode_4xx_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode 4xx count>(>= ${var.threshold.httpcode_4xx_count})."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For HTTPCode_5XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_5xx_count" {
  count                     = var.is_enabled && var.threshold.enabled_httpcode_5xx_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-alb-${local.names[count.index].name}httpcode-5xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "HTTPCode_5XX_Count"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.httpcode_5xx_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode 5xx count>(>= ${var.threshold.httpcode_5xx_count})."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For HTTPCode_ELB_4XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_elb_4xx_count" {
  count                     = var.is_enabled && var.threshold.enabled_httpcode_elb_4xx_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-alb-${local.names[count.index].name}httpcode-elb-4xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "HTTPCode_ELB_4XX_Count"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.httpcode_elb_4xx_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode elb 4xx count>(>= ${var.threshold.httpcode_elb_4xx_count})."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For HTTPCode_ELB_5XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_elb_5xx_count" {
  count                     = var.is_enabled && var.threshold.enabled_httpcode_elb_5xx_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-alb-${local.names[count.index].name}httpcode-elb-5xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "HTTPCode_ELB_5XX_Count"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.httpcode_elb_5xx_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode elb 5xx count>(>= ${var.threshold.httpcode_elb_5xx_count})."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For TargetResponseTime
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_response_time" {
  count                     = var.is_enabled && var.threshold.enabled_target_response_time ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-alb-${local.names[count.index].name}target-response-time"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "TargetResponseTime"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.target_response_time
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target response time>(>= ${var.threshold.target_response_time})."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For TargetTLSNegotiationErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_tls_negotiation_error_count" {
  count                     = var.is_enabled && var.threshold.enabled_target_tls_negotiation_error_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-alb-${local.names[count.index].name}target-tls-negotiation-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "TargetTLSNegotiationErrorCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.target_tls_negotiation_error_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target tls negotiation error count>(>= ${var.threshold.target_tls_negotiation_error_count})."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
#--------------------------------------------------------------
# For UnHealthyHostCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "unhealthy_host_count" {
  count                     = var.is_enabled && var.threshold.enabled_unhealthy_host_count ? local.count : 0
  alarm_name                = "${var.name_prefix}metric-alb-${local.names[count.index].name}unhealthy-host-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "UnHealthyHostCount"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = var.threshold.unhealthy_host_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB unhealthy host count>(>= ${var.threshold.unhealthy_host_count})."
  insufficient_data_actions = []
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = local.is_dimensions ? var.dimensions[count.index] : null
  tags                      = local.tags
}
