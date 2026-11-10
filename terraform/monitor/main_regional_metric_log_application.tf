#--------------------------------------------------------------
# For Application Log
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter And Alarm resource.
#--------------------------------------------------------------
module "aws_cloudwatch_alarm_log_application" {
  for_each = local.metric_regions["metric_log_application"]

  source = "../../modules/aws/cloudwatch/alarm/log"

  is_enabled = each.value.is_enabled
  region     = local.monitor_regions[each.key]

  alarm_actions                     = each.value.is_enabled ? [module.aws_sns_subscription_lambda_log[each.key].arn] : []
  auto_log_group_names_exclude_list = each.value.auto_log_group_names_exclude_list
  auto_log_group_names_include_list = each.value.auto_log_group_names_include_list
  aws_cloudwatch_log_metric_filter  = each.value.aws_cloudwatch_log_metric_filter
  aws_cloudwatch_metric_alarm       = each.value.aws_cloudwatch_metric_alarm
  create_auto_log_group_names       = each.value.create_auto_log_group_names
  # In the case of logs, even if the alarm has been recovered, it is not considered OK.
  #   ok_actions                        = each.value.is_enabled ? [module.aws_sns_subscription_lambda_log[each.key].arn] : []
  log_group_names    = each.value.log_group_names
  log_group_override = each.value.log_group_override
  name_prefix        = var.name_prefix

  tags = var.tags
}
