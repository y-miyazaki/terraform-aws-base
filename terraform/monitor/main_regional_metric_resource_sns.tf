#--------------------------------------------------------------
# For SNS metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_sns" {
  for_each = local.metric_regions["metric_resource_sns"]

  source = "../../modules/aws/metric/sns"

  is_enabled = each.value.is_enabled
  region     = local.monitor_regions[each.key]

  alarm_actions                = [module.aws_sns_subscription_lambda_metric[each.key].arn]
  auto_dimensions_exclude_list = each.value.auto_dimensions_exclude_list
  auto_dimensions_include_list = each.value.auto_dimensions_include_list
  create_auto_dimensions       = each.value.create_auto_dimensions
  dimensions                   = each.value.dimensions
  name_prefix                  = var.name_prefix
  ok_actions                   = [module.aws_sns_subscription_lambda_metric[each.key].arn]
  period                       = each.value.period
  threshold                    = each.value.threshold
  threshold_override           = each.value.threshold_override

  tags = var.tags
}
