#--------------------------------------------------------------
# For Synthetics Canary metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Metrics: Synthetics Canary: Heartbeat
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_synthetics_canary_heartbeat" {
  source        = "../../modules/aws/metric/synthetics_canary"
  is_enabled    = var.metric_synthetics_canary_heartbeat.is_enabled
  period        = var.metric_synthetics_canary_heartbeat.period
  threshold     = var.metric_synthetics_canary_heartbeat.threshold
  alarm_actions = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions    = var.metric_synthetics_canary_heartbeat.dimensions
  name_prefix   = var.name_prefix
  tags          = var.tags
}
#--------------------------------------------------------------
# Metrics: Synthetics Canary: Linkcheck
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_synthetics_canary_linkcheck" {
  source        = "../../modules/aws/metric/synthetics_canary"
  is_enabled    = var.metric_synthetics_canary_linkcheck.is_enabled
  period        = var.metric_synthetics_canary_linkcheck.period
  threshold     = var.metric_synthetics_canary_linkcheck.threshold
  alarm_actions = [module.aws_sns_subscription_lambda_metric.arn]
  dimensions    = var.metric_synthetics_canary_linkcheck.dimensions
  name_prefix   = var.name_prefix
  tags          = var.tags
}
