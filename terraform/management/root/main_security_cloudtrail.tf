#--------------------------------------------------------------
# For CloudTrail
#--------------------------------------------------------------
#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  aws_sns_topic_cloudtrail = merge(var.security_cloudtrail.aws_sns_topic, {
    name = "${var.name_prefix}${var.security_cloudtrail.aws_sns_topic.name}"
    }
  )
  aws_sns_topic_subscription_cloudtrail = merge(var.security_cloudtrail.aws_sns_topic_subscription, {
    endpoint = module.lambda_function_cloudtrail.lambda_function_arn
    }
  )
}

#--------------------------------------------------------------
# Provides a CloudTrail.
#--------------------------------------------------------------
module "aws_security_cloudtrail_controltower" {
  source     = "../../../modules/aws/security/cloudtrail/controltower"
  is_enabled = var.security_cloudtrail.is_enabled

  aws_sns_topic              = local.aws_sns_topic_cloudtrail
  aws_sns_topic_subscription = local.aws_sns_topic_subscription_cloudtrail
  cis_name_prefix            = var.name_prefix
  sns_kms_master_key_id      = module.kms_key["root"].key_id

  tags = var.tags
}

#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter And Alarm resource.
#--------------------------------------------------------------
module "aws_cloudwatch_alarm_cloudtrail" {
  for_each = var.security_cloudtrail.is_enabled ? var.security_cloudtrail.aws_cloudwatch_log : {}

  source = "../../../modules/aws/cloudwatch/alarm/log"

  alarm_actions = var.security_cloudtrail.is_enabled ? [module.aws_security_cloudtrail_controltower.sns_topic_arn] : []
  #   ok_actions                        = var.security_cloudtrail.is_enabled ? [module.aws_security_cloudtrail_controltower.sns_topic_arn] : []
  create_auto_log_group_names       = false
  auto_log_group_names_exclude_list = []
  auto_log_group_names_include_list = []
  log_group_names = [
    "aws-controltower/CloudTrailLogs"
  ]
  name_prefix                      = var.name_prefix
  aws_cloudwatch_log_metric_filter = each.value.aws_cloudwatch_log_metric_filter
  aws_cloudwatch_metric_alarm      = each.value.aws_cloudwatch_metric_alarm

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_cloudtrail" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.1.2"
  create  = var.security_cloudtrail.is_enabled

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "sns.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_security_cloudtrail_controltower.sns_topic_arn
      statement_id        = "CloudTrailDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key["root"].key_arn
  cloudwatch_logs_retention_in_days       = try(var.cloudwatch_log_group.override.security_cloudtrail.retention_in_days, null) == null ? var.cloudwatch_log_group.retention_in_days : var.cloudwatch_log_group.override.security_cloudtrail.retention_in_days
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of CloudTrail to Slack."
  environment_variables = {
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = try(var.slack.override.security_cloudtrail.oauth_access_token, null) != null ? var.slack.override.security_cloudtrail.oauth_access_token : var.slack.oauth_access_token
    SLACK_CHANNEL_ID         = try(var.slack.override.security_cloudtrail.channel_id, null) != null ? var.slack.override.security_cloudtrail.channel_id : var.slack.channel_id
  }
  function_name                 = "${var.name_prefix}cloudwatch-alarm-cloudtrail"
  handler                       = "cloudwatch_alarm_to_sns_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../../lambda/outputs/go_cloudwatch_alarm_to_sns_to_slack.zip"
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
