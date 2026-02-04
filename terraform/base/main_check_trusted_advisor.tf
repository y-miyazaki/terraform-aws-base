#--------------------------------------------------------------
# AWS Trusted Advisor Monitoring
#--------------------------------------------------------------
#--------------------------------------------------------------
# Configures EventBridge Scheduler to periodically check AWS Trusted Advisor
# recommendations and send alerts to Slack. Trusted Advisor provides real-time
# guidance to help optimize AWS infrastructure, improve security and performance,
# reduce costs, and monitor service limits.
#
# This monitors recommendations for:
# - Cost optimization opportunities
# - Security vulnerabilities and misconfigurations
# - Performance improvements
# - Service limit warnings
# - Fault tolerance best practices
#--------------------------------------------------------------
module "aws_cloudwatch_events_trusted_advisor" {
  source     = "../../modules/aws/cloudwatch/events/trusted_advisor"
  is_enabled = var.trusted_advisor.is_enabled

  aws_cloudwatch_event_rule = {
    name                = "${var.name_prefix}${try(var.trusted_advisor.aws_cloudwatch_event_rule.name, "trusted-advisor-cloudwatch-event-rule")}"
    schedule_expression = try(var.trusted_advisor.aws_cloudwatch_event_rule.schedule_expression, "cron(0 0 * * ? *)")
    description         = try(var.trusted_advisor.aws_cloudwatch_event_rule.description, null)
    state               = try(var.trusted_advisor.aws_cloudwatch_event_rule.state, "ENABLED")
  }
  aws_cloudwatch_event_target = {
    arn = module.lambda_function_trusted_advisor.lambda_function_arn
  }

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_trusted_advisor" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.2.0"
  create  = var.trusted_advisor.is_enabled

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "events.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_cloudwatch_events_trusted_advisor.arn
      statement_id        = "TrustedAdvisorDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key["base"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.trusted_advisor.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of Trusted Advisor to Slack."
  environment_variables = {
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.trusted_advisor.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.trusted_advisor.channel_id, null), var.slack.channel_id)
  }
  function_name                 = "${var.name_prefix}cloudwatch-event-trusted-advisor"
  handler                       = "cloudwatch_event_trusted_advisor_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_event_trusted_advisor_to_slack.zip"
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 128
  publish                       = false
  runtime                       = "provided.al2"
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc.private_subnets : var.common_lambda.vpc.exists.private_subnets : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc
  ]
}
