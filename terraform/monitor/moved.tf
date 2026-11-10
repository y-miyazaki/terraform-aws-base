#--------------------------------------------------------------
# State migration for the regional refactor (singleton -> for_each keyed by local.monitor_regions).
# primary: key "primary", global (us-east-1): key "global".
# These blocks can be removed once every environment has applied this change.
#--------------------------------------------------------------

moved {
  from = module.aws_sns_subscription_lambda_metric
  to   = module.aws_sns_subscription_lambda_metric["primary"]
}

moved {
  from = module.aws_lambda_create_lambda_metric
  to   = module.aws_lambda_create_lambda_metric["primary"]
}

moved {
  from = module.aws_sns_subscription_lambda_log
  to   = module.aws_sns_subscription_lambda_log["primary"]
}

moved {
  from = module.aws_lambda_create_lambda_log
  to   = module.aws_lambda_create_lambda_log["primary"]
}

moved {
  from = module.aws_sns_subscription_lambda_ses
  to   = module.aws_sns_subscription_lambda_ses["primary"]
}

moved {
  from = module.aws_lambda_create_lambda_ses
  to   = module.aws_lambda_create_lambda_ses["primary"]
}

moved {
  from = module.aws_cloudwatch_alarm_log_application
  to   = module.aws_cloudwatch_alarm_log_application["primary"]
}

moved {
  from = module.aws_cloudwatch_alarm_log_mysql_query
  to   = module.aws_cloudwatch_alarm_log_mysql_query["primary"]
}

moved {
  from = module.aws_cloudwatch_alarm_log_postgresql
  to   = module.aws_cloudwatch_alarm_log_postgresql["primary"]
}

moved {
  from = module.aws_cloudwatch_alarm_log_postgresql_slowquery
  to   = module.aws_cloudwatch_alarm_log_postgresql_slowquery["primary"]
}

moved {
  from = module.aws_cloudwatch_alarm_log_step_functions
  to   = module.aws_cloudwatch_alarm_log_step_functions["primary"]
}

moved {
  from = module.aws_cloudwatch_alarm_log_waf
  to   = module.aws_cloudwatch_alarm_log_waf["primary"]
}

moved {
  from = module.aws_metric_api_gateway
  to   = module.aws_metric_api_gateway["primary"]
}

moved {
  from = module.aws_metric_ec2
  to   = module.aws_metric_ec2["primary"]
}

moved {
  from = module.aws_metric_ecs_container_insights
  to   = module.aws_metric_ecs_container_insights["primary"]
}

moved {
  from = module.aws_metric_elasticache
  to   = module.aws_metric_elasticache["primary"]
}

moved {
  from = module.aws_metric_elb
  to   = module.aws_metric_elb["primary"]
}

moved {
  from = module.aws_metric_eventbridge_scheduler
  to   = module.aws_metric_eventbridge_scheduler["primary"]
}

moved {
  from = module.aws_metric_lambda
  to   = module.aws_metric_lambda["primary"]
}

moved {
  from = module.aws_metric_nat_gateway
  to   = module.aws_metric_nat_gateway["primary"]
}

moved {
  from = module.aws_metric_rds_cluster
  to   = module.aws_metric_rds_cluster["primary"]
}

moved {
  from = module.aws_metric_redshift
  to   = module.aws_metric_redshift["primary"]
}

moved {
  from = module.aws_metric_ses
  to   = module.aws_metric_ses["primary"]
}

moved {
  from = module.aws_metric_sns
  to   = module.aws_metric_sns["primary"]
}

moved {
  from = module.aws_metric_sqs
  to   = module.aws_metric_sqs["primary"]
}

moved {
  from = module.aws_sns_subscription_lambda_metric_us_east_1[0]
  to   = module.aws_sns_subscription_lambda_metric["global"]
}

moved {
  from = module.aws_sns_subscription_lambda_log_us_east_1[0]
  to   = module.aws_sns_subscription_lambda_log["global"]
}

moved {
  from = module.aws_sns_subscription_lambda_ses_us_east_1[0]
  to   = module.aws_sns_subscription_lambda_ses["global"]
}

moved {
  from = module.aws_lambda_create_lambda_metric_us_east_1
  to   = module.aws_lambda_create_lambda_metric["global"]
}

moved {
  from = module.aws_lambda_create_lambda_log_us_east_1
  to   = module.aws_lambda_create_lambda_log["global"]
}

moved {
  from = module.aws_lambda_create_lambda_ses_us_east_1
  to   = module.aws_lambda_create_lambda_ses["global"]
}

moved {
  from = module.aws_metric_ses_us_east_1
  to   = module.aws_metric_ses["global"]
}
