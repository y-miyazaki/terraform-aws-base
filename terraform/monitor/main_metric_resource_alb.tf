#--------------------------------------------------------------
# For EC2 metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_recipes_metric_alb" {
  source        = "../../modules/aws/recipes/metric/alb"
  is_enabled    = lookup(var.metric_resource_alb, "is_enabled", true)
  period        = lookup(var.metric_resource_alb, "period")
  threshold     = lookup(var.metric_resource_alb, "threshold")
  alarm_actions = [module.aws_recipes_sns_subscription_lambda.arn]
  dimensions    = lookup(var.metric_resource_alb, "dimensions")
  name_prefix   = var.name_prefix
  tags          = var.tags
}
