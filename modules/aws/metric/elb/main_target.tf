#--------------------------------------------------------------
# Target Metrics
# Reference: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
#--------------------------------------------------------------

#--------------------------------------------------------------
# For HTTPCode_Target_4XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_target_4xx_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_httpcode_4xx_count
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-target-4xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "HTTPCode_Target_4XX_Count"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_4xx_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode target 4xx count>(>= ${local.effective_thresholds[each.key].httpcode_4xx_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_Target_5XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_target_5xx_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_httpcode_5xx_count
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-target-5xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "HTTPCode_Target_5XX_Count"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_5xx_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode target 5xx count>(>= ${local.effective_thresholds[each.key].httpcode_5xx_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetResponseTime
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_response_time" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_target_response_time
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-response-time"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "TargetResponseTime"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].target_response_time
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target response time>(>= ${local.effective_thresholds[each.key].target_response_time})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Seconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetTLSNegotiationErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_tls_negotiation_error_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_target_tls_negotiation_error_count
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-tls-negotiation-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "TargetTLSNegotiationErrorCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_tls_negotiation_error_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target tls negotiation error count>(>= ${local.effective_thresholds[each.key].target_tls_negotiation_error_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For UnHealthyHostCount
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires LoadBalancer + TargetGroup dimensions
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "unhealthy_host_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_unhealthy_host_count && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-unhealthy-host-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "UnHealthyHostCount"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].unhealthy_host_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB unhealthy host count>(>= ${local.effective_thresholds[each.key].unhealthy_host_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For HealthyHostCount
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires LoadBalancer + TargetGroup dimensions
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "healthy_host_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_healthy_host_count && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-healthy-host-count"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "HealthyHostCount"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].healthy_host_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB healthy host count>(< ${local.effective_thresholds[each.key].healthy_host_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_Target_2XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_target_2xx_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_httpcode_target_2xx_count
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-target-2xx-count"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "HTTPCode_Target_2XX_Count"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_target_2xx_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode target 2xx count>(< ${local.effective_thresholds[each.key].httpcode_target_2xx_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_Target_3XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_target_3xx_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_httpcode_target_3xx_count
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-target-3xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "HTTPCode_Target_3XX_Count"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_target_3xx_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode target 3xx count>(>= ${local.effective_thresholds[each.key].httpcode_target_3xx_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For RequestCountPerTarget
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires TargetGroup dimension
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "request_count_per_target" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_request_count_per_target && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-request-count-per-target"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "RequestCountPerTarget"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].request_count_per_target
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB request count per target>(>= ${local.effective_thresholds[each.key].request_count_per_target})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetConnectionErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_connection_error_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_target_connection_error_count
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-connection-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "TargetConnectionErrorCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_connection_error_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target connection error count>(>= ${local.effective_thresholds[each.key].target_connection_error_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For AnomalousHostCount
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires TargetGroup + LoadBalancer dimensions
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "anomalous_host_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_anomalous_host_count && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-anomalous-host-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "AnomalousHostCount"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].anomalous_host_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB anomalous host count>(>= ${local.effective_thresholds[each.key].anomalous_host_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ZonalShiftedHostCount
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires LoadBalancer + TargetGroup dimensions
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "zonal_shifted_host_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_zonal_shifted_host_count && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-zonal-shifted-host-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "ZonalShiftedHostCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].zonal_shifted_host_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB zonal shifted host count>(>= ${local.effective_thresholds[each.key].zonal_shifted_host_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
