#--------------------------------------------------------------
# For SES metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_ses" {
  source        = "../../modules/aws/metric/ses"
  is_enabled    = var.metric_resource_ses.is_enabled
  period        = var.metric_resource_ses.period
  threshold     = var.metric_resource_ses.threshold
  alarm_actions = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions    = var.metric_resource_ses.dimensions
  name_prefix   = var.name_prefix
  tags          = var.tags
}
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_ses_us_east_1" {
  source = "../../modules/aws/metric/ses"
  providers = {
    aws = aws.us-east-1
  }
  is_enabled    = var.metric_resource_ses.is_enabled
  period        = var.metric_resource_ses.period
  threshold     = var.metric_resource_ses.threshold
  alarm_actions = [module.aws_sns_subscription_lambda_metric_us_east_1.arn]
  dimensions    = var.metric_resource_ses.dimensions
  name_prefix   = var.name_prefix
  tags          = var.tags
}
