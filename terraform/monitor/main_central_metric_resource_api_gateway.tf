#--------------------------------------------------------------
# For API Gateway metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_api_gateway" {
  source = "../../modules/aws/metric/api_gateway"

  is_enabled = var.metric_resource_api_gateway.is_enabled
  region     = var.region.primary

  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  auto_dimensions_exclude_list = var.metric_resource_api_gateway.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_api_gateway.auto_dimensions_include_list
  create_auto_dimensions       = var.metric_resource_api_gateway.create_auto_dimensions
  dimensions                   = var.metric_resource_api_gateway.dimensions
  name_prefix                  = var.name_prefix
  ok_actions                   = [module.aws_sns_subscription_lambda_metric.arn]
  period                       = var.metric_resource_api_gateway.period
  threshold                    = var.metric_resource_api_gateway.threshold
  threshold_override           = var.metric_resource_api_gateway.threshold_override

  tags = var.tags
}
