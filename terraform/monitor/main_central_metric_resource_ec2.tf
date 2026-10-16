#--------------------------------------------------------------
# For EC2 metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_ec2" {
  source = "../../modules/aws/metric/ec2"

  is_enabled = var.metric_resource_ec2.is_enabled
  region     = var.region.primary

  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  auto_dimensions_exclude_list = var.metric_resource_ec2.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_ec2.auto_dimensions_include_list
  create_auto_dimensions       = var.metric_resource_ec2.create_auto_dimensions
  dimensions                   = var.metric_resource_ec2.dimensions
  name_prefix                  = var.name_prefix
  ok_actions                   = [module.aws_sns_subscription_lambda_metric.arn]
  period                       = var.metric_resource_ec2.period
  threshold                    = var.metric_resource_ec2.threshold
  threshold_override           = var.metric_resource_ec2.threshold_override

  tags = var.tags
}
