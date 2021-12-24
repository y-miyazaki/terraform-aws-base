#--------------------------------------------------------------
# For AWS Config
# for CloudFront
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_config_configuration_recorder_config_us_east_1 = merge(var.security_config_us_east_1.aws_config_configuration_recorder, {
    name = "${var.name_prefix}${lookup(var.security_config_us_east_1.aws_config_configuration_recorder, "name")}"
    }
  )
  aws_iam_role_config_us_east_1 = merge(var.security_config_us_east_1.aws_iam_role, {
    name = "${var.name_prefix}${lookup(var.security_config_us_east_1.aws_iam_role, "name")}"
    }
  )
  #   aws_s3_bucket_config = merge(var.security_config_us_east_1.aws_s3_bucket, { bucket = "${var.name_prefix}${var.security_config_us_east_1.aws_s3_bucket.bucket}-${random_id.this.dec}" })
  aws_config_delivery_channel_config_us_east_1 = merge(var.security_config_us_east_1.aws_config_delivery_channel, {
    name = "${var.name_prefix}${lookup(var.security_config_us_east_1.aws_config_delivery_channel, "name")}"
    }
  )
}
#--------------------------------------------------------------
# Provides AWS Config.
#--------------------------------------------------------------
module "aws_recipes_security_config_create_us_east_1" {
  source = "../../modules/aws/recipes/security/config/create"
  providers = {
    aws = aws.us-east-1
  }
  is_enabled                        = lookup(var.security_config_us_east_1, "is_enabled", true)
  is_s3_enabled                     = lookup(var.security_config_us_east_1, "is_s3_enabled", false)
  aws_config_configuration_recorder = local.aws_config_configuration_recorder_config_us_east_1
  aws_iam_role                      = local.aws_iam_role_config_us_east_1
  #   aws_s3_bucket                     = local.aws_s3_bucket_config_us_east_1
  aws_s3_bucket_existing = {
    # The S3 bucket id
    bucket_id = module.aws_recipes_s3_bucket_log_common.id
    # The S3 bucket arn
    bucket_arn = module.aws_recipes_s3_bucket_log_common.arn
  }
  aws_config_delivery_channel              = local.aws_config_delivery_channel_config_us_east_1
  aws_config_configuration_recorder_status = lookup(var.security_config_us_east_1, "aws_config_configuration_recorder_status")
  aws_cloudwatch_event_rule = {
    name        = "${var.name_prefix}${lookup(var.security_config_us_east_1.aws_cloudwatch_event_rule, "name", "security-©-cloudwatch-event-rule")}"
    description = lookup(var.security_config_us_east_1.aws_cloudwatch_event_rule, "description", "This cloudwatch event used for Config.")
  }
  aws_cloudwatch_event_target = {
    arn = module.aws_recipes_lambda_create_config_us_east_1.arn
  }
  account_id = data.aws_caller_identity.current.account_id
  tags       = var.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for API Gateway
#--------------------------------------------------------------
module "aws_recipes_security_config_rule_cloudfront_us_east_1" {
  source = "../../modules/aws/recipes/security/config/rule/cloudfront"
  providers = {
    aws = aws.us-east-1
  }
  is_enabled                               = lookup(var.security_config_us_east_1, "is_enabled", true)
  name_prefix                              = var.name_prefix
  ssm_automation_assume_role_arn           = module.aws_recipes_security_config_ssm_automation.role_arn
  is_enable_cloudfront_viewer_policy_https = lookup(var.security_config_us_east_1.remediation.cloudfront, "is_enable_cloudfront_viewer_policy_https", false)
  tags                                     = var.tags
  depends_on = [
    module.aws_recipes_security_config_create_us_east_1
  ]
}

#--------------------------------------------------------------
# Create Lambda function
#--------------------------------------------------------------
module "aws_recipes_lambda_create_config_us_east_1" {
  source = "../../modules/aws/recipes/lambda/create"
  providers = {
    aws = aws.us-east-1
  }
  is_enabled               = lookup(var.security_config_us_east_1, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.security_config_us_east_1, "aws_cloudwatch_log_group_lambda")
  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "../../lambda/outputs/cloudwatch_event_config_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-event-config"
    dead_letter_config             = []
    handler                        = "cloudwatch_event_config_to_slack"
    role                           = module.aws_recipes_iam_lambda.arn
    description                    = "This program sends the result of config to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "go1.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    vpc_config                     = []
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("../../lambda/outputs/cloudwatch_event_config_to_slack.zip")
    environment                    = lookup(var.security_config_us_east_1.aws_lambda_function, "environment")
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Event Rule, SNS or S3).
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    principal           = "events.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = module.aws_recipes_security_config_create_us_east_1.arn
    statement_id        = "configDetectUnexpectedUsage"
    statement_id_prefix = null
  }
  tags = var.tags
}
