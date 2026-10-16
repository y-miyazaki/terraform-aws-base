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
    if var.is_enabled && local.effective_thresholds[k].consumed_lcus.enabled && !contains(keys(v.dimensions), "AvailabilityZone")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB consumed lcus>(>= ${local.effective_thresholds[each.key].consumed_lcus.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-consumed-lcus"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].consumed_lcus.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].consumed_lcus.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ConsumedLCUs"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].consumed_lcus.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
    if var.is_enabled && local.effective_thresholds[k].peak_lcus.enabled && !contains(keys(v.dimensions), "AvailabilityZone")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB peak lcus>(>= ${local.effective_thresholds[each.key].peak_lcus.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-peak-lcus"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].peak_lcus.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].peak_lcus.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "PeakLCUs"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].peak_lcus.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
    if var.is_enabled && local.effective_thresholds[k].reserved_lcus.enabled && !contains(keys(v.dimensions), "AvailabilityZone")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB reserved lcus>(>= ${local.effective_thresholds[each.key].reserved_lcus.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-reserved-lcus"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].reserved_lcus.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].reserved_lcus.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ReservedLCUs"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].reserved_lcus.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}
