#--------------------------------------------------------------
# For SQS(DLQ)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_sqs_dlq" {
  source                       = "../../modules/aws/metric/sqs/dlq"
  is_enabled                   = var.metric_resource_sqs_dlq.is_enabled
  period                       = var.metric_resource_sqs_dlq.period
  threshold                    = var.metric_resource_sqs_dlq.threshold
  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  create_auto_dimensions       = var.metric_resource_sqs_dlq.create_auto_dimensions
  auto_dimensions_exclude_list = var.metric_resource_sqs_dlq.auto_dimensions_exclude_list
  dimensions                   = var.metric_resource_sqs_dlq.dimensions
  name_prefix                  = var.name_prefix
  tags                         = var.tags
}
