#--------------------------------------------------------------
# For ElastiCache metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_elasticache" {
  source = "../../modules/aws/metric/elasticache"

  is_enabled = var.metric_resource_elasticache.is_enabled
  region     = var.region.primary

  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  auto_dimensions_exclude_list = var.metric_resource_elasticache.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_elasticache.auto_dimensions_include_list
  create_auto_dimensions       = var.metric_resource_elasticache.create_auto_dimensions
  dimensions                   = var.metric_resource_elasticache.dimensions
  name_prefix                  = var.name_prefix
  ok_actions                   = [module.aws_sns_subscription_lambda_metric.arn]
  period                       = var.metric_resource_elasticache.period
  threshold                    = var.metric_resource_elasticache.threshold
  threshold_override           = var.metric_resource_elasticache.threshold_override

  tags = var.tags
}
