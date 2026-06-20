#--------------------------------------------------------------
# For SES metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_ses" {
  source = "../../modules/aws/metric/ses"

  is_enabled = var.metric_resource_ses.is_enabled
  region     = var.region.primary

  period        = var.metric_resource_ses.period
  threshold     = var.metric_resource_ses.threshold
  alarm_actions = [module.aws_sns_subscription_lambda_metric.arn]
  ok_actions    = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions    = var.metric_resource_ses.dimensions
  name_prefix   = var.name_prefix

  tags = var.tags
}
