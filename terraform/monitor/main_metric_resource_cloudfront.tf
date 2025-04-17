#--------------------------------------------------------------
# For CloudFront metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_cloudfront" {
  source = "../../modules/aws/metric/cloudfront"
  providers = {
    aws = aws.us-east-1
  }
  is_enabled                   = var.metric_resource_cloudfront.is_enabled
  period                       = var.metric_resource_cloudfront.period
  threshold                    = var.metric_resource_cloudfront.threshold
  alarm_actions                = [module.aws_sns_subscription_lambda_metric_us_east_1.arn]
  create_auto_dimensions       = var.metric_resource_cloudfront.create_auto_dimensions
  auto_dimensions_exclude_list = var.metric_resource_cloudfront.auto_dimensions_exclude_list
  dimensions                   = var.metric_resource_cloudfront.dimensions
  name_prefix                  = var.name_prefix
  tags                         = var.tags
}
