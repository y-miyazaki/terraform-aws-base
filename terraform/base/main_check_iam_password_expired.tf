#--------------------------------------------------------------
# IAM Password Expiration Monitoring
#--------------------------------------------------------------
#--------------------------------------------------------------
# Configures EventBridge Scheduler to check for expired or expiring IAM user
# passwords and send notifications to Slack. This helps maintain security
# compliance by ensuring users update their passwords regularly.
#
# This monitors:
# - Password expiration dates
# - Users with expired passwords
# - Upcoming password expiration warnings
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "iam_password_expired" {
  count = var.iam_password_expired.is_enabled ? 1 : 0

  name        = "${var.name_prefix}${var.iam_password_expired.aws_eventbridge_schedule.name}"
  description = var.iam_password_expired.aws_eventbridge_schedule.description
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = var.iam_password_expired.aws_eventbridge_schedule.schedule_expression
  state               = "ENABLED"
  target {
    arn      = module.lambda_function_iam_password_expired.lambda_function_arn
    role_arn = module.aws_iam_role_eventbridge.arn
    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_iam_password_expired" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.8.0"
  create  = var.iam_password_expired.is_enabled && !local.control_tower_managed_services.iam_password_expired

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "scheduler.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = try(aws_scheduler_schedule.iam_password_expired[0].arn, null)
      statement_id        = "IAMPasswordExpiredDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key["base"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.iam_password_expired.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of IAM password expired to Slack."
  environment_variables = {
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.iam_password_expired.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.iam_password_expired.channel_id, null), var.slack.channel_id)
  }
  function_name                 = "${var.name_prefix}cloudwatch-schedule-iam-password-expired-to-slack"
  handler                       = "cloudwatch_schedule_iam_password_expired_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_schedule_iam_password_expired_to_slack.zip"
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 128
  publish                       = false
  runtime                       = "provided.al2023"
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc.private_subnets : var.common_lambda.vpc.exists.private_subnets : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc
  ]
}
