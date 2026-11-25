#--------------------------------------------------------------
# Regional deployment of AWS Config
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# using AWS Provider v6+ region attribute.
# Not created when AWS Config is managed by Control Tower / the organization
# (control_tower.managed_services.config).

module "aws_security_config_create" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/config/create"

  is_enabled = local.is_enabled_security_config
  region     = each.value

  # CloudWatch Event Rule and Target (non-compliant notification: EventBridge -> Lambda -> Slack)
  aws_cloudwatch_event_rule = {
    description = var.security_config.aws_cloudwatch_event_rule.description
    name        = local.event_rule_names.config
  }
  aws_cloudwatch_event_target = {
    arn = module.lambda_function_config[each.value].lambda_function_arn
  }
  # AWS Config Configuration Recorder
  aws_config_configuration_recorder = try(var.security_config.aws_config_configuration_recorder, {})
  # AWS Config Configuration Recorder Status
  aws_config_configuration_recorder_status = try(var.security_config.aws_config_configuration_recorder_status, {})
  # AWS Config Delivery Channel
  aws_config_delivery_channel = try(var.security_config.aws_config_delivery_channel, {})
  aws_s3_bucket_existing      = try(var.security_config.aws_s3_bucket_existing, null)
  # S3 bucket configuration
  is_s3_enabled = try(var.security_config.is_s3_enabled, false)
  s3_bucket = try(var.security_config.aws_s3_bucket, {
    bucket                               = "config"
    lifecycle_rule                       = []
    logging                              = null
    server_side_encryption_configuration = {}
    versioning                           = {}
  })

  # Tags
  tags = var.tags
}

# AWS Config Rules for S3
module "aws_security_config_rule_s3" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/config/rule/s3"

  is_enabled = local.is_enabled_security_config
  region     = each.value

  # Config rules configuration
  name_prefix = var.name_prefix

  # SSM automation role
  ssm_automation_assume_role_arn = try(var.security_config.ssm_automation_assume_role_arn, "")

  # Tags
  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_config" {
  for_each = toset(var.region.targets)

  source  = "terraform-aws-modules/lambda/aws"
  version = "8.13.2"

  create = local.is_enabled_security_config
  region = each.value

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "events.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = "arn:aws:events:${each.value}:${data.aws_caller_identity.current.account_id}:rule/${local.event_rule_names.config}"
      statement_id        = "ConfigDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = local.is_lambda_vpc_region[each.value]
  cloudwatch_logs_kms_key_id              = module.kms_key[each.value].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.security_config.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of Config to Slack."
  environment_variables = {
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.security_config.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.security_config.channel_id, null), var.slack.channel_id)
  }
  function_name                 = "${var.name_prefix}cloudwatch-event-config-to-slack"
  handler                       = "cloudwatch_event_config_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_event_config_to_slack.zip"
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
