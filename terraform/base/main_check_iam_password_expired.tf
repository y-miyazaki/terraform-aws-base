#--------------------------------------------------------------
# IAM Password Expiration Monitoring
#--------------------------------------------------------------
#--------------------------------------------------------------
# Configures EventBridge Scheduler to check for expired or expiring IAM user
# passwords and send notifications to Slack. This helps maintain security
# compliance by ensuring users update their passwords regularly.
#
# Note: This monitoring is disabled when AWS Control Tower is enabled,
# as Control Tower provides its own password policy management.
#
# This monitors:
# - Password expiration dates
# - Users with expired passwords
# - Upcoming password expiration warnings
#--------------------------------------------------------------
module "aws_cloudwatch_events_iam_password_expired" {
  source     = "../../modules/aws/cloudwatch/events/iam_password_expired"
  is_enabled = var.iam_password_expired.is_enabled && !var.use_control_tower

  aws_cloudwatch_event_rule = {
    name                = "${var.name_prefix}${try(var.iam_password_expired.aws_cloudwatch_event_rule.name, "iam-password-expired-cloudwatch-event-rule")}"
    schedule_expression = try(var.iam_password_expired.aws_cloudwatch_event_rule.schedule_expression, "cron(0 0 * * ? *)")
    description         = try(var.iam_password_expired.aws_cloudwatch_event_rule.description, null)
    state               = try(var.iam_password_expired.aws_cloudwatch_event_rule.state, "ENABLED")
  }
  aws_cloudwatch_event_target = {
    arn = module.lambda_function_iam_password_expired.lambda_function_arn
  }

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_iam_password_expired" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"
  create  = var.iam_password_expired.is_enabled && !var.use_control_tower

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "events.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_cloudwatch_events_iam_password_expired.arn
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
  function_name                 = "${var.name_prefix}cloudwatch-event-iam-password-expired"
  handler                       = "cloudwatch_event_iam_password_expired_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_event_iam_password_expired_to_slack.zip"
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
