#--------------------------------------------------------------
# For ECS Container Insights metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_ecs_container_insights" {
  source = "../../modules/aws/metric/ecs_container_insights"

  is_enabled = var.metric_resource_ecs_container_insights.is_enabled
  region     = var.region.primary

  alarm_actions      = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions         = var.metric_resource_ecs_container_insights.dimensions
  name_prefix        = var.name_prefix
  ok_actions         = [module.aws_sns_subscription_lambda_metric.arn]
  period             = var.metric_resource_ecs_container_insights.period
  threshold          = var.metric_resource_ecs_container_insights.threshold
  threshold_override = var.metric_resource_ecs_container_insights.threshold_override

  tags = var.tags
}
