#--------------------------------------------------------------
# AWS Health Event Monitoring Configuration
#--------------------------------------------------------------
#--------------------------------------------------------------
# Configures EventBridge (CloudWatch Events) to monitor AWS Health events
# and send notifications to Slack. AWS Health provides alerts about AWS
# service events that may affect your resources.
#
# This monitors issues such as:
# - Scheduled maintenance events
# - Service disruptions
# - Resource-specific health notifications
#--------------------------------------------------------------
module "aws_cloudwatch_events_health" {
  source     = "../../modules/aws/cloudwatch/events/health"
  is_enabled = var.health.is_enabled

  aws_cloudwatch_event_rule = {
    name        = "${var.name_prefix}${try(var.health.aws_cloudwatch_event_rule.name, "health-cloudwatch-event-rule")}"
    description = try(var.health.aws_cloudwatch_event_rule.description, "This cloudwatch event used for Health.")
    state       = try(var.health.aws_cloudwatch_event_rule.state, "ENABLED")
  }
  aws_cloudwatch_event_target = {
    arn = module.lambda_function_health.lambda_function_arn
  }

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_health" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"
  create  = var.health.is_enabled

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "events.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_cloudwatch_events_health.arn
      statement_id        = "HealthDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key["base"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.health.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of Health to Slack."
  environment_variables = {
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* - coalesce() handles null values properly
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.health.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.health.channel_id, null), var.slack.channel_id)
  }
  function_name                 = "${var.name_prefix}cloudwatch-event-health"
  handler                       = "cloudwatch_event_health_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_event_health_to_slack.zip"
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
