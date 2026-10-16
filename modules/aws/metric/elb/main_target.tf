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
    if var.is_enabled && local.effective_thresholds[k].httpcode_4xx_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode target 4xx count>(>= ${local.effective_thresholds[each.key].httpcode_4xx_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-target-4xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].httpcode_4xx_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].httpcode_4xx_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTPCode_Target_4XX_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_4xx_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_Target_5XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_target_5xx_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].httpcode_5xx_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode target 5xx count>(>= ${local.effective_thresholds[each.key].httpcode_5xx_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-target-5xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].httpcode_5xx_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].httpcode_5xx_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTPCode_Target_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_5xx_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetResponseTime
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_response_time" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].target_response_time.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target response time>(>= ${local.effective_thresholds[each.key].target_response_time.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-response-time"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_response_time.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_response_time.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].target_response_time.value
  treat_missing_data        = "notBreaching"
  unit                      = "Seconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetTLSNegotiationErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_tls_negotiation_error_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].target_tls_negotiation_error_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target tls negotiation error count>(>= ${local.effective_thresholds[each.key].target_tls_negotiation_error_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-tls-negotiation-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_tls_negotiation_error_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_tls_negotiation_error_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetTLSNegotiationErrorCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_tls_negotiation_error_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
    if var.is_enabled && local.effective_thresholds[k].unhealthy_host_count.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB unhealthy host count>(>= ${local.effective_thresholds[each.key].unhealthy_host_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-unhealthy-host-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].unhealthy_host_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].unhealthy_host_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].unhealthy_host_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
    if var.is_enabled && local.effective_thresholds[k].healthy_host_count.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB healthy host count>(< ${local.effective_thresholds[each.key].healthy_host_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-healthy-host-count"
  comparison_operator       = "LessThanThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].healthy_host_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].healthy_host_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].healthy_host_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_Target_2XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_target_2xx_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].httpcode_target_2xx_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode target 2xx count>(< ${local.effective_thresholds[each.key].httpcode_target_2xx_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-target-2xx-count"
  comparison_operator       = "LessThanThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].httpcode_target_2xx_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].httpcode_target_2xx_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTPCode_Target_2XX_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_target_2xx_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For HTTPCode_Target_3XX_Count
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "httpcode_target_3xx_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].httpcode_target_3xx_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB httpcode target 3xx count>(>= ${local.effective_thresholds[each.key].httpcode_target_3xx_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-httpcode-target-3xx-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].httpcode_target_3xx_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].httpcode_target_3xx_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HTTPCode_Target_3XX_Count"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].httpcode_target_3xx_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
    if var.is_enabled && local.effective_thresholds[k].request_count_per_target.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB request count per target>(>= ${local.effective_thresholds[each.key].request_count_per_target.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-request-count-per-target"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].request_count_per_target.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].request_count_per_target.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "RequestCountPerTarget"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].request_count_per_target.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetConnectionErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_connection_error_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].target_connection_error_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target connection error count>(>= ${local.effective_thresholds[each.key].target_connection_error_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-connection-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_connection_error_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_connection_error_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetConnectionErrorCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_connection_error_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
    if var.is_enabled && local.effective_thresholds[k].anomalous_host_count.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB anomalous host count>(>= ${local.effective_thresholds[each.key].anomalous_host_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-anomalous-host-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].anomalous_host_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].anomalous_host_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "AnomalousHostCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].anomalous_host_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
    if var.is_enabled && local.effective_thresholds[k].zonal_shifted_host_count.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB zonal shifted host count>(>= ${local.effective_thresholds[each.key].zonal_shifted_host_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-zonal-shifted-host-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].zonal_shifted_host_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].zonal_shifted_host_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ZonalShiftedHostCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].zonal_shifted_host_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}
