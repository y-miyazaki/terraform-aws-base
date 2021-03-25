#--------------------------------------------------------------
# For Trusted Advisor
#--------------------------------------------------------------

#--------------------------------------------------------------
# Enables Security Hub for this AWS account.
#--------------------------------------------------------------
module "aws_recipes_trusted_advisor" {
  source = "../modules/aws/recipes/trusted_advisor"
  count  = var.trusted_advisor.is_enabled ? 1 : 0
  aws_cloudwatch_event_rule = {
    name                = "${var.name_prefix}${lookup(var.trusted_advisor.aws_cloudwatch_event_rule, "name", "budgets")}"
    schedule_expression = lookup(var.trusted_advisor.aws_cloudwatch_event_rule, "schedule_expression", "cron(*/5 * * * ? *)")
    description         = lookup(var.trusted_advisor.aws_cloudwatch_event_rule, "description", null)
    is_enabled          = lookup(var.trusted_advisor.aws_cloudwatch_event_rule, "is_enabled", true)
  }
  aws_cloudwatch_event_target = {
    arn = module.aws_recipes_lambda_create_trusted_advisor[0].arn
  }
  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
#--------------------------------------------------------------
module "aws_recipes_lambda_create_trusted_advisor" {
  source                   = "../modules/aws/recipes/lambda/create"
  count                    = var.trusted_advisor.is_enabled ? 1 : 0
  aws_cloudwatch_log_group = lookup(var.trusted_advisor, "aws_cloudwatch_log_group_lambda")
  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "./lambda/outputs/cloudwatch_event_trusted_advisor_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-event-trusted-advisor"
    dead_letter_config             = []
    handler                        = "cloudwatch_event_trusted_advisor_to_slack"
    role                           = module.aws_recipes_iam_lambda.arn
    description                    = "This program sends the result of Trusted Advisor to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "go1.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    vpc_config                     = []
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("./lambda/outputs/cloudwatch_event_trusted_advisor_to_slack.zip")
    environment                    = lookup(var.trusted_advisor.aws_lambda_function, "environment")
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Event Rule, SNS or S3).
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    principal           = "events.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = module.aws_recipes_trusted_advisor[0].arn
    statement_id        = "TrustedAdvisorDetectUnexpectedUsage"
    statement_id_prefix = null
  }
  tags = var.tags
}
