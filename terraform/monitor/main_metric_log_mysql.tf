#--------------------------------------------------------------
# For mysql Log
#--------------------------------------------------------------
locals {
  aws_cloudwatch_log_metric_filter_mysql_log = flatten([
    for r in var.metric_log_mysql_slowquery.log_group_names : {
      name           = "${var.name_prefix}${lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_log_metric_filter, "name")}-${replace(replace(r, "/", "-"), "/^-/", "")}"
      pattern        = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_log_metric_filter, "pattern")
      log_group_name = r
      metric_transformation = [
        {
          name      = "${var.name_prefix}${lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_log_metric_filter, "name")}-${replace(replace(r, "/", "-"), "/^-/", "")}"
          namespace = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_log_metric_filter.metric_transformation[0], "namespace")
          value     = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_log_metric_filter.metric_transformation[0], "value")
        }
      ]
    }
  ])
  aws_cloudwatch_metric_alarm_mysql_log = flatten([
    for r in var.metric_log_mysql_slowquery.log_group_names : {
      alarm_name                            = "${var.name_prefix}${lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "alarm_name")}-${replace(replace(r, "/", "-"), "/^-/", "")}"
      comparison_operator                   = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "comparison_operator")
      evaluation_periods                    = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "evaluation_periods")
      metric_name                           = "${var.name_prefix}${lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_log_metric_filter, "name")}-${replace(replace(r, "/", "-"), "/^-/", "")}"
      namespace                             = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_log_metric_filter.metric_transformation[0], "namespace")
      period                                = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "period")
      statistic                             = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "statistic")
      threshold                             = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "threshold", null)
      threshold_metric_id                   = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "threshold_metric_id", null)
      actions_enabled                       = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "actions_enabled")
      alarm_description                     = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "alarm_description")
      datapoints_to_alarm                   = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "datapoints_to_alarm", null)
      dimensions                            = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "dimensions", null)
      insufficient_data_actions             = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "insufficient_data_actions", null)
      ok_actions                            = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "ok_actions", null)
      unit                                  = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "unit", null)
      extended_statistic                    = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "extended_statistic", null)
      treat_missing_data                    = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "treat_missing_data", null)
      evaluate_low_sample_count_percentiles = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "evaluate_low_sample_count_percentiles", null)
      metric_query                          = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "metric_query", [])
      extended_statistic                    = lookup(var.metric_log_mysql_slowquery.aws_cloudwatch_metric_alarm, "extended_statistic", null)
      alarm_actions                         = var.metric_log_mysql_slowquery.is_enabled ? [module.aws_recipes_sns_subscription_lambda_log.arn] : null
    }
  ])
}

#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter And Alarm resource.
#--------------------------------------------------------------
module "aws_recipes_cloudwatch_alarm_log_mysql_query" {
  count                            = lookup(var.metric_log_mysql_slowquery, "is_enabled", true) ? 1 : 0
  source                           = "../../modules/aws/recipes/cloudwatch/alarm/log"
  aws_cloudwatch_log_metric_filter = local.aws_cloudwatch_log_metric_filter_mysql_log
  aws_cloudwatch_metric_alarm      = local.aws_cloudwatch_metric_alarm_mysql_log
  tags                             = var.tags
}
