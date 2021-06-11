#--------------------------------------------------------------
# For Health
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an Health.
#--------------------------------------------------------------
module "aws_recipes_health" {
  source     = "../../modules/aws/recipes/health"
  is_enabled = lookup(var.health, "is_enabled", true)
  aws_cloudwatch_event_rule = {
    name        = "${var.name_prefix}${lookup(var.health.aws_cloudwatch_event_rule, "name", "health-cloudwatch-event-rule")}"
    description = lookup(var.health.aws_cloudwatch_event_rule, "description", "This cloudwatch event used for Health.")
  }
  aws_cloudwatch_event_target = {
    arn = module.aws_recipes_lambda_create_health.arn
  }
  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
#--------------------------------------------------------------
module "aws_recipes_lambda_create_health" {
  source                   = "../../modules/aws/recipes/lambda/create"
  is_enabled               = lookup(var.health, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.health, "aws_cloudwatch_log_group_lambda")
  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "../../lambda/outputs/cloudwatch_event_health_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-event-health"
    dead_letter_config             = []
    handler                        = "cloudwatch_event_health_to_slack"
    role                           = module.aws_recipes_iam_lambda.arn
    description                    = "This program sends the result of Health to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "go1.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    vpc_config                     = []
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("../../lambda/outputs/cloudwatch_event_health_to_slack.zip")
    environment                    = lookup(var.health.aws_lambda_function, "environment")
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Event Rule, SNS or S3).
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    principal           = "events.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = module.aws_recipes_health.arn
    statement_id        = "HealthDetectUnexpectedUsage"
    statement_id_prefix = null
  }
  tags = var.tags
}
