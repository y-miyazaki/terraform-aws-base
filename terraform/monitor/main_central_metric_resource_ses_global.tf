#--------------------------------------------------------------
# For SES metric(us-east-1)
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_ses_us_east_1" {
  source = "../../modules/aws/metric/ses"

  is_enabled = local.is_enabled_global && var.metric_resource_ses.is_enabled
  region     = "us-east-1"

  period        = var.metric_resource_ses.period
  threshold     = var.metric_resource_ses.threshold
  alarm_actions = [module.aws_sns_subscription_lambda_metric_us_east_1[0].arn]
  ok_actions    = [module.aws_sns_subscription_lambda_metric_us_east_1[0].arn]
  dimensions    = var.metric_resource_ses.dimensions
  name_prefix   = var.name_prefix

  tags = var.tags
}
