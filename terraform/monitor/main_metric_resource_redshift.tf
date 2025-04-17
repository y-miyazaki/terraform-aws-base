#--------------------------------------------------------------
# For Redshift metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_redshift" {
  source                       = "../../modules/aws/metric/redshift"
  is_enabled                   = var.metric_resource_redshift.is_enabled
  period                       = var.metric_resource_redshift.period
  threshold                    = var.metric_resource_redshift.threshold
  create_auto_dimensions       = var.metric_resource_redshift.create_auto_dimensions
  auto_dimensions_exclude_list = var.metric_resource_redshift.auto_dimensions_exclude_list
  dimensions                   = var.metric_resource_redshift.dimensions
  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  name_prefix                  = var.name_prefix
  tags                         = var.tags
}
