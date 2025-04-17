#--------------------------------------------------------------
# For Lambda metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_lambda" {
  source                       = "../../modules/aws/metric/lambda"
  is_enabled                   = var.metric_resource_lambda.is_enabled
  period                       = var.metric_resource_lambda.period
  threshold                    = var.metric_resource_lambda.threshold
  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  create_auto_dimensions       = var.metric_resource_lambda.create_auto_dimensions
  auto_dimensions_exclude_list = var.metric_resource_lambda.auto_dimensions_exclude_list
  dimensions                   = var.metric_resource_lambda.dimensions
  name_prefix                  = var.name_prefix
  tags                         = var.tags
}
