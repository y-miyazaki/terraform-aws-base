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
    if var.is_enabled && local.effective_thresholds[k].lambda_internal_error.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB lambda internal error>(>= ${local.effective_thresholds[each.key].lambda_internal_error.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-lambda-internal-error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].lambda_internal_error.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].lambda_internal_error.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "LambdaInternalError"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].lambda_internal_error.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

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
    if var.is_enabled && local.effective_thresholds[k].lambda_target_processed_bytes.enabled && !contains(keys(v.dimensions), "AvailabilityZone")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB lambda target processed bytes>(>= ${local.effective_thresholds[each.key].lambda_target_processed_bytes.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-lambda-target-processed-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].lambda_target_processed_bytes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].lambda_target_processed_bytes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "LambdaTargetProcessedBytes"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].lambda_target_processed_bytes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

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
    if var.is_enabled && local.effective_thresholds[k].lambda_user_error.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB lambda user error>(>= ${local.effective_thresholds[each.key].lambda_user_error.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-lambda-user-error"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].lambda_user_error.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].lambda_user_error.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "LambdaUserError"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].lambda_user_error.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}
