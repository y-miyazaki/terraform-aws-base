#--------------------------------------------------------------
# For SES metric
# SES is a regional service. Alarms are created in each region listed in var.metric_resource_ses.regions (default: primary only).
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_ses" {
  for_each = local.metric_regions["metric_resource_ses"]

  source = "../../modules/aws/metric/ses"

  is_enabled = each.value.is_enabled
  region     = local.monitor_regions[each.key]

  alarm_actions      = [module.aws_sns_subscription_lambda_metric[each.key].arn]
  dimensions         = each.value.dimensions
  name_prefix        = var.name_prefix
  ok_actions         = [module.aws_sns_subscription_lambda_metric[each.key].arn]
  period             = each.value.period
  threshold          = each.value.threshold
  threshold_override = each.value.threshold_override

  tags = var.tags
}
