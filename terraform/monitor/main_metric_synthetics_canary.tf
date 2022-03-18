#--------------------------------------------------------------
# For Synthetics Canary metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_recipes_metric_synthetics_canary" {
  source        = "../../modules/aws/recipes/metric/synthetics_canary"
  is_enabled    = lookup(var.metric_synthetics_canary, "is_enabled", true)
  period        = lookup(var.metric_synthetics_canary, "period")
  threshold     = lookup(var.metric_synthetics_canary, "threshold")
  alarm_actions = [module.aws_recipes_sns_subscription_lambda_metric.arn]
  dimensions    = lookup(var.metric_synthetics_canary, "dimensions")
  name_prefix   = var.name_prefix
  tags          = var.tags
}
