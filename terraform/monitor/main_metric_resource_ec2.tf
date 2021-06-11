#--------------------------------------------------------------
# For EC2 metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_recipes_metric_ec2" {
  source        = "../../modules/aws/recipes/metric/ec2"
  is_enabled    = lookup(var.metric_resource_ec2, "is_enabled", true)
  period        = lookup(var.metric_resource_ec2, "period")
  threshold     = lookup(var.metric_resource_ec2, "threshold")
  alarm_actions = [module.aws_recipes_sns_subscription_lambda.arn]
  dimensions    = lookup(var.metric_resource_ec2, "dimensions")
  name_prefix   = var.name_prefix
  tags          = var.tags
}
