#--------------------------------------------------------------
# For API Gateway metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_api_gateway" {
  source                       = "../../modules/aws/metric/api_gateway"
  is_enabled                   = var.metric_resource_api_gateway.is_enabled
  period                       = var.metric_resource_api_gateway.period
  threshold                    = var.metric_resource_api_gateway.threshold
  create_auto_dimensions       = var.metric_resource_api_gateway.create_auto_dimensions
  auto_dimensions_exclude_list = var.metric_resource_api_gateway.auto_dimensions_exclude_list
  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions                   = var.metric_resource_api_gateway.dimensions
  name_prefix                  = var.name_prefix
  tags                         = var.tags
}
