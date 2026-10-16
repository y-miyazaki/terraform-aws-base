#--------------------------------------------------------------
# For Redshift metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_redshift" {
  source = "../../modules/aws/metric/redshift"

  is_enabled = var.metric_resource_redshift.is_enabled
  region     = var.region.primary

  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  auto_dimensions_exclude_list = var.metric_resource_redshift.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_redshift.auto_dimensions_include_list
  create_auto_dimensions       = var.metric_resource_redshift.create_auto_dimensions
  dimensions                   = var.metric_resource_redshift.dimensions
  name_prefix                  = var.name_prefix
  ok_actions                   = [module.aws_sns_subscription_lambda_metric.arn]
  period                       = var.metric_resource_redshift.period
  threshold                    = var.metric_resource_redshift.threshold
  threshold_override           = var.metric_resource_redshift.threshold_override

  tags = var.tags
}
