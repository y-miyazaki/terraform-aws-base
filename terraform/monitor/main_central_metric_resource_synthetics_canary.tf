#--------------------------------------------------------------
# Synthetics Canary Metrics
# Monitor synthetic endpoint availability using CloudWatch Synthetics.
# Supports both auto-discovery and manual dimension configuration.
# Configured via function-specific settings in metric_synthetics_canary variable.
#--------------------------------------------------------------
module "aws_metric_synthetics_canary" {
  for_each = var.metric_synthetics_canary.functions

  source     = "../../modules/aws/metric/synthetics_canary"
  is_enabled = each.value.is_enabled
  region     = var.region.primary

  period                       = each.value.period
  threshold                    = each.value.threshold
  create_auto_dimensions       = try(each.value.create_auto_dimensions, false)
  auto_dimensions_exclude_list = try(each.value.auto_dimensions_exclude_list, [])
  auto_dimensions_include_list = try(each.value.auto_dimensions_include_list, [])
  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  ok_actions                   = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions = each.value.is_enabled ? [
    {
      "CanaryName" = module.aws_synthetics_canary[each.key].name
    }
  ] : []
  name_prefix = var.name_prefix

  tags = var.tags
}
