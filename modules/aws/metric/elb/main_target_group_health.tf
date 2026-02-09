#--------------------------------------------------------------
# Target Group Health Metrics
# Reference: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
#--------------------------------------------------------------

#--------------------------------------------------------------
# For HealthyStateDNS
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires LoadBalancer + TargetGroup dimensions
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "healthy_state_dns" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_healthy_state_dns && contains(keys(v.dimensions), "TargetGroup")
  }

  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-healthy-state-dns"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "HealthyStateDNS"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].healthy_state_dns
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB healthy state DNS>(< ${local.effective_thresholds[each.key].healthy_state_dns})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For HealthyStateRouting
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires LoadBalancer + TargetGroup dimensions
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "healthy_state_routing" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_healthy_state_routing && contains(keys(v.dimensions), "TargetGroup")
  }

  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-healthy-state-routing"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "HealthyStateRouting"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].healthy_state_routing
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB healthy state routing>(< ${local.effective_thresholds[each.key].healthy_state_routing})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For UnhealthyStateDNS
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires LoadBalancer + TargetGroup dimensions
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "unhealthy_state_dns" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_unhealthy_state_dns && contains(keys(v.dimensions), "TargetGroup")
  }

  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-unhealthy-state-dns"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "UnhealthyStateDNS"
  period                    = var.period
  statistic                 = "Minimum"
  threshold                 = local.effective_thresholds[each.key].unhealthy_state_dns
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB unhealthy state DNS>(>= ${local.effective_thresholds[each.key].unhealthy_state_dns})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For UnhealthyStateRouting
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires LoadBalancer + TargetGroup dimensions
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "unhealthy_state_routing" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_unhealthy_state_routing && contains(keys(v.dimensions), "TargetGroup")
  }

  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-unhealthy-state-routing"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "UnhealthyStateRouting"
  period                    = var.period
  statistic                 = "Minimum"
  threshold                 = local.effective_thresholds[each.key].unhealthy_state_routing
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB unhealthy state routing>(>= ${local.effective_thresholds[each.key].unhealthy_state_routing})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For UnhealthyRoutingRequestCount
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires LoadBalancer + TargetGroup dimensions
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "unhealthy_routing_request_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_unhealthy_routing_request_count && contains(keys(v.dimensions), "TargetGroup")
  }

  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-unhealthy-routing-request-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "UnhealthyRoutingRequestCount"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].unhealthy_routing_request_count
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB unhealthy routing request count>(>= ${local.effective_thresholds[each.key].unhealthy_routing_request_count})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
