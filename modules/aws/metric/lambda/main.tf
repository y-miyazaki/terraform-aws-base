#--------------------------------------------------------------
# Module: aws/metric/lambda
# Purpose: Provide CloudWatch metric alarms for Lambda functions (concurrency, duration, errors, throttles) with optional auto-discovery.
# Notes: Unified tagging; auto discovery filters functions via exclude list.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

#--------------------------------------------------------------
# Auto-discovery metric filter module
#--------------------------------------------------------------
module "helper" {
  source = "../../_internal/metric_helper"

  is_enabled = var.is_enabled

  base_threshold     = var.threshold
  create_auto        = var.create_auto_dimensions
  dimension_key      = "FunctionName"
  exclude_list       = var.auto_dimensions_exclude_list
  include_list       = var.auto_dimensions_include_list
  manual_dimensions  = var.dimensions
  source_list        = data.aws_lambda_functions.this.function_names
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/monitoring-metrics-types.html"

  # Use filtered results from helper module
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
}

#--------------------------------------------------------------
# For AsyncEventAge
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "async_event_age" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].async_event_age.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda async event age>(>= ${local.effective_thresholds[each.key].async_event_age.value}ms)."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-async-event-age"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].async_event_age.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].async_event_age.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "AsyncEventAge"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].async_event_age.value
  treat_missing_data        = "notBreaching"
  unit                      = "Milliseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For AsyncEventsDropped
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "async_events_dropped" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].async_events_dropped.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda async events dropped>(>= ${local.effective_thresholds[each.key].async_events_dropped.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-async-events-dropped"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].async_events_dropped.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].async_events_dropped.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "AsyncEventsDropped"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].async_events_dropped.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For AsyncEventsReceived
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "async_events_received" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].async_events_received.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda async events received>(>= ${local.effective_thresholds[each.key].async_events_received.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-async-events-received"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].async_events_received.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].async_events_received.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "AsyncEventsReceived"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].async_events_received.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ClaimedAccountConcurrency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "claimed_account_concurrency" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].claimed_account_concurrency.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda claimed account concurrency>(>= ${local.effective_thresholds[each.key].claimed_account_concurrency.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-claimed-account-concurrency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].claimed_account_concurrency.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].claimed_account_concurrency.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ClaimedAccountConcurrency"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].claimed_account_concurrency.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ConcurrentExecutions
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "concurrent_executions" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].concurrent_executions.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda concurrent executions>(>= ${local.effective_thresholds[each.key].concurrent_executions.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-concurrent-executions"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].concurrent_executions.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].concurrent_executions.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ConcurrentExecutions"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].concurrent_executions.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For DeadLetterErrors
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dead_letter_errors" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].dead_letter_errors.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda dead letter errors>(>= ${local.effective_thresholds[each.key].dead_letter_errors.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-dead-letter-errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].dead_letter_errors.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].dead_letter_errors.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DeadLetterErrors"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].dead_letter_errors.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For DestinationDeliveryFailures
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "destination_delivery_failures" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].destination_delivery_failures.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda destination delivery failures>(>= ${local.effective_thresholds[each.key].destination_delivery_failures.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-destination-delivery-failures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].destination_delivery_failures.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].destination_delivery_failures.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "DestinationDeliveryFailures"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].destination_delivery_failures.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For Duration
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "duration" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].duration.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda duration>(>= ${local.effective_thresholds[each.key].duration.value}ms)."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-duration"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].duration.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].duration.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Duration"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].duration.value
  treat_missing_data        = "notBreaching"
  unit                      = "Milliseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For Errors
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "errors" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].errors.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda errors>(>= ${local.effective_thresholds[each.key].errors.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].errors.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].errors.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].errors.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For Invocations
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "invocations" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].invocations.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda invocations>(>= ${local.effective_thresholds[each.key].invocations.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-invocations"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].invocations.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].invocations.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Invocations"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].invocations.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For IteratorAge
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "iterator_age" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].iterator_age.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda iterator age>(>= ${local.effective_thresholds[each.key].iterator_age.value}ms)."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-iterator-age"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].iterator_age.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].iterator_age.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "IteratorAge"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].iterator_age.value
  treat_missing_data        = "notBreaching"
  unit                      = "Milliseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For OffsetLag
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "offset_lag" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].offset_lag.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda offset lag>(>= ${local.effective_thresholds[each.key].offset_lag.value}ms)."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-offset-lag"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].offset_lag.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].offset_lag.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "OffsetLag"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].offset_lag.value
  treat_missing_data        = "notBreaching"
  unit                      = "Milliseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For PostRuntimeExtensionsDuration
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "post_runtime_extensions_duration" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].post_runtime_extensions_duration.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda post runtime extensions duration>(>= ${local.effective_thresholds[each.key].post_runtime_extensions_duration.value}ms)."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-post-runtime-extensions-duration"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].post_runtime_extensions_duration.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].post_runtime_extensions_duration.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "PostRuntimeExtensionsDuration"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].post_runtime_extensions_duration.value
  treat_missing_data        = "notBreaching"
  unit                      = "Milliseconds"

  tags = var.tags
}

