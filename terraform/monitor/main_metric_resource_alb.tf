#--------------------------------------------------------------
# For ALB metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_alb" {
  source        = "../../modules/aws/metric/alb"
  is_enabled    = var.metric_resource_alb.is_enabled
  period        = var.metric_resource_alb.period
  threshold     = var.metric_resource_alb.threshold
  alarm_actions = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions    = var.metric_resource_alb.dimensions
  name_prefix   = var.name_prefix
  tags          = var.tags
}
