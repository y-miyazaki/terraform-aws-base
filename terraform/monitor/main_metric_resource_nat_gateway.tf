#--------------------------------------------------------------
# For NAT Gateway metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_nat_gateway" {
  source     = "../../modules/aws/metric/nat_gateway"
  is_enabled = var.metric_resource_nat_gateway.is_enabled

  period                       = var.metric_resource_nat_gateway.period
  threshold                    = var.metric_resource_nat_gateway.threshold
  threshold_override           = var.metric_resource_nat_gateway.threshold_override
  create_auto_dimensions       = var.metric_resource_nat_gateway.create_auto_dimensions
  auto_dimensions_exclude_list = var.metric_resource_nat_gateway.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_nat_gateway.auto_dimensions_include_list
  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  ok_actions                   = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions                   = var.metric_resource_nat_gateway.dimensions
  name_prefix                  = var.name_prefix

  tags = var.tags
}
