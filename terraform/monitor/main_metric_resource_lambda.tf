#--------------------------------------------------------------
# For Lambda metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_recipes_metric_lambda" {
  source        = "../../modules/aws/recipes/metric/lambda"
  is_enabled    = lookup(var.metric_resource_lambda, "is_enabled", true)
  period        = lookup(var.metric_resource_lambda, "period")
  threshold     = lookup(var.metric_resource_lambda, "threshold")
  alarm_actions = [module.aws_recipes_sns_subscription_lambda_metric.arn]
  dimensions    = lookup(var.metric_resource_lambda, "dimensions")
  name_prefix   = var.name_prefix
  tags          = var.tags
}
