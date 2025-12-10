#--------------------------------------------------------------
# Module: aws/metric/lambda
# Purpose: Provide CloudWatch metric alarms for Lambda functions (concurrency, duration, errors, throttles) with optional auto-discovery.
# Notes: Unified tagging; auto discovery filters functions via exclude list.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "filter" {
  source     = "../../_internal/auto_discovery_filter"
  is_enabled = var.is_enabled

  create_auto       = var.create_auto_dimensions
  source_list       = data.aws_lambda_functions.this.function_names
  include_list      = var.auto_dimensions_include_list
  exclude_list      = var.auto_dimensions_exclude_list
  manual_dimensions = var.dimensions
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics.html"

  # Use filtered results from helper module
  auto_dimensions = module.filter.filtered_list
  safe_dimensions = module.filter.safe_manual_dimensions

  list = var.create_auto_dimensions ? {
    for v in local.auto_dimensions : v => {
      name = v
      dimensions = {
        "FunctionName" = v
      }
    }
    } : {
    for v in local.safe_dimensions : v.FunctionName => {
      name       = v.FunctionName
      dimensions = v
    } if v != null && try(v.FunctionName, null) != null && v.FunctionName != ""
  }
}

#--------------------------------------------------------------
# For AsyncEventAge
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "async_event_age" {
  for_each = var.is_enabled && var.threshold.enabled_async_event_age ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-async-event-age"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "AsyncEventAge"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.async_event_age
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda async event age>(>= ${var.threshold.async_event_age}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For AsyncEventsDropped
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "async_events_dropped" {
  for_each = var.is_enabled && var.threshold.enabled_async_events_dropped ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-async-events-dropped"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "AsyncEventsDropped"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.async_events_dropped
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda async events dropped>(>= ${var.threshold.async_events_dropped})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For AsyncEventsReceived
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "async_events_received" {
  for_each = var.is_enabled && var.threshold.enabled_async_events_received ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-async-events-received"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "AsyncEventsReceived"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.async_events_received
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda async events received>(>= ${var.threshold.async_events_received})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ClaimedAccountConcurrency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "claimed_account_concurrency" {
  for_each = var.is_enabled && var.threshold.enabled_claimed_account_concurrency ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-claimed-account-concurrency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "ClaimedAccountConcurrency"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.claimed_account_concurrency
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda claimed account concurrency>(>= ${var.threshold.claimed_account_concurrency})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ConcurrentExecutions
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "concurrent_executions" {
  for_each = var.is_enabled && var.threshold.enabled_concurrent_executions ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-concurrent-executions"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "ConcurrentExecutions"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.concurrent_executions
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda concurrent executions>(>= ${var.threshold.concurrent_executions})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DeadLetterErrors
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dead_letter_errors" {
  for_each = var.is_enabled && var.threshold.enabled_dead_letter_errors ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-dead-letter-errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "DeadLetterErrors"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.dead_letter_errors
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda dead letter errors>(>= ${var.threshold.dead_letter_errors})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For DestinationDeliveryFailures
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "destination_delivery_failures" {
  for_each = var.is_enabled && var.threshold.enabled_destination_delivery_failures ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-destination-delivery-failures"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "DestinationDeliveryFailures"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.destination_delivery_failures
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda destination delivery failures>(>= ${var.threshold.destination_delivery_failures})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For Duration
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "duration" {
  for_each = var.is_enabled && var.threshold.enabled_duration ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-duration"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "Duration"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.duration
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda duration>(>= ${var.threshold.duration}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For Errors
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "errors" {
  for_each = var.is_enabled && var.threshold.enabled_errors ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "Errors"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.errors
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda errors>(>= ${var.threshold.errors})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For Invocations
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "invocations" {
  for_each = var.is_enabled && var.threshold.enabled_invocations ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-invocations"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "Invocations"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.invocations
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda invocations>(>= ${var.threshold.invocations})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For IteratorAge
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "iterator_age" {
  for_each = var.is_enabled && var.threshold.enabled_iterator_age ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-iterator-age"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "IteratorAge"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.iterator_age
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda iterator age>(>= ${var.threshold.iterator_age}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For OffsetLag
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "offset_lag" {
  for_each = var.is_enabled && var.threshold.enabled_offset_lag ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-offset-lag"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "OffsetLag"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.offset_lag
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda offset lag>(>= ${var.threshold.offset_lag}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For PostRuntimeExtensionsDuration
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "post_runtime_extensions_duration" {
  for_each = var.is_enabled && var.threshold.enabled_post_runtime_extensions_duration ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-post-runtime-extensions-duration"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "PostRuntimeExtensionsDuration"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.post_runtime_extensions_duration
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda post runtime extensions duration>(>= ${var.threshold.post_runtime_extensions_duration}ms)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Milliseconds"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ProvisionedConcurrencyInvocations
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "provisioned_concurrency_invocations" {
  for_each = var.is_enabled && var.threshold.enabled_provisioned_concurrency_invocations ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-provisioned-concurrency-invocations"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "ProvisionedConcurrencyInvocations"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.provisioned_concurrency_invocations
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda provisioned concurrency invocations>(>= ${var.threshold.provisioned_concurrency_invocations})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ProvisionedConcurrencySpilloverInvocations
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "provisioned_concurrency_spillover_invocations" {
  for_each = var.is_enabled && var.threshold.enabled_provisioned_concurrency_spillover_invocations ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-provisioned-concurrency-spillover-invocations"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "ProvisionedConcurrencySpilloverInvocations"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.provisioned_concurrency_spillover_invocations
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda provisioned concurrency spillover invocations>(>= ${var.threshold.provisioned_concurrency_spillover_invocations})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For ProvisionedConcurrencyUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "provisioned_concurrency_utilization" {
  for_each = var.is_enabled && var.threshold.enabled_provisioned_concurrency_utilization ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-provisioned-concurrency-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "ProvisionedConcurrencyUtilization"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.provisioned_concurrency_utilization
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda provisioned concurrency utilization>(>= ${var.threshold.provisioned_concurrency_utilization}%)."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For RecursiveInvocationsDropped
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "recursive_invocations_dropped" {
  for_each = var.is_enabled && var.threshold.enabled_recursive_invocations_dropped ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-recursive-invocations-dropped"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "RecursiveInvocationsDropped"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.recursive_invocations_dropped
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda recursive invocations dropped>(>= ${var.threshold.recursive_invocations_dropped})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For Throttles
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "throttles" {
  for_each = var.is_enabled && var.threshold.enabled_throttles ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-throttles"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "Throttles"
  period                    = var.period
  statistic                 = "Sum"
  threshold                 = var.threshold.throttles
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda throttles>(>= ${var.threshold.throttles})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}

#--------------------------------------------------------------
# For UnreservedConcurrentExecutions
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "unreserved_concurrent_executions" {
  for_each = var.is_enabled && var.threshold.enabled_unreserved_concurrent_executions ? local.list : {}

  alarm_name                = "${var.name_prefix}metric-lambda-${each.value.name}-unreserved-concurrent-executions"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  namespace                 = "AWS/Lambda"
  metric_name               = "UnreservedConcurrentExecutions"
  period                    = var.period
  statistic                 = "Maximum"
  threshold                 = var.threshold.unreserved_concurrent_executions
  actions_enabled           = true
  alarm_actions             = var.alarm_actions
  alarm_description         = "This is an alarm to check for <${local.url}|Lambda unreserved concurrent executions>(>= ${var.threshold.unreserved_concurrent_executions})."
  insufficient_data_actions = var.insufficient_data_actions
  ok_actions                = var.ok_actions
  unit                      = "Count"
  treat_missing_data        = "notBreaching"
  dimensions                = each.value.dimensions

  tags = var.tags
}
