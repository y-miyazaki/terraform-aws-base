#--------------------------------------------------------------
# Provides a SNS
# For Log
#--------------------------------------------------------------
module "aws_sns_subscription_lambda_step_functions_log" {
  source = "../../modules/aws/sns/subscription"

  aws_sns_topic = merge(var.common_lambda.step_functions_log.aws_sns_topic, {
    name = "${var.name_prefix}${var.common_lambda.step_functions_log.aws_sns_topic.name}"
    }
  )
  aws_sns_topic_subscription = {
    protocol                        = var.common_lambda.aws_sns_topic_subscription.protocol
    endpoint                        = module.aws_lambda_create_lambda_step_functions_log.lambda_function_arn
    endpoint_auto_confirms          = var.common_lambda.aws_sns_topic_subscription.endpoint_auto_confirms
    confirmation_timeout_in_minutes = var.common_lambda.aws_sns_topic_subscription.confirmation_timeout_in_minutes
    raw_message_delivery            = var.common_lambda.aws_sns_topic_subscription.raw_message_delivery
    filter_policy                   = var.common_lambda.aws_sns_topic_subscription.filter_policy
    delivery_policy                 = var.common_lambda.aws_sns_topic_subscription.delivery_policy
    redrive_policy                  = var.common_lambda.aws_sns_topic_subscription.redrive_policy
  }
  kms_master_key_id = module.kms_key["monitor"].key_id

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# For Log
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "aws_lambda_create_lambda_step_functions_log" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.2.0"

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "sns.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_sns_subscription_lambda_step_functions_log.arn
      statement_id        = "LogDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key["monitor"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.common_lambda_step_functions.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of log to Slack."
  environment_variables = {
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.common_lambda_step_functions.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.common_lambda_step_functions.channel_id, null), var.slack.channel_id)
  }
  function_name                 = "${var.name_prefix}cloudwatch-alarm-step-functions-log"
  handler                       = "cloudwatch_alarm_to_sns_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_alarm_to_sns_to_slack.zip"
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
