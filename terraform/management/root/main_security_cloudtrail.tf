#--------------------------------------------------------------
# For CloudTrail
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_kms_key_cloudtrail = merge(var.security_cloudtrail.aws_kms_key, {
    cloudtrail = {
      description             = lookup(var.security_cloudtrail.aws_kms_key.cloudtrail, "description", null)
      deletion_window_in_days = lookup(var.security_cloudtrail.aws_kms_key.cloudtrail, "deletion_window_in_days", 7)
      is_enabled              = var.security_cloudtrail.aws_kms_key.cloudtrail.is_enabled
      enable_key_rotation     = var.security_cloudtrail.aws_kms_key.cloudtrail.enable_key_rotation
      alias_name              = "alias/${var.name_prefix}${var.security_cloudtrail.aws_kms_key.cloudtrail.alias_name}"
    }
    sns = {
      description             = lookup(var.security_cloudtrail.aws_kms_key.sns, "description", null)
      deletion_window_in_days = lookup(var.security_cloudtrail.aws_kms_key.sns, "deletion_window_in_days", 7)
      is_enabled              = var.security_cloudtrail.aws_kms_key.sns.is_enabled
      enable_key_rotation     = var.security_cloudtrail.aws_kms_key.sns.enable_key_rotation
      alias_name              = "alias/${var.name_prefix}${var.security_cloudtrail.aws_kms_key.sns.alias_name}"
    }
    }
  )
  aws_sns_topic_cloudtrail = merge(var.security_cloudtrail.aws_sns_topic, {
    name = "${var.name_prefix}${var.security_cloudtrail.aws_sns_topic.name}"
    }
  )
  aws_sns_topic_subscription_cloudtrail = merge(var.security_cloudtrail.aws_sns_topic_subscription, {
    endpoint = module.lambda_function_cloudtrail.lambda_function_arn
    }
  )
}

#--------------------------------------------------------------
# Provides a CloudTrail.
#--------------------------------------------------------------
module "aws_security_cloudtrail_controltower" {
  source                     = "../../../modules/aws/security/cloudtrail/controltower"
  is_enabled                 = lookup(var.security_cloudtrail, "is_enabled", true)
  aws_kms_key                = local.aws_kms_key_cloudtrail
  aws_sns_topic              = local.aws_sns_topic_cloudtrail
  aws_sns_topic_subscription = local.aws_sns_topic_subscription_cloudtrail
  cis_name_prefix            = var.name_prefix
  account_id                 = data.aws_caller_identity.current.account_id
  region                     = var.region
  tags                       = var.tags
}

#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter And Alarm resource.
#--------------------------------------------------------------
module "aws_cloudwatch_alarm_cloudtrail" {
  for_each                          = var.security_cloudtrail.is_enabled ? var.security_cloudtrail.aws_cloudwatch_log : {}
  source                            = "../../../modules/aws/cloudwatch/alarm/log"
  alarm_actions                     = var.security_cloudtrail.is_enabled ? [module.aws_security_cloudtrail_controltower.sns_topic_arn] : []
  create_auto_log_group_names       = false
  auto_log_group_names_exclude_list = []
  log_group_names = [
    "aws-controltower/CloudTrailLogs"
  ]
  name_prefix                      = var.name_prefix
  aws_cloudwatch_log_metric_filter = each.value.aws_cloudwatch_log_metric_filter
  aws_cloudwatch_metric_alarm      = each.value.aws_cloudwatch_metric_alarm
  tags                             = var.tags
}
#--------------------------------------------------------------
# Create Lambda function
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "lambda_function_cloudtrail" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.2"
  create  = lookup(var.security_cloudtrail, "is_enabled", true)

  architectures                           = ["arm64"]
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "sns.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_security_cloudtrail_controltower.sns_topic_arn
      statement_id        = "CloudTrailDetectUnexpectedUsage"
      statement_id_prefix = null
    }
  }
  attach_network_policy             = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_retention_in_days = var.cloudwatch_log_group_retention_in_days
  environment_variables             = var.security_cloudtrail.aws_lambda_function.environment
  description                       = "This program sends the result of CloudTrail to Slack."
  function_name                     = "${var.name_prefix}cloudwatch-alarm-cloudtrail"
  handler                           = "cloudwatch_alarm_to_sns_to_slack"
  lambda_role                       = module.aws_iam_role_lambda.arn
  local_existing_package            = "../../lambda/outputs/go_cloudwatch_alarm_to_sns_to_slack.zip"
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
