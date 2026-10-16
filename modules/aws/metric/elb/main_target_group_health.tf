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
    if var.is_enabled && local.effective_thresholds[k].healthy_state_dns.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB healthy state DNS>(< ${local.effective_thresholds[each.key].healthy_state_dns.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-healthy-state-dns"
  comparison_operator       = "LessThanThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].healthy_state_dns.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].healthy_state_dns.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HealthyStateDNS"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].healthy_state_dns.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
    if var.is_enabled && local.effective_thresholds[k].healthy_state_routing.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB healthy state routing>(< ${local.effective_thresholds[each.key].healthy_state_routing.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-healthy-state-routing"
  comparison_operator       = "LessThanThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].healthy_state_routing.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].healthy_state_routing.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "HealthyStateRouting"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].healthy_state_routing.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
    if var.is_enabled && local.effective_thresholds[k].unhealthy_state_dns.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB unhealthy state DNS>(>= ${local.effective_thresholds[each.key].unhealthy_state_dns.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-unhealthy-state-dns"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].unhealthy_state_dns.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].unhealthy_state_dns.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "UnhealthyStateDNS"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Minimum"
  threshold                 = local.effective_thresholds[each.key].unhealthy_state_dns.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
    if var.is_enabled && local.effective_thresholds[k].unhealthy_state_routing.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB unhealthy state routing>(>= ${local.effective_thresholds[each.key].unhealthy_state_routing.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-unhealthy-state-routing"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].unhealthy_state_routing.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].unhealthy_state_routing.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "UnhealthyStateRouting"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Minimum"
  threshold                 = local.effective_thresholds[each.key].unhealthy_state_routing.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
    if var.is_enabled && local.effective_thresholds[k].unhealthy_routing_request_count.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB unhealthy routing request count>(>= ${local.effective_thresholds[each.key].unhealthy_routing_request_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-unhealthy-routing-request-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].unhealthy_routing_request_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].unhealthy_routing_request_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "UnhealthyRoutingRequestCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].unhealthy_routing_request_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}
