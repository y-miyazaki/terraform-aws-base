#--------------------------------------------------------------
# For Health
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an Health.
#--------------------------------------------------------------
module "aws_cloudwatch_events_health" {
  source     = "../../modules/aws/cloudwatch/events/health"
  is_enabled = lookup(var.health, "is_enabled", true)
  aws_cloudwatch_event_rule = {
    name        = "${var.name_prefix}${lookup(var.health.aws_cloudwatch_event_rule, "name", "health-cloudwatch-event-rule")}"
    description = lookup(var.health.aws_cloudwatch_event_rule, "description", "This cloudwatch event used for Health.")
    state       = lookup(var.health.aws_cloudwatch_event_rule, "state", "ENABLED")
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
  version = "7.21.0"
  create  = lookup(var.health, "is_enabled", true)

  architectures                           = ["arm64"]
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "events.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_cloudwatch_events_health.arn
      statement_id        = "HealthDetectUnexpectedUsage"
      statement_id_prefix = null
    }
  }
  attach_network_policy             = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_retention_in_days = var.health.aws_cloudwatch_log_group_lambda.retention_in_days
  environment_variables             = lookup(var.health.aws_lambda_function, "environment")
  description                       = "This program sends the result of Health to Slack."
  function_name                     = "${var.name_prefix}cloudwatch-event-health"
  handler                           = "cloudwatch_event_health_to_slack"
  lambda_role                       = module.aws_iam_role_lambda.arn
  local_existing_package            = "../../lambda/outputs/go_cloudwatch_event_health_to_slack.zip"
  memory_size                       = 128
  runtime                           = "provided.al2"
  timeout                           = 300
  tags                              = var.tags
  tracing_mode                      = "PassThrough"
  vpc_subnet_ids                    = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc.private_subnets : var.common_lambda.vpc.exists.private_subnets : []
  vpc_security_group_ids            = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id] : []
  depends_on = [
    module.lambda_vpc
  ]
}
