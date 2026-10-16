#--------------------------------------------------------------
# For CloudFront metric
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_cloudfront" {
  source = "../../modules/aws/metric/cloudfront"

  is_enabled = local.is_enabled_global && var.metric_resource_cloudfront.is_enabled
  region     = "us-east-1"

  alarm_actions                = local.is_enabled_global ? [module.aws_sns_subscription_lambda_metric_us_east_1[0].arn] : []
  auto_dimensions_exclude_list = var.metric_resource_cloudfront.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_cloudfront.auto_dimensions_include_list
  create_auto_dimensions       = var.metric_resource_cloudfront.create_auto_dimensions
  dimensions                   = var.metric_resource_cloudfront.dimensions
  name_prefix                  = var.name_prefix
  ok_actions                   = local.is_enabled_global ? [module.aws_sns_subscription_lambda_metric_us_east_1[0].arn] : []
  period                       = var.metric_resource_cloudfront.period
  threshold                    = var.metric_resource_cloudfront.threshold
  threshold_override           = var.metric_resource_cloudfront.threshold_override

  tags = var.tags
}
