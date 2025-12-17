#--------------------------------------------------------------
# For EventBridge Scheduler metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_eventbridge_scheduler" {
  source     = "../../modules/aws/metric/eventbridge_scheduler"
  is_enabled = var.metric_resource_eventbridge_scheduler.is_enabled

  period                       = var.metric_resource_eventbridge_scheduler.period
  threshold                    = var.metric_resource_eventbridge_scheduler.threshold
  threshold_override           = var.metric_resource_eventbridge_scheduler.threshold_override
  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  ok_actions                   = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions                   = var.metric_resource_eventbridge_scheduler.dimensions
  create_auto_dimensions       = var.metric_resource_eventbridge_scheduler.create_auto_dimensions
  auto_dimensions_exclude_list = var.metric_resource_eventbridge_scheduler.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_eventbridge_scheduler.auto_dimensions_include_list
  name_prefix                  = var.name_prefix

  tags = var.tags
}
