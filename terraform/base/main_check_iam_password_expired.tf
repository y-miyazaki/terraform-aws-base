#--------------------------------------------------------------
# For IAM password expired
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an IAM password expired.
#--------------------------------------------------------------
module "aws_cloudwatch_events_iam_password_expired" {
  source     = "../../modules/aws/cloudwatch/events/iam_password_expired"
  is_enabled = var.iam_password_expired.is_enabled && !var.use_control_tower
  aws_cloudwatch_event_rule = {
    name                = "${var.name_prefix}${lookup(var.iam_password_expired.aws_cloudwatch_event_rule, "name", "iam-password-expired-cloudwatch-event-rule")}"
    schedule_expression = lookup(var.iam_password_expired.aws_cloudwatch_event_rule, "schedule_expression", "cron(0 0 * * ? *)")
    description         = lookup(var.iam_password_expired.aws_cloudwatch_event_rule, "description", null)
    state               = lookup(var.iam_password_expired.aws_cloudwatch_event_rule, "state", "ENABLED")
  }
  aws_cloudwatch_event_target = {
    arn = module.lambda_function_iam_password_expired.lambda_function_arn
  }
  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_iam_password_expired" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.0.1"
  create  = var.iam_password_expired.is_enabled && !var.use_control_tower

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
      source_arn          = module.aws_cloudwatch_events_iam_password_expired.arn
      statement_id        = "IAMPasswordExpiredDetectUnexpectedUsage"
      statement_id_prefix = null
    }
  }
  attach_network_policy             = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_retention_in_days = var.iam_password_expired.aws_cloudwatch_log_group_lambda.retention_in_days
  environment_variables             = lookup(var.iam_password_expired.aws_lambda_function, "environment")
  description                       = "This program sends the result of IAM password expired to Slack."
  function_name                     = "${var.name_prefix}cloudwatch-event-iam-password-expired"
  handler                           = "cloudwatch_event_iam_password_expired_to_slack"
  lambda_role                       = module.aws_iam_role_lambda.arn
  local_existing_package            = "../../lambda/outputs/go_cloudwatch_event_iam_password_expired_to_slack.zip"
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
