#--------------------------------------------------------------
# For EventBridge Scheduler metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_eventbridge_scheduler" {
  source = "../../modules/aws/metric/eventbridge_scheduler"

  is_enabled = var.metric_resource_eventbridge_scheduler.is_enabled
  region     = var.region.primary

  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  auto_dimensions_exclude_list = var.metric_resource_eventbridge_scheduler.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_eventbridge_scheduler.auto_dimensions_include_list
  create_auto_dimensions       = var.metric_resource_eventbridge_scheduler.create_auto_dimensions
  dimensions                   = var.metric_resource_eventbridge_scheduler.dimensions
  name_prefix                  = var.name_prefix
  ok_actions                   = [module.aws_sns_subscription_lambda_metric.arn]
  period                       = var.metric_resource_eventbridge_scheduler.period
  threshold                    = var.metric_resource_eventbridge_scheduler.threshold
  threshold_override           = var.metric_resource_eventbridge_scheduler.threshold_override

  tags = var.tags
}
