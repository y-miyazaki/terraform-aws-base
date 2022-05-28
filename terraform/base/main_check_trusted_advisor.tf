#--------------------------------------------------------------
# For Trusted Advisor
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables Security Hub for this AWS account.
#--------------------------------------------------------------
module "aws_recipes_trusted_advisor" {
  source     = "../../modules/aws/recipes/trusted_advisor"
  is_enabled = lookup(var.trusted_advisor, "is_enabled", true)
  aws_cloudwatch_event_rule = {
    name                = "${var.name_prefix}${lookup(var.trusted_advisor.aws_cloudwatch_event_rule, "name", "budgets")}"
    schedule_expression = lookup(var.trusted_advisor.aws_cloudwatch_event_rule, "schedule_expression", "cron(0 0 * * ? *)")
    description         = lookup(var.trusted_advisor.aws_cloudwatch_event_rule, "description", null)
    is_enabled          = lookup(var.trusted_advisor.aws_cloudwatch_event_rule, "is_enabled", true)
  }
  aws_cloudwatch_event_target = {
    arn = module.lambda_function_trusted_advisor.lambda_function_arn
  }
  tags = var.tags
}


#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_trusted_advisor" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "3.2.1"
  create  = lookup(var.trusted_advisor, "is_enabled", true)

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
      source_arn          = module.aws_recipes_trusted_advisor.arn
      statement_id        = "TrustedAdvisorDetectUnexpectedUsage"
      statement_id_prefix = null
    }
  }
  cloudwatch_logs_retention_in_days = var.trusted_advisor.aws_cloudwatch_log_group_lambda.retention_in_days
  environment_variables             = lookup(var.trusted_advisor.aws_lambda_function, "environment")
  description                       = "This program sends the result of Trusted Advisor to Slack."
  function_name                     = "${var.name_prefix}cloudwatch-event-trusted-advisor"
  handler                           = "cloudwatch_event_trusted_advisor_to_slack"
  lambda_role                       = module.aws_recipes_iam_lambda.arn
  local_existing_package            = "../../lambda/outputs/cloudwatch_event_trusted_advisor_to_slack.zip"
  memory_size                       = 128
  runtime                           = "go1.x"
  timeout                           = 300
  tags                              = var.tags
  tracing_mode                      = "PassThrough"
  vpc_subnet_ids                    = module.lambda_vpc.private_subnets
  vpc_security_group_ids            = [module.lambda_vpc.default_security_group_id]
}
