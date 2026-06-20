#--------------------------------------------------------------
# For Step Functions
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter And Alarm resource.
#--------------------------------------------------------------
module "aws_cloudwatch_alarm_log_step_functions" {
  source = "../../modules/aws/cloudwatch/alarm/log"

  is_enabled = var.metric_log_step_functions.is_enabled
  region     = var.region.primary

  create_auto_log_group_names       = var.metric_log_step_functions.create_auto_log_group_names
  auto_log_group_names_exclude_list = var.metric_log_step_functions.auto_log_group_names_exclude_list
  auto_log_group_names_include_list = var.metric_log_step_functions.auto_log_group_names_include_list
  alarm_actions                     = var.metric_log_mysql_slowquery.is_enabled ? [module.aws_sns_subscription_lambda_log.arn] : []
  # In the case of logs, even if the alarm has been recovered, it is not considered OK.
  #   ok_actions                        = var.metric_log_mysql_slowquery.is_enabled ? [module.aws_sns_subscription_lambda_log.arn] : []
  log_group_names                  = var.metric_log_step_functions.log_group_names
  name_prefix                      = var.name_prefix
  aws_cloudwatch_log_metric_filter = var.metric_log_step_functions.aws_cloudwatch_log_metric_filter
  aws_cloudwatch_metric_alarm      = var.metric_log_step_functions.aws_cloudwatch_metric_alarm

  tags = var.tags
}
