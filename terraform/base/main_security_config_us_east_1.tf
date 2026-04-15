#--------------------------------------------------------------
# For AWS Config for CloudFront
#--------------------------------------------------------------
#--------------------------------------------------------------
# Locals
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
# NOTE: Skip creation if default region is already us-east-1 to avoid duplication
#--------------------------------------------------------------
module "aws_security_config_create_v4_us_east_1" {
  source     = "../../modules/aws/security/config/create-v4"
  is_enabled = !local.is_default_region_us_east_1 && var.security_config_us_east_1.is_enabled && !local.control_tower_managed_services.config
  providers = {
    aws = aws.us-east-1
  }

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
# NOTE: Skip creation if default region is already us-east-1 to avoid duplication
#--------------------------------------------------------------
module "aws_security_config_rule_cloudfront_us_east_1" {
  source     = "../../modules/aws/security/config/rule/cloudfront"
  is_enabled = !local.is_default_region_us_east_1 && var.security_config_us_east_1.is_enabled && !local.control_tower_managed_services.config
  providers = {
    aws = aws.us-east-1
  }

  name_prefix                              = var.name_prefix
  ssm_automation_assume_role_arn           = module.aws_security_config_ssm_automation.role_arn
  is_enable_cloudfront_viewer_policy_https = var.security_config_us_east_1.remediation.cloudfront.is_enable_cloudfront_viewer_policy_https

  tags = var.tags

  depends_on = [
    module.aws_security_config_create_v4_us_east_1
  ]
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
# NOTE: Skip creation if default region is already us-east-1 to avoid duplication
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_config_us_east_1" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"
  providers = {
    aws = aws.us-east-1
  }
  # Skip if default region is us-east-1
  create = !local.is_default_region_us_east_1 && var.security_config_us_east_1.is_enabled && !local.control_tower_managed_services.config

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "events.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_security_config_create_v4_us_east_1.arn
      statement_id        = "ConfigDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key_us_east_1["base"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.security_config.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of config to Slack."
  environment_variables = {
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.security_config.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.security_config.channel_id, null), var.slack.channel_id)
  }
  function_name                 = "${var.name_prefix}cloudwatch-event-config"
  handler                       = "cloudwatch_event_config_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_event_config_to_slack.zip"
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 128
  publish                       = false
  runtime                       = "provided.al2023"
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc_us_east_1.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id_us_east_1] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc_us_east_1.private_subnets : var.common_lambda.vpc.exists.private_subnets_us_east_1 : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc_us_east_1
  ]
}
