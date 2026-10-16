#--------------------------------------------------------------
# For SNS metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_sns" {
  source = "../../modules/aws/metric/sns"

  is_enabled = var.metric_resource_sns.is_enabled
  region     = var.region.primary

  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  auto_dimensions_exclude_list = var.metric_resource_sns.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_sns.auto_dimensions_include_list
  create_auto_dimensions       = var.metric_resource_sns.create_auto_dimensions
  dimensions                   = var.metric_resource_sns.dimensions
  name_prefix                  = var.name_prefix
  ok_actions                   = [module.aws_sns_subscription_lambda_metric.arn]
  period                       = var.metric_resource_sns.period
  threshold                    = var.metric_resource_sns.threshold
  threshold_override           = var.metric_resource_sns.threshold_override

  tags = var.tags
}
