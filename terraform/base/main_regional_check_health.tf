#--------------------------------------------------------------
# Regional deployment of AWS Health event monitoring
#--------------------------------------------------------------
# EventBridge rule -> Lambda -> Slack, deployed to each region in var.region.targets
# to monitor Health events across regions.
# AWS Health is not a Control Tower managed service, so it is created whenever
# health.is_enabled is true. Global events are only published to var.region.global,
# which must be included in var.region.targets.

module "aws_cloudwatch_events_health" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/cloudwatch/events/health"

  is_enabled = var.health.is_enabled
  region     = each.value

  aws_cloudwatch_event_rule = {
    description = var.health.aws_cloudwatch_event_rule.description
    name        = local.event_rule_names.health
    state       = var.health.aws_cloudwatch_event_rule.state
  }
  aws_cloudwatch_event_target = {
    arn = module.lambda_function_health[each.value].lambda_function_arn
  }

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_health" {
  for_each = toset(var.region.targets)

  source  = "terraform-aws-modules/lambda/aws"
  version = "8.13.0"

  create = var.health.is_enabled
  region = each.value

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "events.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = "arn:aws:events:${each.value}:${data.aws_caller_identity.current.account_id}:rule/${local.event_rule_names.health}"
      statement_id        = "HealthDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = local.is_lambda_vpc_region[each.value]
  cloudwatch_logs_kms_key_id              = module.kms_key[each.value].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.health.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of Health to Slack."
  environment_variables = {
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.health.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.health.channel_id, null), var.slack.channel_id)
  }
  function_name                 = "${var.name_prefix}cloudwatch-event-health-to-slack"
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
  vpc_security_group_ids        = local.lambda_vpc_security_group_ids[each.value]
  vpc_subnet_ids                = local.lambda_vpc_subnet_ids[each.value]

  tags = var.tags
}
