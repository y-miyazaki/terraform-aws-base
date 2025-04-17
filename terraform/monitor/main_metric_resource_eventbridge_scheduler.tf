#--------------------------------------------------------------
# For EventBridge Scheduler metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_eventbridge_scheduler" {
  source        = "../../modules/aws/metric/eventbridge_scheduler"
  is_enabled    = var.metric_resource_eventbridge_scheduler.is_enabled
  period        = var.metric_resource_eventbridge_scheduler.period
  threshold     = var.metric_resource_eventbridge_scheduler.threshold
  alarm_actions = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions    = var.metric_resource_eventbridge_scheduler.dimensions
  name_prefix   = var.name_prefix
  tags          = var.tags
}
