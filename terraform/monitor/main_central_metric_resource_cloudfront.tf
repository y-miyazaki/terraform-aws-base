#--------------------------------------------------------------
# For CloudFront metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_cloudfront" {
  source = "../../modules/aws/metric/cloudfront"

  is_enabled = var.metric_resource_cloudfront.is_enabled
  region     = "us-east-1"

  alarm_actions                = [module.aws_sns_subscription_lambda_metric[local.is_enabled_global ? "global" : "primary"].arn]
  auto_dimensions_exclude_list = var.metric_resource_cloudfront.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_cloudfront.auto_dimensions_include_list
  create_auto_dimensions       = var.metric_resource_cloudfront.create_auto_dimensions
  dimensions                   = var.metric_resource_cloudfront.dimensions
  name_prefix                  = var.name_prefix
  ok_actions                   = [module.aws_sns_subscription_lambda_metric[local.is_enabled_global ? "global" : "primary"].arn]
  period                       = var.metric_resource_cloudfront.period
  threshold                    = var.metric_resource_cloudfront.threshold
  threshold_override           = var.metric_resource_cloudfront.threshold_override

  tags = var.tags
}
