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
module "aws_recipes_security_config_create_v4_us_east_1" {
  source = "../../modules/aws/recipes/security/config/create-v4"
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
    bucket_id = module.aws_recipes_s3_bucket_log_v4_common.id
    # The S3 bucket arn
    bucket_arn = module.aws_recipes_s3_bucket_log_v4_common.arn
  }
  aws_config_delivery_channel              = local.aws_config_delivery_channel_config_us_east_1
  aws_config_configuration_recorder_status = lookup(var.security_config_us_east_1, "aws_config_configuration_recorder_status")
  aws_cloudwatch_event_rule = {
    name        = "${var.name_prefix}${lookup(var.security_config_us_east_1.aws_cloudwatch_event_rule, "name", "security-©-cloudwatch-event-rule")}"
    description = lookup(var.security_config_us_east_1.aws_cloudwatch_event_rule, "description", "This cloudwatch event used for Config.")
  }
  aws_cloudwatch_event_target = {
    arn = module.lambda_function_config_us_east_1.lambda_function_arn
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
    module.aws_recipes_security_config_create_v4_us_east_1
  ]
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_config_us_east_1" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "3.2.1"
  providers = {
    aws = aws.us-east-1
  }
  create = lookup(var.security_config_us_east_1, "is_enabled", true)

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
      source_arn          = module.aws_recipes_security_config_create_v4_us_east_1.arn
      statement_id        = "ConfigDetectUnexpectedUsage"
      statement_id_prefix = null
    }
  }
  cloudwatch_logs_retention_in_days = var.security_config_us_east_1.aws_cloudwatch_log_group_lambda.retention_in_days
  environment_variables             = lookup(var.security_config_us_east_1.aws_lambda_function, "environment")
  description                       = "This program sends the result of config to Slack."
  function_name                     = "${var.name_prefix}cloudwatch-event-config"
  handler                           = "cloudwatch_event_config_to_slack"
  lambda_role                       = module.aws_recipes_iam_lambda.arn
  local_existing_package            = "../../lambda/outputs/cloudwatch_event_config_to_slack.zip"
  memory_size                       = 128
  runtime                           = "go1.x"
  timeout                           = 300
  tags                              = var.tags
  tracing_mode                      = "PassThrough"
  vpc_subnet_ids                    = module.lambda_vpc.private_subnets
  vpc_security_group_ids            = [module.lambda_vpc.default_security_group_id]
}
