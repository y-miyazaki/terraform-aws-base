#--------------------------------------------------------------
# For EC2 metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_ec2" {
  source                       = "../../modules/aws/metric/ec2"
  is_enabled                   = var.metric_resource_ec2.is_enabled
  period                       = var.metric_resource_ec2.period
  threshold                    = var.metric_resource_ec2.threshold
  create_auto_dimensions       = var.metric_resource_ec2.create_auto_dimensions
  auto_dimensions_exclude_list = var.metric_resource_ec2.auto_dimensions_exclude_list
  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions                   = var.metric_resource_ec2.dimensions
  name_prefix                  = var.name_prefix
  tags                         = var.tags
}
