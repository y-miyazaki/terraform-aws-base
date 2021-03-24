#--------------------------------------------------------------
# For Budgets
#--------------------------------------------------------------

#--------------------------------------------------------------
# Provides a budgets budget resource. Budgets use the cost visualisation provided by Cost Explorer to show you the status of your budgets, to provide forecasts of your estimated costs, and to track your AWS usage, including your free tier usage.
#--------------------------------------------------------------
resource "aws_budgets_budget" "this" {
  account_id   = lookup(var.budgets.aws_budgets_budget, "account_id", null)
  name         = "${var.name_prefix}${lookup(var.budgets.aws_budgets_budget, "name", null)}"
  name_prefix  = lookup(var.budgets.aws_budgets_budget, "name_prefix", null)
  budget_type  = lookup(var.budgets.aws_budgets_budget, "budget_type", "COST")
  cost_filters = lookup(var.budgets.aws_budgets_budget, "cost_filters", null)
  dynamic "cost_types" {
    for_each = lookup(var.budgets.aws_budgets_budget, "cost_types", [{}])
    content {
      include_credit             = lookup(cost_types.value, "include_credit", true)
      include_discount           = lookup(cost_types.value, "include_discount", true)
      include_other_subscription = lookup(cost_types.value, "include_other_subscription", true)
      include_recurring          = lookup(cost_types.value, "include_recurring", true)
      include_refund             = lookup(cost_types.value, "include_refund", true)
      include_subscription       = lookup(cost_types.value, "include_subscription", true)
      include_support            = lookup(cost_types.value, "include_support", true)
      include_tax                = lookup(cost_types.value, "include_tax", true)
      include_upfront            = lookup(cost_types.value, "include_upfront", true)
      use_amortized              = lookup(cost_types.value, "use_amortized", false)
      use_blended                = lookup(cost_types.value, "use_blended", false)
    }
  }
  limit_amount      = lookup(var.budgets.aws_budgets_budget, "limit_amount")
  limit_unit        = lookup(var.budgets.aws_budgets_budget, "limit_unit", "USD")
  time_period_end   = lookup(var.budgets.aws_budgets_budget, "time_period_end", "2050-12-31_00:00")
  time_period_start = lookup(var.budgets.aws_budgets_budget, "time_period_start", "2021-01-01_00:00")
  time_unit         = lookup(var.budgets.aws_budgets_budget, "time_unit", "MONTHLY")
  dynamic "notification" {
    for_each = lookup(var.budgets.aws_budgets_budget, "notification", [
      {
      }
    ])
    content {
      comparison_operator        = lookup(notification.value, "comparison_operator", "GREATER_THAN")
      threshold                  = lookup(notification.value, "threshold", "80")
      threshold_type             = lookup(notification.value, "threshold_type", "PERCENTAGE")
      notification_type          = lookup(notification.value, "notification_type", "ACTUAL")
      subscriber_email_addresses = lookup(notification.value, "subscriber_email_addresses", null)
      subscriber_sns_topic_arns  = lookup(notification.value, "subscriber_sns_topic_arns", null)
    }
  }
}

#--------------------------------------------------------------
# Create Lambda function
#--------------------------------------------------------------
module "aws_recipes_lambda_create_budgets" {
  source                   = "../modules/aws/recipes/lambda/create"
  aws_cloudwatch_log_group = lookup(var.budgets, "aws_cloudwatch_log_group_lambda")
  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "./lambda/outputs/cloudwatch_event_budgets_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-event-budgets"
    dead_letter_config             = []
    handler                        = "cloudwatch_event_budgets_to_slack"
    role                           = module.aws_recipes_iam_lambda.arn
    description                    = "This program sends the result of Budgets to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "go1.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    vpc_config                     = []
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("./lambda/outputs/cloudwatch_event_budgets_to_slack.zip")
    environment                    = lookup(var.budgets.aws_lambda_function, "environment")
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Event Rule, SNS or S3).
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    principal           = "events.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = module.aws_recipes_cloudwatch_event_budgets.arn
    statement_id        = "BudgetsDetectUnexpectedUsage"
    statement_id_prefix = null
  }
  tags = var.tags
}
#--------------------------------------------------------------
# Provides a resource to manage CloudWatch Rule and CloudWatch Event.
#--------------------------------------------------------------
module "aws_recipes_cloudwatch_event_budgets" {
  source = "../modules/aws/recipes/cloudwatch/event"
  aws_cloudwatch_event_rule = {
    name                = "${var.name_prefix}${lookup(var.budgets.aws_cloudwatch_event_rule, "name", "budgets")}"
    schedule_expression = lookup(var.budgets.aws_cloudwatch_event_rule, "schedule_expression", null)
    event_pattern       = null
    description         = lookup(var.budgets.aws_cloudwatch_event_rule, "description", null)
    role_arn            = null
    is_enabled          = lookup(var.budgets.aws_cloudwatch_event_rule, "is_enabled", true)
  }
  aws_cloudwatch_event_target = {
    event_bus_name      = null
    target_id           = null
    arn                 = module.aws_recipes_lambda_create_budgets.arn
    input               = null
    input_path          = null
    role_arn            = null
    run_command_targets = []
    ecs_target          = []
    batch_target        = []
    kinesis_target      = []
    sqs_target          = []
    input_transformer   = []
    retry_policy        = []
    dead_letter_config  = []
  }
  tags = var.tags
}
