#--------------------------------------------------------------
# For SES metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_recipes_metric_ses" {
  source        = "../../modules/aws/recipes/metric/ses"
  is_enabled    = lookup(var.metric_resource_ses, "is_enabled", true)
  period        = lookup(var.metric_resource_ses, "period")
  threshold     = lookup(var.metric_resource_ses, "threshold")
  alarm_actions = [module.aws_recipes_sns_subscription_lambda.arn]
  dimensions    = lookup(var.metric_resource_ses, "dimensions")
  name_prefix   = var.name_prefix
  tags          = var.tags
}
