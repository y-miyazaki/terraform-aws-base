#--------------------------------------------------------------
# For CloudFront metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_recipes_metric_cloudfront" {
  source = "../../modules/aws/recipes/metric/cloudfront"
  providers = {
    aws = aws.us-east-1
  }
  is_enabled    = lookup(var.metric_resource_cloudfront, "is_enabled", true)
  period        = lookup(var.metric_resource_cloudfront, "period")
  threshold     = lookup(var.metric_resource_cloudfront, "threshold")
  alarm_actions = [module.aws_recipes_sns_subscription_lambda_us_east_1.arn]
  dimensions    = lookup(var.metric_resource_cloudfront, "dimensions")
  name_prefix   = var.name_prefix
  tags          = var.tags
}
