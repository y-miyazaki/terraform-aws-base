#--------------------------------------------------------------
# IAM role of Lambda for alarm monitoring
# for CloudFront
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_kms_key_lambda_us_east_1 = merge(var.common_lambda.metric.aws_kms_key, {
    description             = lookup(var.common_lambda.metric.aws_kms_key, "description", null)
    deletion_window_in_days = lookup(var.common_lambda.metric.aws_kms_key, "deletion_window_in_days", 7)
    is_enabled              = lookup(var.common_lambda.metric.aws_kms_key, "is_enabled")
    enable_key_rotation     = lookup(var.common_lambda.metric.aws_kms_key, "enable_key_rotation")
    alias_name              = "alias/${var.name_prefix}${lookup(var.common_lambda.metric.aws_kms_key, "alias_name")}"
    }
  )

  aws_sns_topic_lambda_us_east_1 = merge(var.common_lambda.metric.aws_sns_topic, {
    name = "${var.name_prefix}${lookup(var.common_lambda.metric.aws_sns_topic, "name")}"
    }
  )
}
#--------------------------------------------------------------
# Provides a SNS
#--------------------------------------------------------------
module "aws_recipes_sns_subscription_lambda_us_east_1" {
  source = "../../modules/aws/recipes/sns/subscription"
  providers = {
    aws = aws.us-east-1
  }
  aws_kms_key   = local.aws_kms_key_lambda_us_east_1
  aws_sns_topic = local.aws_sns_topic_lambda_us_east_1
  aws_sns_topic_subscription = {
    protocol                        = lookup(var.common_lambda.aws_sns_topic_subscription, "protocol")
    endpoint                        = module.aws_recipes_lambda_create_lambda_us_east_1.arn
    endpoint_auto_confirms          = lookup(var.common_lambda.aws_sns_topic_subscription, "endpoint_auto_confirms")
    confirmation_timeout_in_minutes = lookup(var.common_lambda.aws_sns_topic_subscription, "confirmation_timeout_in_minutes")
    raw_message_delivery            = lookup(var.common_lambda.aws_sns_topic_subscription, "raw_message_delivery")
    filter_policy                   = lookup(var.common_lambda.aws_sns_topic_subscription, "filter_policy")
    delivery_policy                 = lookup(var.common_lambda.aws_sns_topic_subscription, "delivery_policy")
    redrive_policy                  = lookup(var.common_lambda.aws_sns_topic_subscription, "redrive_policy")
  }

  account_id = data.aws_caller_identity.current.account_id
  region     = var.region
  user       = var.deploy_user
  tags       = var.tags
}
#--------------------------------------------------------------
# Create Lambda function
#--------------------------------------------------------------
module "aws_recipes_lambda_create_lambda_us_east_1" {
  source = "../../modules/aws/recipes/lambda/create"
  providers = {
    aws = aws.us-east-1
  }
  is_enabled               = lookup(var.common_lambda, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.common_lambda, "aws_cloudwatch_log_group_lambda")

  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "../../lambda/outputs/cloudwatch_alarm_to_sns_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-alarm-monitor"
    dead_letter_config             = []
    handler                        = "cloudwatch_alarm_to_sns_to_slack"
    role                           = module.aws_recipes_iam_role_lambda.arn
    description                    = "This program sends the result of monitor to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "go1.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    vpc_config = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [
      {
        subnet_ids         = module.lambda_vpc_us_east_1.private_subnets
        security_group_ids = [module.lambda_vpc_us_east_1.default_security_group_id]
      }
      ] : [
      {
        subnet_ids         = var.common_lambda.vpc.exsits.private_subnets_us_east_1
        security_group_ids = [var.common_lambda.vpc.exsits.security_group_id_us_east_1]
      }
    ] : []
    kms_key_arn      = null
    source_code_hash = filebase64sha256("../../lambda/outputs/cloudwatch_alarm_to_sns_to_slack.zip")
    environment      = lookup(var.common_lambda.metric.aws_lambda_function, "environment")
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Events Rule, SNS or S3).
  tags = var.tags
  depends_on = [
    module.lambda_vpc_us_east_1
  ]
}

#--------------------------------------------------------------
# Create Lambda Permission
#--------------------------------------------------------------
module "aws_recipes_lambda_permission_lambda_us_east_1" {
  source = "../../modules/aws/recipes/lambda/permission"
  providers = {
    aws = aws.us-east-1
  }
  is_enabled = lookup(var.common_lambda, "is_enabled", true)
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    function_name       = module.aws_recipes_lambda_create_lambda_us_east_1.function_name
    principal           = "sns.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = module.aws_recipes_sns_subscription_lambda_us_east_1.arn
    statement_id        = "MonitorDetectUnexpectedUsage"
    statement_id_prefix = null
  }
}
