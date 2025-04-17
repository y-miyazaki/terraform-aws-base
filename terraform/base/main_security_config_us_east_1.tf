#--------------------------------------------------------------
# For AWS Config
# for CloudFront
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_config_configuration_recorder_config_us_east_1 = merge(var.security_config_us_east_1.aws_config_configuration_recorder, {
    name = "${var.name_prefix}${var.security_config_us_east_1.aws_config_configuration_recorder.name}"
    }
  )
  aws_iam_role_config_us_east_1 = merge(var.security_config_us_east_1.aws_iam_role, {
    name = "${var.name_prefix}${var.security_config_us_east_1.aws_iam_role.name}"
    }
  )
  #   aws_s3_bucket_config = merge(var.security_config_us_east_1.aws_s3_bucket, { bucket = "${var.name_prefix}${var.security_config_us_east_1.aws_s3_bucket.bucket}-${data.aws_caller_identity.current.account_id}" })
  aws_config_delivery_channel_config_us_east_1 = merge(var.security_config_us_east_1.aws_config_delivery_channel, {
    name = "${var.name_prefix}${var.security_config_us_east_1.aws_config_delivery_channel.name}"
    }
  )
}
#--------------------------------------------------------------
# Provides AWS Config.
#--------------------------------------------------------------
module "aws_security_config_create_v4_us_east_1" {
  source = "../../modules/aws/security/config/create-v4"
  providers = {
    aws = aws.us-east-1
  }
  is_enabled                        = var.security_config_us_east_1.is_enabled && var.use_control_tower
  is_s3_enabled                     = var.security_config_us_east_1.is_s3_enabled
  aws_config_configuration_recorder = local.aws_config_configuration_recorder_config_us_east_1
  aws_iam_role                      = local.aws_iam_role_config_us_east_1
  aws_s3_bucket_existing = {
    # The S3 bucket id
    bucket_id = local.s3_log_bucket
    # The S3 bucket arn
    bucket_arn = "arn:aws:s3:::${local.s3_log_bucket}"
  }
  aws_config_delivery_channel              = local.aws_config_delivery_channel_config_us_east_1
  aws_config_configuration_recorder_status = var.security_config_us_east_1.aws_config_configuration_recorder_status
  aws_cloudwatch_event_rule = {
    name        = "${var.name_prefix}${var.security_config_us_east_1.aws_cloudwatch_event_rule.name}"
    description = var.security_config_us_east_1.aws_cloudwatch_event_rule.description
  }
  aws_cloudwatch_event_target = {
    arn = module.lambda_function_config_us_east_1.lambda_function_arn
  }
  tags = var.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for API Gateway
#--------------------------------------------------------------
module "aws_security_config_rule_cloudfront_us_east_1" {
  source = "../../modules/aws/security/config/rule/cloudfront"
  providers = {
    aws = aws.us-east-1
  }
  is_enabled                               = var.security_config_us_east_1.is_enabled && var.use_control_tower
  name_prefix                              = var.name_prefix
  ssm_automation_assume_role_arn           = module.aws_security_config_ssm_automation.role_arn
  is_enable_cloudfront_viewer_policy_https = var.security_config_us_east_1.remediation.cloudfront.is_enable_cloudfront_viewer_policy_https
  tags                                     = var.tags
  depends_on = [
    module.aws_security_config_create_v4_us_east_1
  ]
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_config_us_east_1" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.2.1"
  providers = {
    aws = aws.us-east-1
  }
  create = lookup(var.security_config_us_east_1, "is_enabled", true)

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
      source_arn          = module.aws_security_config_create_v4_us_east_1.arn
      statement_id        = "ConfigDetectUnexpectedUsage"
      statement_id_prefix = null
    }
  }
  attach_network_policy             = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_retention_in_days = var.security_config_us_east_1.aws_cloudwatch_log_group_lambda.retention_in_days
  environment_variables             = lookup(var.security_config_us_east_1.aws_lambda_function, "environment")
  description                       = "This program sends the result of config to Slack."
  function_name                     = "${var.name_prefix}cloudwatch-event-config"
  handler                           = "cloudwatch_event_config_to_slack"
  lambda_role                       = module.aws_iam_role_lambda.arn
  local_existing_package            = "../../lambda/outputs/go_cloudwatch_event_config_to_slack.zip"
  memory_size                       = 128
  runtime                           = "provided.al2"
  timeout                           = 300
  tags                              = var.tags
  tracing_mode                      = "PassThrough"
  vpc_subnet_ids                    = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc_us_east_1.private_subnets : var.common_lambda.vpc.exists.private_subnets_us_east_1 : []
  vpc_security_group_ids            = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc_us_east_1.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id_east_1] : []
  depends_on = [
    module.lambda_vpc_us_east_1
  ]
}
