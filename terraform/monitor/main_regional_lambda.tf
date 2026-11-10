#--------------------------------------------------------------
# Alarm notification pipeline (CloudWatch Alarm -> SNS -> Lambda -> Slack).
# Deployed to each monitor region (local.monitor_regions: primary, global when it differs, other region.targets).
# SES event notification resources are deployed to the same regions, so they always exist wherever SES alarms can be enabled.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a SNS
# For Metric
#--------------------------------------------------------------
module "aws_sns_subscription_lambda_metric" {
  for_each = local.monitor_regions

  source = "../../modules/aws/sns/subscription"

  region = each.value

  aws_sns_topic = merge(var.common_lambda.metric.aws_sns_topic, {
    name = "${var.name_prefix}${var.common_lambda.metric.aws_sns_topic.name}"
    }
  )
  aws_sns_topic_subscription = {
    protocol                        = var.common_lambda.aws_sns_topic_subscription.protocol
    endpoint                        = module.aws_lambda_create_lambda_metric[each.key].lambda_function_arn
    endpoint_auto_confirms          = var.common_lambda.aws_sns_topic_subscription.endpoint_auto_confirms
    confirmation_timeout_in_minutes = var.common_lambda.aws_sns_topic_subscription.confirmation_timeout_in_minutes
    raw_message_delivery            = var.common_lambda.aws_sns_topic_subscription.raw_message_delivery
    filter_policy                   = var.common_lambda.aws_sns_topic_subscription.filter_policy
    delivery_policy                 = var.common_lambda.aws_sns_topic_subscription.delivery_policy
    redrive_policy                  = var.common_lambda.aws_sns_topic_subscription.redrive_policy
  }
  kms_master_key_id = module.kms_key[each.key].key_id

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# For Metric
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
module "aws_lambda_create_lambda_metric" {
  for_each = local.monitor_regions

  source  = "terraform-aws-modules/lambda/aws"
  version = "8.12.0"

  region = each.value

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "sns.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = "arn:aws:sns:${each.value}:${data.aws_caller_identity.current.account_id}:${var.name_prefix}${var.common_lambda.metric.aws_sns_topic.name}"
      statement_id        = "MetricDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key[each.key].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.common_lambda_metric.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of metric to Slack."
  environment_variables = merge({
    LOGGER_FORMATTER    = "json"
    LOGGER_OUT          = "stdout"
    LOGGER_LEVEL        = "warn"
    DYNAMODB_TABLE_NAME = module.dynamodb_table_monitor_log[each.key].dynamodb_table_id
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.common_lambda_metric.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.common_lambda_metric.channel_id, null), var.slack.channel_id)
  }, local.devops_agent_webhook_locale_environment, var.common_lambda.metric.aws_lambda_function.environment)
  function_name                 = "${var.name_prefix}cloudwatch-alarm-metric-to-sns-to-slack"
  handler                       = "cloudwatch_alarm_to_sns_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_alarm_to_sns_to_slack.zip"
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 128
  publish                       = false
  runtime                       = "provided.al2023"
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc[each.key].default_security_group_id] : [var.common_lambda.vpc.exists[each.value].security_group_id] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc[each.key].private_subnets : var.common_lambda.vpc.exists[each.value].private_subnets : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc
  ]
}

#--------------------------------------------------------------
# Provides a SNS
# For Log
#--------------------------------------------------------------
module "aws_sns_subscription_lambda_log" {
  for_each = local.monitor_regions

  source = "../../modules/aws/sns/subscription"

  region = each.value

  aws_sns_topic = merge(var.common_lambda.log.aws_sns_topic, {
    name = "${var.name_prefix}${var.common_lambda.log.aws_sns_topic.name}"
    }
  )
  aws_sns_topic_subscription = {
    protocol                        = var.common_lambda.aws_sns_topic_subscription.protocol
    endpoint                        = module.aws_lambda_create_lambda_log[each.key].lambda_function_arn
    endpoint_auto_confirms          = var.common_lambda.aws_sns_topic_subscription.endpoint_auto_confirms
    confirmation_timeout_in_minutes = var.common_lambda.aws_sns_topic_subscription.confirmation_timeout_in_minutes
    raw_message_delivery            = var.common_lambda.aws_sns_topic_subscription.raw_message_delivery
    filter_policy                   = var.common_lambda.aws_sns_topic_subscription.filter_policy
    delivery_policy                 = var.common_lambda.aws_sns_topic_subscription.delivery_policy
    redrive_policy                  = var.common_lambda.aws_sns_topic_subscription.redrive_policy
  }
  kms_master_key_id = module.kms_key[each.key].key_id

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# For Log
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
module "aws_lambda_create_lambda_log" {
  for_each = local.monitor_regions

  source  = "terraform-aws-modules/lambda/aws"
  version = "8.12.0"

