#--------------------------------------------------------------
# For Budgets
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a resource to manage CloudWatch Rule and CloudWatch Events.
#--------------------------------------------------------------
module "aws_budgets_create_v4" {
  source     = "../../modules/aws/budgets/create-v4"
  is_enabled = lookup(var.budgets, "is_enabled", true)
  aws_budgets_budget = {
    name         = "${var.name_prefix}${lookup(var.budgets.aws_budgets_budget, "name", "budgets-monthly")}"
    budget_type  = "COST"
    cost_filter  = lookup(var.budgets.aws_budgets_budget, "cost_filter", [])
    cost_types   = {}
    limit_amount = var.budgets.aws_budgets_budget.limit_amount
    time_unit    = lookup(var.budgets.aws_budgets_budget, "time_unit", "MONTHLY")
    notification = var.budgets.aws_budgets_budget.notification
  }
  aws_cloudwatch_event_rule = {
    name                = "${var.name_prefix}${lookup(var.budgets.aws_cloudwatch_event_rule, "name", "budgets")}"
    schedule_expression = lookup(var.budgets.aws_cloudwatch_event_rule, "schedule_expression", null)
    description         = lookup(var.budgets.aws_cloudwatch_event_rule, "description", null)
    state               = lookup(var.budgets.aws_cloudwatch_event_rule, "state", "ENABLED")
  }
  aws_cloudwatch_event_target = {
    arn = var.budgets.is_enabled ? module.lambda_function_budgets.lambda_function_arn : null
  }
  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_budgets" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.2"
  create  = lookup(var.budgets, "is_enabled", true)

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
      source_arn          = module.aws_budgets_create_v4.arn
      statement_id        = "BudgetsDetectUnexpectedUsage"
      statement_id_prefix = null
    }
  }
  attach_network_policy             = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_retention_in_days = var.budgets.aws_cloudwatch_log_group_lambda.retention_in_days
  environment_variables = merge(var.budgets.aws_lambda_function.environment, {
    MONTHLY_TARGET_COST = var.budgets.aws_budgets_budget.limit_amount
  })
  description            = "This program sends the result of Budgets to Slack."
  function_name          = "${var.name_prefix}cloudwatch-event-budgets"
  handler                = "cloudwatch_event_budgets_to_slack"
  lambda_role            = module.aws_iam_role_lambda.arn
  local_existing_package = "../../lambda/outputs/go_cloudwatch_event_budgets_to_slack.zip"
  memory_size            = 128
  runtime                = "provided.al2"
  timeout                = 300
  tags                   = var.tags
  tracing_mode           = "PassThrough"
  vpc_subnet_ids         = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc.private_subnets : var.common_lambda.vpc.exists.private_subnets : []
  vpc_security_group_ids = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id] : []
  depends_on = [
    module.lambda_vpc
  ]
}
