#--------------------------------------------------------------
# CloudWatch Events:EC2
# The following events are monitored.
# - EC2 Instance Rebalance Recommendation
# - EC2 Spot Instance Interruption Warning
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an EC2.
#--------------------------------------------------------------
module "aws_cloudwatch_events_ec2" {
  source = "../../modules/aws/cloudwatch/events/ec2"

  is_enabled = var.cloudwatch_event_ec2.is_enabled
  region     = var.region.primary

  aws_cloudwatch_event_rule = {
    name        = "${var.name_prefix}${var.cloudwatch_event_ec2.aws_cloudwatch_event_rule.name}"
    description = var.cloudwatch_event_ec2.aws_cloudwatch_event_rule.description
    state       = var.cloudwatch_event_ec2.aws_cloudwatch_event_rule.state
  }
  aws_cloudwatch_event_target = {
    arn = module.lambda_function_cloudwatch_event_ec2.lambda_function_arn
  }

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_cloudwatch_event_ec2" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.8.0"

  create = var.cloudwatch_event_ec2.is_enabled
  region = var.region.primary

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "events.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_cloudwatch_events_ec2.arn
      statement_id        = "EC2Detection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key["primary"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.cloudwatch_event_ec2.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of EC2 to Slack."
  environment_variables = merge({
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.cloudwatch_event_ec2.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.cloudwatch_event_ec2.channel_id, null), var.slack.channel_id)
  }, var.cloudwatch_event_ec2.aws_lambda_function.environment)
  function_name                 = "${var.name_prefix}cloudwatch-event-ec2-to-slack"
  handler                       = "cloudwatch_event_ec2_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_event_ec2_to_slack.zip"
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 128
  publish                       = false
  runtime                       = "provided.al2023"
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc["primary"].default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc["primary"].private_subnets : var.common_lambda.vpc.exists.private_subnets : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc
  ]
}
