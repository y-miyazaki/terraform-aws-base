
#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter And Alarm resource.
#--------------------------------------------------------------
module "aws_cloudwatch_alarm_log_postgresql_slowquery" {
  source     = "../../modules/aws/cloudwatch/alarm/log"
  is_enabled = var.metric_log_postgresql_slowquery.is_enabled_alert

  create_auto_log_group_names       = false
  auto_log_group_names_exclude_list = []
  auto_log_group_names_include_list = []
  alarm_actions                     = var.metric_log_postgresql_slowquery.is_enabled_alert ? [module.aws_sns_subscription_lambda_log.arn] : []
  # In the case of logs, even if the alarm has been recovered, it is not considered OK.
  #   ok_actions                        = var.metric_log_postgresql_slowquery.is_enabled_alert ? [module.aws_sns_subscription_lambda_log.arn] : []
  log_group_names                  = var.metric_log_postgresql_slowquery.log_group_names
  name_prefix                      = var.name_prefix
  aws_cloudwatch_log_metric_filter = var.metric_log_postgresql_slowquery.aws_cloudwatch_log_metric_filter
  aws_cloudwatch_metric_alarm      = var.metric_log_postgresql_slowquery.aws_cloudwatch_metric_alarm

  tags = var.tags
}

#--------------------------------------------------------------
# Provides a CloudWatch Events Schedule resource for PostgreSQL slow query
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "postgresql_slowquery" {
  count = var.metric_log_postgresql_slowquery.is_enabled_report ? 1 : 0

  name        = "${var.name_prefix}${var.metric_log_postgresql_slowquery.aws_eventbridge_schedule.name}"
  description = var.metric_log_postgresql_slowquery.aws_eventbridge_schedule.description
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = var.metric_log_postgresql_slowquery.aws_eventbridge_schedule.schedule_expression
  state               = "ENABLED"
  target {
    arn      = module.lambda_function_postgresql_slowquery.lambda_function_arn
    role_arn = module.aws_iam_role_eventbridge.arn
    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}

#--------------------------------------------------------------
# Create Lambda function for PostgreSQL slow query
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_postgresql_slowquery" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.2.0"
  create  = try(var.metric_log_postgresql_slowquery.is_enabled_report, true)

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "scheduler.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = null
      statement_id        = "PostgreSQLSlowQueryDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key["monitor"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.metric_log_postgresql_slowquery.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of PostgreSQL slow query list to Slack."
  environment_variables = merge({
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.metric_log_postgresql_slowquery.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.metric_log_postgresql_slowquery.channel_id, null), var.slack.channel_id)
  }, var.metric_log_postgresql_slowquery.aws_lambda_function.environment)
  function_name                 = "${var.name_prefix}cloudwatch-postgresql-slowquery"
  handler                       = "cloudwatch_postgresql_slowquery_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_postgresql_slowquery_to_slack.zip"
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 1024
  publish                       = false
  runtime                       = "provided.al2"
  timeout                       = 900
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc.private_subnets : var.common_lambda.vpc.exists.private_subnets : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc
  ]
}
