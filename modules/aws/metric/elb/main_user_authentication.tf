#--------------------------------------------------------------
# User Authentication Metrics
# Reference: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
#--------------------------------------------------------------

#--------------------------------------------------------------
# For ELBAuthError
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "elb_auth_error" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].elb_auth_error.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB elb auth error>(>= ${local.effective_thresholds[each.key].elb_auth_error.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-elb-auth-error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].elb_auth_error.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].elb_auth_error.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ELBAuthError"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].elb_auth_error.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ELBAuthFailure
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "elb_auth_failure" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].elb_auth_failure.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB elb auth failure>(>= ${local.effective_thresholds[each.key].elb_auth_failure.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-elb-auth-failure"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].elb_auth_failure.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].elb_auth_failure.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ELBAuthFailure"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].elb_auth_failure.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ELBAuthLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "elb_auth_latency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].elb_auth_latency.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB elb auth latency>(>= ${local.effective_thresholds[each.key].elb_auth_latency.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-elb-auth-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].elb_auth_latency.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].elb_auth_latency.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ELBAuthLatency"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].elb_auth_latency.value
  treat_missing_data        = "notBreaching"
  unit                      = "Milliseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For ELBAuthRefreshTokenSuccess
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "elb_auth_refresh_token_success" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].elb_auth_refresh_token_success.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB elb auth refresh token success>(< ${local.effective_thresholds[each.key].elb_auth_refresh_token_success.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-elb-auth-refresh-token-success"
  comparison_operator       = "LessThanThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].elb_auth_refresh_token_success.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].elb_auth_refresh_token_success.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ELBAuthRefreshTokenSuccess"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].elb_auth_refresh_token_success.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ELBAuthSuccess
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "elb_auth_success" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].elb_auth_success.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB elb auth success>(< ${local.effective_thresholds[each.key].elb_auth_success.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-elb-auth-success"
  comparison_operator       = "LessThanThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].elb_auth_success.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].elb_auth_success.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ELBAuthSuccess"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].elb_auth_success.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ELBAuthUserClaimsSizeExceeded
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "elb_auth_user_claims_size_exceeded" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].elb_auth_user_claims_size_exceeded.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB elb auth user claims size exceeded>(>= ${local.effective_thresholds[each.key].elb_auth_user_claims_size_exceeded.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-elb-auth-user-claims-size-exceeded"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].elb_auth_user_claims_size_exceeded.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].elb_auth_user_claims_size_exceeded.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ELBAuthUserClaimsSizeExceeded"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].elb_auth_user_claims_size_exceeded.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}
