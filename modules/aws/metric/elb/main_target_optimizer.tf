#--------------------------------------------------------------
# Target Optimizer Metrics
# Reference: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
#--------------------------------------------------------------

#--------------------------------------------------------------
# For MitigatedHostCount
# Provides a CloudWatch Metric Alarm resource.
# Note: This metric requires TargetGroup + LoadBalancer dimensions
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "mitigated_host_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].mitigated_host_count.enabled && contains(keys(v.dimensions), "TargetGroup")
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB mitigated host count>(>= ${local.effective_thresholds[each.key].mitigated_host_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-mitigated-host-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].mitigated_host_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].mitigated_host_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "MitigatedHostCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].mitigated_host_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetControlRequestCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_control_request_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].target_control_request_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target control request count>(>= ${local.effective_thresholds[each.key].target_control_request_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-control-request-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_control_request_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_control_request_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetControlRequestCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_control_request_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetOptimizerAnomalyScore
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_optimizer_anomaly_score" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].target_optimizer_anomaly_score.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target optimizer anomaly score>(>= ${local.effective_thresholds[each.key].target_optimizer_anomaly_score.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-optimizer-anomaly-score"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_optimizer_anomaly_score.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_optimizer_anomaly_score.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetOptimizerAnomalyScore"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Average"
  threshold                 = local.effective_thresholds[each.key].target_optimizer_anomaly_score.value
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetControlRequestRejectCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_control_request_reject_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].target_control_request_reject_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target control request reject count>(>= ${local.effective_thresholds[each.key].target_control_request_reject_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-control-request-reject-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_control_request_reject_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_control_request_reject_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetControlRequestRejectCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_control_request_reject_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetControlActiveChannelCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_control_active_channel_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].target_control_active_channel_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target control active channel count>(< ${local.effective_thresholds[each.key].target_control_active_channel_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-control-active-channel-count"
  comparison_operator       = "LessThanThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_control_active_channel_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_control_active_channel_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetControlActiveChannelCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_control_active_channel_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetControlChannelErrorCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_control_channel_error_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].target_control_channel_error_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target control channel error count>(>= ${local.effective_thresholds[each.key].target_control_channel_error_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-control-channel-error-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_control_channel_error_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_control_channel_error_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetControlChannelErrorCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_control_channel_error_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetControlNewChannelCount
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_control_new_channel_count" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].target_control_new_channel_count.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target control new channel count>(>= ${local.effective_thresholds[each.key].target_control_new_channel_count.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-control-new-channel-count"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_control_new_channel_count.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_control_new_channel_count.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetControlNewChannelCount"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_control_new_channel_count.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetControlWorkQueueLength
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_control_work_queue_length" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].target_control_work_queue_length.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target control work queue length>(>= ${local.effective_thresholds[each.key].target_control_work_queue_length.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-control-work-queue-length"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_control_work_queue_length.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_control_work_queue_length.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetControlWorkQueueLength"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_control_work_queue_length.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For TargetControlProcessedBytes
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "target_control_processed_bytes" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].target_control_processed_bytes.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|ALB target control processed bytes>(>= ${local.effective_thresholds[each.key].target_control_processed_bytes.value})."
  alarm_name                = "${var.name_prefix}metric-alb-${each.value.name}-target-control-processed-bytes"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].target_control_processed_bytes.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].target_control_processed_bytes.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "TargetControlProcessedBytes"
  namespace                 = "AWS/ApplicationELB"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].target_control_processed_bytes.value
  treat_missing_data        = "notBreaching"
  unit                      = "Bytes"

  tags = var.tags
}
