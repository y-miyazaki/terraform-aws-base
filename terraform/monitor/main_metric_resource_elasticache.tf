#--------------------------------------------------------------
# For ElastiCache metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_elasticache" {
  source        = "../../modules/aws/metric/elasticache"
  is_enabled    = var.metric_resource_elasticache.is_enabled
  period        = var.metric_resource_elasticache.period
  threshold     = var.metric_resource_elasticache.threshold
  alarm_actions = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions    = var.metric_resource_elasticache.dimensions
  name_prefix   = var.name_prefix
  tags          = var.tags
}
