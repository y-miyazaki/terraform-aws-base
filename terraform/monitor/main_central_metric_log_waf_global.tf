#--------------------------------------------------------------
# For WAF Log(us-east-1)
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter And Alarm resource.
#--------------------------------------------------------------
module "aws_cloudwatch_alarm_log_waf_us_east_1" {
  source = "../../modules/aws/cloudwatch/alarm/log"

  is_enabled = local.is_enabled_global && var.metric_log_waf_us_east_1.is_enabled
  region     = "us-east-1"

  create_auto_log_group_names       = var.metric_log_waf_us_east_1.create_auto_log_group_names
  auto_log_group_names_exclude_list = var.metric_log_waf_us_east_1.auto_log_group_names_exclude_list
  auto_log_group_names_include_list = var.metric_log_waf_us_east_1.auto_log_group_names_include_list
  alarm_actions                     = [module.aws_sns_subscription_lambda_log_us_east_1[0].arn]
  # In the case of logs, even if the alarm has been recovered, it is not considered OK.
  #   ok_actions                        = var.metric_log_waf_us_east_1.is_enabled ? [module.aws_sns_subscription_lambda_log_us_east_1[0].arn] : []
  log_group_names                  = var.metric_log_waf_us_east_1.log_group_names
  name_prefix                      = var.name_prefix
  aws_cloudwatch_log_metric_filter = var.metric_log_waf_us_east_1.aws_cloudwatch_log_metric_filter
  aws_cloudwatch_metric_alarm      = var.metric_log_waf_us_east_1.aws_cloudwatch_metric_alarm

  tags = var.tags
}
