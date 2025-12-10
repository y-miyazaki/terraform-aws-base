#--------------------------------------------------------------
# For CloudFront metric
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_cloudfront" {
  source     = "../../modules/aws/metric/cloudfront"
  is_enabled = !local.is_default_region_us_east_1 && var.metric_resource_cloudfront.is_enabled
  providers = {
    aws = aws.us-east-1
  }

  period                       = var.metric_resource_cloudfront.period
  threshold                    = var.metric_resource_cloudfront.threshold
  create_auto_dimensions       = var.metric_resource_cloudfront.create_auto_dimensions
  auto_dimensions_exclude_list = var.metric_resource_cloudfront.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_cloudfront.auto_dimensions_include_list
  alarm_actions                = [module.aws_sns_subscription_lambda_metric_us_east_1[0].arn]
  ok_actions                   = [module.aws_sns_subscription_lambda_metric_us_east_1[0].arn]
  dimensions                   = var.metric_resource_cloudfront.dimensions
  name_prefix                  = var.name_prefix

  tags = var.tags
}
