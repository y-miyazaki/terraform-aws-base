#--------------------------------------------------------------
# For ECS Container Insights metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_ecs_container_insights" {
  for_each = local.metric_regions["metric_resource_ecs_container_insights"]

  source = "../../modules/aws/metric/ecs_container_insights"

  is_enabled = each.value.is_enabled
  region     = local.monitor_regions[each.key]

  alarm_actions      = [module.aws_sns_subscription_lambda_metric[each.key].arn]
  dimensions         = each.value.dimensions
  name_prefix        = var.name_prefix
  ok_actions         = [module.aws_sns_subscription_lambda_metric[each.key].arn]
  period             = each.value.period
  threshold          = each.value.threshold
  threshold_override = each.value.threshold_override

  tags = var.tags
}
