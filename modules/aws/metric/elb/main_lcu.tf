#--------------------------------------------------------------
# LCU Metrics
# Reference: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
#--------------------------------------------------------------

#--------------------------------------------------------------
# For ConsumedLCUs
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric only supports LoadBalancer dimension (no AvailabilityZone)
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "consumed_lcus" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_consumed_lcus && !contains(keys(v.dimensions), "AvailabilityZone")
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-consumed-lcus"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "ConsumedLCUs"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].consumed_lcus
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB consumed lcus>(>= ${local.effective_thresholds[each.key].consumed_lcus})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PeakLCUs
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric only supports LoadBalancer dimension (no AvailabilityZone)
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "peak_lcus" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_peak_lcus && !contains(keys(v.dimensions), "AvailabilityZone")
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-peak-lcus"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "PeakLCUs"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].peak_lcus
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB peak lcus>(>= ${local.effective_thresholds[each.key].peak_lcus})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ReservedLCUs
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric only supports LoadBalancer dimension (no AvailabilityZone)
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "reserved_lcus" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_reserved_lcus && !contains(keys(v.dimensions), "AvailabilityZone")
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-reserved-lcus"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "ReservedLCUs"
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].reserved_lcus
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB reserved lcus>(>= ${local.effective_thresholds[each.key].reserved_lcus})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
