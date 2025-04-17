#--------------------------------------------------------------
# For Application Log
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter And Alarm resource.
#--------------------------------------------------------------
module "aws_cloudwatch_alarm_log_application" {
  count                             = var.metric_log_application.is_enabled ? 1 : 0
  source                            = "../../modules/aws/cloudwatch/alarm/log"
  alarm_actions                     = var.metric_log_application.is_enabled ? [module.aws_sns_subscription_lambda_log.arn] : []
  create_auto_log_group_names       = var.metric_log_application.create_auto_log_group_names
  auto_log_group_names_exclude_list = var.metric_log_application.auto_log_group_names_exclude_list
  log_group_names                   = var.metric_log_application.log_group_names
  name_prefix                       = var.name_prefix
  aws_cloudwatch_log_metric_filter  = var.metric_log_application.aws_cloudwatch_log_metric_filter
  aws_cloudwatch_metric_alarm       = var.metric_log_application.aws_cloudwatch_metric_alarm
  tags                              = var.tags
}
