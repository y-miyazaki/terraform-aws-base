#--------------------------------------------------------------
# Lambda Function Metrics
# Reference: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
#--------------------------------------------------------------

#--------------------------------------------------------------
# For LambdaInternalError
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires TargetGroup dimension
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "lambda_internal_error" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_lambda_internal_error && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-lambda-internal-error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "LambdaInternalError"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].lambda_internal_error
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB lambda internal error>(>= ${local.effective_thresholds[each.key].lambda_internal_error})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For LambdaTargetProcessedBytes
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric only supports LoadBalancer dimension (no AvailabilityZone)
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "lambda_target_processed_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_lambda_target_processed_bytes && !contains(keys(v.dimensions), "AvailabilityZone")
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-lambda-target-processed-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "LambdaTargetProcessedBytes"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].lambda_target_processed_bytes
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB lambda target processed bytes>(>= ${local.effective_thresholds[each.key].lambda_target_processed_bytes})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Bytes"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For LambdaUserError
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires TargetGroup dimension
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "lambda_user_error" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].enabled_lambda_user_error && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-lambda-user-error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "LambdaUserError"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].lambda_user_error
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB lambda user error>(>= ${local.effective_thresholds[each.key].lambda_user_error})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
