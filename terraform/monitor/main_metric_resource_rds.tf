#--------------------------------------------------------------
# For Lambda metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_recipes_metric_rds" {
  source        = "../../modules/aws/recipes/metric/rds"
  is_enabled    = lookup(var.metric_resource_rds, "is_enabled", true)
  is_aurora     = lookup(var.metric_resource_rds, "is_aurora")
  is_mysql      = lookup(var.metric_resource_rds, "is_mysql")
  is_postgres   = lookup(var.metric_resource_rds, "is_postgres")
  period        = lookup(var.metric_resource_rds, "period")
  dimensions    = lookup(var.metric_resource_rds, "dimensions")
  alarm_actions = [module.aws_recipes_sns_subscription_lambda.arn]
  name_prefix   = var.name_prefix
  tags          = var.tags
}