#--------------------------------------------------------------
# For ProvisionedConcurrentExecutions
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "provisioned_concurrent_executions" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].provisioned_concurrent_executions.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda provisioned concurrent executions>(>= ${local.effective_thresholds[each.key].provisioned_concurrent_executions.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-provisioned-concurrent-executions"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].provisioned_concurrent_executions.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].provisioned_concurrent_executions.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ProvisionedConcurrentExecutions"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].provisioned_concurrent_executions.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ProvisionedConcurrencyInvocations
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "provisioned_concurrency_invocations" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].provisioned_concurrency_invocations.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda provisioned concurrency invocations>(>= ${local.effective_thresholds[each.key].provisioned_concurrency_invocations.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-provisioned-concurrency-invocations"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].provisioned_concurrency_invocations.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].provisioned_concurrency_invocations.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ProvisionedConcurrencyInvocations"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].provisioned_concurrency_invocations.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ProvisionedConcurrencySpilloverInvocations
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "provisioned_concurrency_spillover_invocations" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].provisioned_concurrency_spillover_invocations.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda provisioned concurrency spillover invocations>(>= ${local.effective_thresholds[each.key].provisioned_concurrency_spillover_invocations.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-provisioned-concurrency-spillover-invocations"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].provisioned_concurrency_spillover_invocations.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].provisioned_concurrency_spillover_invocations.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ProvisionedConcurrencySpilloverInvocations"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].provisioned_concurrency_spillover_invocations.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For ProvisionedConcurrencyUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "provisioned_concurrency_utilization" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].provisioned_concurrency_utilization.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda provisioned concurrency utilization>(>= ${local.effective_thresholds[each.key].provisioned_concurrency_utilization.value}%)."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-provisioned-concurrency-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].provisioned_concurrency_utilization.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].provisioned_concurrency_utilization.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "ProvisionedConcurrencyUtilization"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].provisioned_concurrency_utilization.value
  treat_missing_data        = "notBreaching"
  unit                      = "Percent"

  tags = var.tags
}

#--------------------------------------------------------------
# For RecursiveInvocationsDropped
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "recursive_invocations_dropped" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].recursive_invocations_dropped.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda recursive invocations dropped>(>= ${local.effective_thresholds[each.key].recursive_invocations_dropped.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-recursive-invocations-dropped"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].recursive_invocations_dropped.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].recursive_invocations_dropped.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "RecursiveInvocationsDropped"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].recursive_invocations_dropped.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For Throttles
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "throttles" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].throttles.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda throttles>(>= ${local.effective_thresholds[each.key].throttles.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-throttles"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].throttles.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].throttles.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "Throttles"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = local.effective_thresholds[each.key].throttles.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}

#--------------------------------------------------------------
# For UnreservedConcurrentExecutions
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "unreserved_concurrent_executions" {
  for_each = {
    for k, v in local.list : k => v
    if var.is_enabled && local.effective_thresholds[k].unreserved_concurrent_executions.enabled
  }

  region                    = local.region
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda unreserved concurrent executions>(>= ${local.effective_thresholds[each.key].unreserved_concurrent_executions.value})."
  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-unreserved-concurrent-executions"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = local.effective_thresholds[each.key].unreserved_concurrent_executions.datapoints_to_alarm
  dimensions                = each.value.dimensions
  evaluation_periods        = local.effective_thresholds[each.key].unreserved_concurrent_executions.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = "UnreservedConcurrentExecutions"
  namespace                 = "AWS/Lambda"
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = local.effective_thresholds[each.key].unreserved_concurrent_executions.value
  treat_missing_data        = "notBreaching"
  unit                      = "Count"

  tags = var.tags
}
