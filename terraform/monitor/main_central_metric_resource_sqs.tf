#--------------------------------------------------------------
# For SQS metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_sqs" {
  source = "../../modules/aws/metric/sqs"

  is_enabled = var.metric_resource_sqs.is_enabled
  region     = var.region.primary

  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  auto_dimensions_exclude_list = var.metric_resource_sqs.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_sqs.auto_dimensions_include_list
  create_auto_dimensions       = var.metric_resource_sqs.create_auto_dimensions
  dimensions                   = var.metric_resource_sqs.dimensions
  name_prefix                  = var.name_prefix
  ok_actions                   = [module.aws_sns_subscription_lambda_metric.arn]
  period                       = var.metric_resource_sqs.period
  threshold                    = var.metric_resource_sqs.threshold
  threshold_override           = var.metric_resource_sqs.threshold_override

  tags = var.tags
}
