#--------------------------------------------------------------
# For API Gateway metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_recipes_metric_api_gateway" {
  source        = "../../modules/aws/recipes/metric/api_gateway"
  is_enabled    = lookup(var.metric_resource_api_gateway, "is_enabled", true)
  period        = lookup(var.metric_resource_api_gateway, "period")
  threshold     = lookup(var.metric_resource_api_gateway, "threshold")
  alarm_actions = [module.aws_recipes_sns_subscription_lambda.arn]
  dimensions    = lookup(var.metric_resource_api_gateway, "dimensions")
  name_prefix   = var.name_prefix
  tags          = var.tags
}
