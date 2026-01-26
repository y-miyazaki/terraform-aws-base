#--------------------------------------------------------------
# For Budgets
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a resource to manage CloudWatch Rule and CloudWatch Events.
#--------------------------------------------------------------
module "aws_budgets_create_v4" {
  source     = "../../../modules/aws/budgets/create-v4"
  is_enabled = var.budgets.is_enabled

  aws_budgets_budget = {
    name         = "${var.name_prefix}${try(var.budgets.aws_budgets_budget.name, "budgets-monthly")}"
    budget_type  = "COST"
    cost_filter  = try(var.budgets.aws_budgets_budget.cost_filter, [])
    cost_types   = []
    limit_amount = var.budgets.aws_budgets_budget.limit_amount
    time_unit    = try(var.budgets.aws_budgets_budget.time_unit, "MONTHLY")
    notification = var.budgets.aws_budgets_budget.notification
  }
}

#--------------------------------------------------------------
# Provides a CloudWatch Events Schedule resource for Budgets
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "budgets" {
  count = var.budgets.is_enabled ? 1 : 0

  name        = "${var.name_prefix}${var.budgets.aws_eventbridge_schedule.name}"
  description = var.budgets.aws_eventbridge_schedule.description
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = var.budgets.aws_eventbridge_schedule.schedule_expression
  state               = "ENABLED"
  target {
    arn      = module.lambda_function_budgets.lambda_function_arn
    role_arn = module.aws_iam_role_eventbridge.arn
    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}

#--------------------------------------------------------------
# Create Lambda function for Budgets
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_budgets" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.2.0"
  create  = var.budgets.is_enabled

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "scheduler.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = null
      statement_id        = "BudgetsDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key["root"].key_arn
  cloudwatch_logs_retention_in_days       = try(var.cloudwatch_log_group.override.budgets.retention_in_days, null) == null ? var.cloudwatch_log_group.retention_in_days : var.cloudwatch_log_group.override.budgets.retention_in_days
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of Budgets(All) to Slack."
  environment_variables = merge({
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = try(var.slack.override.budgets.oauth_access_token, null) != null ? var.slack.override.budgets.oauth_access_token : var.slack.oauth_access_token
    SLACK_CHANNEL_ID         = try(var.slack.override.budgets.channel_id, null) != null ? var.slack.override.budgets.channel_id : var.slack.channel_id
  }, var.budgets.aws_lambda_function.environment)
  function_name                 = "${var.name_prefix}cloudwatch-event-budgets-all"
  handler                       = "cloudwatch_event_budgets_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../../lambda/outputs/go_cloudwatch_event_budgets_all_to_slack.zip"
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