  region = each.value

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "sns.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = "arn:aws:sns:${each.value}:${data.aws_caller_identity.current.account_id}:${var.name_prefix}${var.common_lambda.log.aws_sns_topic.name}"
      statement_id        = "LogDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key[each.key].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.common_lambda_log.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of log to Slack."
  environment_variables = merge({
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.common_lambda_log.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.common_lambda_log.channel_id, null), var.slack.channel_id)
  }, local.devops_agent_webhook_locale_environment, var.common_lambda.log.aws_lambda_function.environment)
  function_name                 = "${var.name_prefix}cloudwatch-alarm-log-to-sns-to-slack"
  handler                       = "cloudwatch_alarm_to_sns_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_alarm_to_sns_to_slack.zip"
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 128
  publish                       = false
  runtime                       = "provided.al2023"
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc[each.key].default_security_group_id] : [var.common_lambda.vpc.exists[each.value].security_group_id] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc[each.key].private_subnets : var.common_lambda.vpc.exists[each.value].private_subnets : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc
  ]
}

#--------------------------------------------------------------
# Provides a SNS
# For SES event notification (every monitor region)
#--------------------------------------------------------------
module "aws_sns_subscription_lambda_ses" {
  for_each = local.monitor_regions

  source = "../../modules/aws/sns/subscription"

  region = each.value

  aws_sns_topic = merge(var.common_lambda.ses.aws_sns_topic, tomap({
    name = "${var.name_prefix}${var.common_lambda.ses.aws_sns_topic.name}",
    policy = jsonencode({
      Version = "2008-10-17"
      Statement = [
        {
          Sid    = "SESAllow"
          Effect = "Allow"
          Principal = {
            Service = "ses.amazonaws.com"
          }
          Action = [
            "SNS:Publish",
          ]
          Resource = [
            "arn:aws:sns:${each.value}:${data.aws_caller_identity.current.account_id}:${var.name_prefix}${var.common_lambda.ses.aws_sns_topic.name}",
          ]
          Condition = {
            StringEquals = {
              "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
            }
            StringLike = {
              "AWS:SourceArn" = "arn:aws:ses:${each.value}:${data.aws_caller_identity.current.account_id}:*"
            }
          }
        }
      ]
    })
    })
  )
  aws_sns_topic_subscription = {
    protocol                        = var.common_lambda.aws_sns_topic_subscription.protocol
    endpoint                        = module.aws_lambda_create_lambda_ses[each.key].lambda_function_arn
    endpoint_auto_confirms          = var.common_lambda.aws_sns_topic_subscription.endpoint_auto_confirms
    confirmation_timeout_in_minutes = var.common_lambda.aws_sns_topic_subscription.confirmation_timeout_in_minutes
    raw_message_delivery            = var.common_lambda.aws_sns_topic_subscription.raw_message_delivery
    filter_policy                   = var.common_lambda.aws_sns_topic_subscription.filter_policy
    delivery_policy                 = var.common_lambda.aws_sns_topic_subscription.delivery_policy
    redrive_policy                  = var.common_lambda.aws_sns_topic_subscription.redrive_policy
  }
  kms_master_key_id = module.kms_key[each.key].key_id

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# For SES event notification (every monitor region)
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
# tfsec:ignore:aws-lambda-enable-tracing
module "aws_lambda_create_lambda_ses" {
  for_each = local.monitor_regions

  source  = "terraform-aws-modules/lambda/aws"
  version = "8.12.0"

  region = each.value

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "sns.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = "arn:aws:sns:${each.value}:${data.aws_caller_identity.current.account_id}:${var.name_prefix}${var.common_lambda.ses.aws_sns_topic.name}"
      statement_id        = "SESDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key[each.key].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.common_lambda_ses.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of SES to Slack."
  environment_variables = merge({
    LOGGER_FORMATTER            = "json"
    LOGGER_OUT                  = "stdout"
    LOGGER_LEVEL                = "warn"
    LOG_GROUP_RETENTION_IN_DAYS = coalesce(try(var.cloudwatch_log_group.override.common_lambda_ses.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.common_lambda_ses.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.common_lambda_ses.channel_id, null), var.slack.channel_id)
  }, var.common_lambda.ses.aws_lambda_function.environment)
  function_name                 = "${var.name_prefix}cloudwatch-alarm-ses-to-sns-to-slack"
  handler                       = "cloudwatch_alarm_to_sns_ses_to_slack"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/go_cloudwatch_alarm_to_sns_ses_to_slack.zip"
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 128
  publish                       = false
  runtime                       = "provided.al2023"
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc[each.key].default_security_group_id] : [var.common_lambda.vpc.exists[each.value].security_group_id] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc[each.key].private_subnets : var.common_lambda.vpc.exists[each.value].private_subnets : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc
  ]
}
