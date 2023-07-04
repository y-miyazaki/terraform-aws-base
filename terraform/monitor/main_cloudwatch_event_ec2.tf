#--------------------------------------------------------------
# CloudWatch Events:EC2
# The following events are monitored.
# - EC2 Instance Rebalance Recommendation
# - EC2 Spot Instance Interruption Warning
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an EC2.
#--------------------------------------------------------------
module "aws_recipes_cloudwatch_events_ec2" {
  source     = "../../modules/aws/recipes/cloudwatch/events/ec2"
  is_enabled = lookup(var.cloudwatch_event_ec2, "is_enabled", true)
  aws_cloudwatch_event_rule = {
    name        = "${var.name_prefix}${lookup(var.cloudwatch_event_ec2.aws_cloudwatch_event_rule, "name", "ec2-cloudwatch-event-rule")}"
    description = lookup(var.cloudwatch_event_ec2.aws_cloudwatch_event_rule, "description", null)
    is_enabled  = lookup(var.cloudwatch_event_ec2.aws_cloudwatch_event_rule, "is_enabled", true)
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
  version = "5.1.0"
  create  = lookup(var.cloudwatch_event_ec2, "is_enabled", true)

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
      source_arn          = module.aws_recipes_cloudwatch_events_ec2.arn
      statement_id        = "EC2DetectUnexpectedUsage"
      statement_id_prefix = null
    }
  }
  attach_network_policy             = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_retention_in_days = var.cloudwatch_event_ec2.aws_cloudwatch_log_group_lambda.retention_in_days
  environment_variables             = lookup(var.cloudwatch_event_ec2.aws_lambda_function, "environment")
  description                       = "This program sends the result of EC2 to Slack."
  function_name                     = "${var.name_prefix}cloudwatch-event-ec2"
  handler                           = "cloudwatch_event_ec2_to_slack"
  lambda_role                       = module.aws_recipes_iam_role_lambda.arn
  local_existing_package            = "../../lambda/outputs/cloudwatch_event_ec2_to_slack.zip"
  memory_size                       = 128
  runtime                           = "go1.x"
  timeout                           = 300
  tags                              = var.tags
  tracing_mode                      = "PassThrough"
  vpc_subnet_ids                    = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc.private_subnets : var.common_lambda.vpc.exsits.private_subnets : []
  vpc_security_group_ids            = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc.default_security_group_id] : [var.common_lambda.vpc.exsits.security_group_id] : []
  depends_on = [
    module.lambda_vpc
  ]
}
