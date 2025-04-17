#--------------------------------------------------------------
# For ECS Container Insights metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_ecs_container_insights" {
  source        = "../../modules/aws/metric/ecs_container_insights"
  is_enabled    = var.metric_resource_ecs_container_insights.is_enabled
  period        = var.metric_resource_ecs_container_insights.period
  threshold     = var.metric_resource_ecs_container_insights.threshold
  alarm_actions = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions    = var.metric_resource_ecs_container_insights.dimensions
  name_prefix   = var.name_prefix
  tags          = var.tags
}
