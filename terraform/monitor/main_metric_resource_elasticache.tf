#--------------------------------------------------------------
# For ElastiCache metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_recipes_metric_elasticache" {
  source        = "../../modules/aws/recipes/metric/elasticache"
  is_enabled    = lookup(var.metric_resource_elasticache, "is_enabled", true)
  period        = lookup(var.metric_resource_elasticache, "period")
  threshold     = lookup(var.metric_resource_elasticache, "threshold")
  alarm_actions = [module.aws_recipes_sns_subscription_lambda_metric.arn]
  dimensions    = lookup(var.metric_resource_elasticache, "dimensions")
  name_prefix   = var.name_prefix
  tags          = var.tags
}
