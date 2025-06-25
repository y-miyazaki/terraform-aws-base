#--------------------------------------------------------------
# For AWS Config
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_config_configuration_recorder_config = merge(var.security_config.aws_config_configuration_recorder, {
    name = "${var.name_prefix}${var.security_config.aws_config_configuration_recorder.name}"
    }
  )
  aws_iam_role_config = merge(var.security_config.aws_iam_role, {
    name = "${var.name_prefix}${var.security_config.aws_iam_role.name}"
    }
  )
  #   aws_s3_bucket_config = merge(var.security_config.aws_s3_bucket, { bucket = "${var.name_prefix}${var.security_config.aws_s3_bucket.bucket}-${data.aws_caller_identity.current.account_id}" })
  aws_config_delivery_channel_config = merge(var.security_config.aws_config_delivery_channel, {
    name = "${var.name_prefix}${var.security_config.aws_config_delivery_channel.name}"
    }
  )
  aws_iam_role_ssm_automation = merge(var.security_config.ssm_automation.aws_iam_role, {
    name = "${var.name_prefix}${var.security_config.ssm_automation.aws_iam_role.name}"
    }
  )
  aws_iam_policy_ssm_automation = merge(var.security_config.ssm_automation.aws_iam_policy, {
    name = "${var.name_prefix}${var.security_config.ssm_automation.aws_iam_policy.name}"
    }
  )
}
#--------------------------------------------------------------
# Provides AWS Config.
#--------------------------------------------------------------
module "aws_security_config_create_v4" {
  source                            = "../../modules/aws/security/config/create-v4"
  is_enabled                        = var.security_config.is_enabled && !var.use_control_tower
  is_s3_enabled                     = var.security_config.is_s3_enabled
  aws_config_configuration_recorder = local.aws_config_configuration_recorder_config
  aws_iam_role                      = local.aws_iam_role_config
  #   aws_s3_bucket                     = local.aws_s3_bucket_config
  aws_s3_bucket_existing = {
    # The S3 bucket id
    bucket_id = local.s3_log_bucket
    # The S3 bucket arn
    bucket_arn = "arn:aws:s3:::${local.s3_log_bucket}"
  }
  aws_config_delivery_channel              = local.aws_config_delivery_channel_config
  aws_config_configuration_recorder_status = var.security_config.aws_config_configuration_recorder_status
  aws_cloudwatch_event_rule = {
    name        = "${var.name_prefix}${var.security_config.aws_cloudwatch_event_rule.name}"
    description = var.security_config.aws_cloudwatch_event_rule.description
  }
  aws_cloudwatch_event_target = {
    arn = module.lambda_function_config.lambda_function_arn
  }
  tags = var.tags
}
#--------------------------------------------------------------
# Create SSM Automation Role
#--------------------------------------------------------------
module "aws_security_config_ssm_automation" {
  source         = "../../modules/aws/security/config/ssm_automation"
  is_enabled     = var.security_config.is_enabled && !var.use_control_tower
  aws_iam_role   = local.aws_iam_role_ssm_automation
  aws_iam_policy = local.aws_iam_policy_ssm_automation
  tags           = var.tags
}

#--------------------------------------------------------------
# Provides an AWS Config Rule for API Gateway
#--------------------------------------------------------------
module "aws_security_config_rule_api_gateway" {
  source      = "../../modules/aws/security/config/rule/api_gateway"
  is_enabled  = var.security_config.is_enabled && !var.use_control_tower
  name_prefix = var.name_prefix
  tags        = var.tags
  depends_on = [
    module.aws_security_config_create_v4
  ]
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for RDS
#--------------------------------------------------------------
module "aws_security_config_rule_rds" {
  source      = "../../modules/aws/security/config/rule/rds"
  is_enabled  = var.security_config.is_enabled && !var.use_control_tower
  name_prefix = var.name_prefix
  tags        = var.tags
  depends_on = [
    module.aws_security_config_create_v4
  ]
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for Load Balancer
#--------------------------------------------------------------
module "aws_security_config_rule_load_balancer" {
  source      = "../../modules/aws/security/config/rule/load_balancer"
  is_enabled  = var.security_config.is_enabled && !var.use_control_tower
  name_prefix = var.name_prefix
  tags        = var.tags
  depends_on = [
    module.aws_security_config_create_v4
  ]
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for EC2
#--------------------------------------------------------------
module "aws_security_config_rule_ec2" {
  source                                      = "../../modules/aws/security/config/rule/ec2"
  is_enabled                                  = var.security_config.is_enabled && !var.use_control_tower
  name_prefix                                 = var.name_prefix
  ssm_automation_assume_role_arn              = module.aws_security_config_ssm_automation.role_arn
  is_disable_public_access_for_security_group = var.security_config.remediation.ec2.is_disable_public_access_for_security_group
  tags                                        = var.tags
  depends_on = [
    module.aws_security_config_create_v4
  ]
}
#--------------------------------------------------------------
# Provides an AWS Config Rule for S3
#--------------------------------------------------------------
module "aws_security_config_rule_s3" {
  source                                     = "../../modules/aws/security/config/rule/s3"
  is_enabled                                 = var.security_config.is_enabled && !var.use_control_tower
  name_prefix                                = var.name_prefix
  ssm_automation_assume_role_arn             = module.aws_security_config_ssm_automation.role_arn
  is_configure_s3_bucket_public_access_block = var.security_config.remediation.s3.is_configure_s3_bucket_public_access_block
  configure_s3_bucket_public_access_block    = var.security_config.remediation.s3.configure_s3_bucket_public_access_block
  is_disable_s3_bucket_public_read_write     = var.security_config.remediation.s3.is_disable_s3_bucket_public_read_write
  is_enabled_s3_bucket_encryption            = var.security_config.remediation.s3.is_enabled_s3_bucket_encryption
  enabled_s3_bucket_encryption_sse_algorithm = var.security_config.remediation.s3.enabled_s3_bucket_encryption_sse_algorithm
  is_restrict_bucket_ssl_requests_only       = var.security_config.remediation.s3.is_restrict_bucket_ssl_requests_only
  is_configure_s3_bucket_versioning          = var.security_config.remediation.s3.is_configure_s3_bucket_versioning
  tags                                       = var.tags
  depends_on = [
    module.aws_security_config_create_v4
  ]
}

#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_config" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.0.1"
  create  = var.security_config.is_enabled && !var.use_control_tower

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
      source_arn          = module.aws_security_config_create_v4.arn
      statement_id        = "ConfigDetectUnexpectedUsage"
      statement_id_prefix = null
    }
  }
  attach_network_policy             = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_retention_in_days = var.security_config.aws_cloudwatch_log_group_lambda.retention_in_days
  environment_variables             = var.security_config.aws_lambda_function.environment
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
  vpc_subnet_ids                    = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc.private_subnets : var.common_lambda.vpc.exists.private_subnets : []
  vpc_security_group_ids            = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id] : []
  depends_on = [
    module.lambda_vpc
  ]
}
