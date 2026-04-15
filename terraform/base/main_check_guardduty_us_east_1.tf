#--------------------------------------------------------------
# AWS GuardDuty Threat Detection Monitoring (us-east-1)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Configures EventBridge in us-east-1 region to monitor AWS GuardDuty
# findings and send security alerts to Slack.
#
# This additional regional deployment is used to capture GuardDuty
# findings that are generated in us-east-1 while avoiding duplicate
# resource creation when the default region is already us-east-1.
#--------------------------------------------------------------
module "aws_cloudwatch_events_guardduty_us_east_1" {
  source     = "../../modules/aws/cloudwatch/events/guardduty"
  is_enabled = !local.is_default_region_us_east_1 && var.guardduty.is_enabled && !local.control_tower_managed_services.guardduty
  providers = {
    aws = aws.us-east-1
  }

  aws_cloudwatch_event_rule = {
    name        = "${var.name_prefix}${try(var.guardduty.aws_cloudwatch_event_rule.name_us_east_1, "guardduty-us-east-1-cloudwatch-event-rule")}"
    description = try(var.guardduty.aws_cloudwatch_event_rule.description, "This cloudwatch event used for GuardDuty.")
    state       = try(var.guardduty.aws_cloudwatch_event_rule.state, "ENABLED")
  }
  aws_cloudwatch_event_target = {
    arn = module.lambda_function_guardduty_us_east_1.lambda_function_arn
  }

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function (us-east-1)
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_guardduty_us_east_1" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"
  create  = !local.is_default_region_us_east_1 && var.guardduty.is_enabled && !local.control_tower_managed_services.guardduty
  providers = {
    aws = aws.us-east-1
  }

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "events.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_cloudwatch_events_guardduty_us_east_1.arn
      statement_id        = "GuardDutyDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key_us_east_1["base"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.guardduty.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of GuardDuty to Slack."
  environment_variables = {
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* - coalesce() handles null values properly
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.guardduty.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.guardduty.channel_id, null), var.slack.channel_id)
  }
  function_name                 = "${var.name_prefix}cloudwatch-event-guardduty"
  handler                       = "cloudwatch_event_guardduty_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_event_guardduty_to_slack.zip"
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 128
  publish                       = false
  runtime                       = "provided.al2023"
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc_us_east_1.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id_us_east_1] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc_us_east_1.private_subnets : var.common_lambda.vpc.exists.private_subnets_us_east_1 : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc_us_east_1
  ]
}
