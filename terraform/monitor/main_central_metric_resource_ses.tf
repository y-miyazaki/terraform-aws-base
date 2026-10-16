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

  alarm_actions      = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions         = var.metric_resource_ses.dimensions
  name_prefix        = var.name_prefix
  ok_actions         = [module.aws_sns_subscription_lambda_metric.arn]
  period             = var.metric_resource_ses.period
  threshold          = var.metric_resource_ses.threshold
  threshold_override = var.metric_resource_ses.threshold_override

  tags = var.tags
}
