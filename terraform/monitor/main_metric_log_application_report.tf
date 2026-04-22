#--------------------------------------------------------------
# Provides a CloudWatch Events Schedule resource for Application errors report
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "application_errors" {
  count = var.metric_log_application_report.is_enabled ? 1 : 0

  name        = "${var.name_prefix}${var.metric_log_application_report.aws_eventbridge_schedule.name}"
  description = var.metric_log_application_report.aws_eventbridge_schedule.description
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = var.metric_log_application_report.aws_eventbridge_schedule.schedule_expression
  state               = "ENABLED"
  target {
    arn      = module.lambda_function_application_errors.lambda_function_arn
    role_arn = module.aws_iam_role_eventbridge.arn
    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}

#--------------------------------------------------------------
# Create Lambda function for Application errors report
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_application_errors" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"
  create  = var.metric_log_application_report.is_enabled

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "scheduler.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = try(aws_scheduler_schedule.application_errors[0].arn, null)
      statement_id        = "ApplicationErrorsDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key["monitor"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.metric_log_application.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of application errors report to Slack."
  environment_variables = merge({
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.metric_log_application.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.metric_log_application.channel_id, null), var.slack.channel_id)
  }, var.metric_log_application_report.aws_lambda_function.environment)
  function_name                 = "${var.name_prefix}cloudwatch-schedule-errors-report-to-slack"
  handler                       = "cloudwatch_schedule_errors_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_schedule_errors_to_slack.zip"
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 1024
  publish                       = false
  runtime                       = "provided.al2023"
  timeout                       = 900
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc.private_subnets : var.common_lambda.vpc.exists.private_subnets : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc
  ]
}
