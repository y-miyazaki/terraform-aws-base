#--------------------------------------------------------------
# Provides a SNS
# For Metric
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
module "aws_sns_subscription_lambda_metric_us_east_1" {
  count = local.is_enabled_us_east_1 ? 1 : 0

  source = "../../modules/aws/sns/subscription"
  providers = {
    aws = aws.us-east-1
  }

  aws_sns_topic = merge(var.common_lambda.metric.aws_sns_topic, {
    name = "${var.name_prefix}${var.common_lambda.metric.aws_sns_topic.name}"
    }
  )
  aws_sns_topic_subscription = {
    protocol                        = var.common_lambda.aws_sns_topic_subscription.protocol
    endpoint                        = module.aws_lambda_create_lambda_metric_us_east_1.lambda_function_arn
    endpoint_auto_confirms          = var.common_lambda.aws_sns_topic_subscription.endpoint_auto_confirms
    confirmation_timeout_in_minutes = var.common_lambda.aws_sns_topic_subscription.confirmation_timeout_in_minutes
    raw_message_delivery            = var.common_lambda.aws_sns_topic_subscription.raw_message_delivery
    filter_policy                   = var.common_lambda.aws_sns_topic_subscription.filter_policy
    delivery_policy                 = var.common_lambda.aws_sns_topic_subscription.delivery_policy
    redrive_policy                  = var.common_lambda.aws_sns_topic_subscription.redrive_policy
  }
  kms_master_key_id = module.kms_key_us_east_1["monitor"].key_id

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# For Metric
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
module "aws_lambda_create_lambda_metric_us_east_1" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"
  create  = local.is_enabled_us_east_1
  providers = {
    aws = aws.us-east-1
  }

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "sns.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_sns_subscription_lambda_metric_us_east_1[0].arn
      statement_id        = "MetricDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key_us_east_1["monitor"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.common_lambda_metric.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of metric to Slack."
  environment_variables = merge({
    LOGGER_FORMATTER    = "json"
    LOGGER_OUT          = "stdout"
    LOGGER_LEVEL        = "warn"
    DYNAMODB_TABLE_NAME = module.dynamodb_table_monitor_log_us_east_1.dynamodb_table_id
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.common_lambda_metric.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.common_lambda_metric.channel_id, null), var.slack.channel_id)
  }, var.common_lambda.metric.aws_lambda_function.environment)
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
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc_us_east_1.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id_us_east_1] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc_us_east_1.private_subnets : var.common_lambda.vpc.exists.private_subnets_us_east_1 : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc_us_east_1
  ]
}

#--------------------------------------------------------------
# Provides a SNS
# For Log
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
module "aws_sns_subscription_lambda_log_us_east_1" {
  count = local.is_enabled_us_east_1 ? 1 : 0

  source = "../../modules/aws/sns/subscription"
  providers = {
    aws = aws.us-east-1
  }

  aws_sns_topic = merge(var.common_lambda.log.aws_sns_topic, {
    name = "${var.name_prefix}${var.common_lambda.log.aws_sns_topic.name}"
    }
  )
  aws_sns_topic_subscription = {
    protocol                        = var.common_lambda.aws_sns_topic_subscription.protocol
    endpoint                        = module.aws_lambda_create_lambda_log_us_east_1.lambda_function_arn
    endpoint_auto_confirms          = var.common_lambda.aws_sns_topic_subscription.endpoint_auto_confirms
    confirmation_timeout_in_minutes = var.common_lambda.aws_sns_topic_subscription.confirmation_timeout_in_minutes
    raw_message_delivery            = var.common_lambda.aws_sns_topic_subscription.raw_message_delivery
    filter_policy                   = var.common_lambda.aws_sns_topic_subscription.filter_policy
    delivery_policy                 = var.common_lambda.aws_sns_topic_subscription.delivery_policy
    redrive_policy                  = var.common_lambda.aws_sns_topic_subscription.redrive_policy
  }
  kms_master_key_id = module.kms_key_us_east_1["monitor"].key_id

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# For Log
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
module "aws_lambda_create_lambda_log_us_east_1" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"
  create  = local.is_enabled_us_east_1
  providers = {
    aws = aws.us-east-1
  }

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "sns.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_sns_subscription_lambda_log_us_east_1[0].arn
      statement_id        = "LogDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key_us_east_1["monitor"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.common_lambda_log.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of log to Slack."
  environment_variables = {
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.common_lambda_log.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.common_lambda_log.channel_id, null), var.slack.channel_id)
  }
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
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc_us_east_1.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id_us_east_1] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc_us_east_1.private_subnets : var.common_lambda.vpc.exists.private_subnets_us_east_1 : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc_us_east_1
  ]
}

#--------------------------------------------------------------
# Provides a SNS
# For SES
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
module "aws_sns_subscription_lambda_ses_us_east_1" {
  count = local.is_enabled_us_east_1 ? 1 : 0

  source = "../../modules/aws/sns/subscription"
  providers = {
    aws = aws.us-east-1
  }

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
            "arn:aws:sns:us-east-1:${data.aws_caller_identity.current.account_id}:${var.name_prefix}${var.common_lambda.ses.aws_sns_topic.name}",
          ]
          Condition = {
            StringEquals = {
              "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
            }
            StringLike = {
              "AWS:SourceArn" = "arn:aws:ses:*"
            }
          }
        }
      ]
    })
    })
  )
  aws_sns_topic_subscription = {
    protocol                        = var.common_lambda.aws_sns_topic_subscription.protocol
    endpoint                        = module.aws_lambda_create_lambda_ses_us_east_1.lambda_function_arn
    endpoint_auto_confirms          = var.common_lambda.aws_sns_topic_subscription.endpoint_auto_confirms
    confirmation_timeout_in_minutes = var.common_lambda.aws_sns_topic_subscription.confirmation_timeout_in_minutes
    raw_message_delivery            = var.common_lambda.aws_sns_topic_subscription.raw_message_delivery
    filter_policy                   = var.common_lambda.aws_sns_topic_subscription.filter_policy
    delivery_policy                 = var.common_lambda.aws_sns_topic_subscription.delivery_policy
    redrive_policy                  = var.common_lambda.aws_sns_topic_subscription.redrive_policy
  }
  kms_master_key_id = module.kms_key_us_east_1["monitor"].key_id

  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
# For SES
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
module "aws_lambda_create_lambda_ses_us_east_1" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"
  create  = local.is_enabled_us_east_1
  providers = {
    aws = aws.us-east-1
  }

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "sns.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = module.aws_sns_subscription_lambda_ses_us_east_1[0].arn
      statement_id        = "SESDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key_us_east_1["monitor"].key_arn
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
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc_us_east_1.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id_us_east_1] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc_us_east_1.private_subnets : var.common_lambda.vpc.exists.private_subnets_us_east_1 : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc_us_east_1
  ]
}

#--------------------------------------------------------------
# Create Lambda function
# For Kinesis Data Firehose Cloudwatch Logs Processor
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
module "aws_lambda_create_lambda_kinesis_data_firehose_cloudwatch_logs_processor_us_east_1" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"
  create  = local.is_enabled_us_east_1
  providers = {
    aws = aws.us-east-1
  }

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "lambda.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = null
      statement_id        = "KinesisDataFirehoseCloudwatchLogsProcessorDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key_us_east_1["monitor"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.common_lambda_kinesis_data_firehose_cloudwatch_logs_processor.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "An Amazon Kinesis Firehose stream processor that extracts individual log events from records sent by Cloudwatch Logs subscription filters."
  environment_variables = merge({
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = coalesce(try(var.slack.override.common_lambda_kinesis_data_firehose_cloudwatch_logs_processor.oauth_access_token, null), var.slack.oauth_access_token)
    SLACK_CHANNEL_ID         = coalesce(try(var.slack.override.common_lambda_kinesis_data_firehose_cloudwatch_logs_processor.channel_id, null), var.slack.channel_id)
  }, var.common_lambda.metric.aws_lambda_function.environment)
  function_name                 = "${var.name_prefix}kinesis-data-firehose-cloudwatch-logs-processor"
  handler                       = "index.handler"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/nodejs_kinesis_data_firehose_cloudwatch_logs_processor.zip"
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 256
  publish                       = false
  runtime                       = "nodejs22.x"
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc_us_east_1.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id_us_east_1] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc_us_east_1.private_subnets : var.common_lambda.vpc.exists.private_subnets_us_east_1 : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc_us_east_1
  ]
}

#--------------------------------------------------------------
# Create Lambda function
# For CloudFront Logs moves object key.
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
module "aws_lambda_create_lambda_s3_notification_s3_object_created_for_athena_us_east_1" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"
  providers = {
    aws = aws.us-east-1
  }
  create = local.is_enabled_us_east_1

  allowed_triggers = {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "lambda.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = null
      statement_id        = "S3NotificationS3ObjectCreatedForAthenaProcessorDetection"
      statement_id_prefix = null
    }
  }
  architectures                           = ["arm64"]
  attach_network_policy                   = var.common_lambda.vpc.is_enabled
  cloudwatch_logs_kms_key_id              = module.kms_key_us_east_1["monitor"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.common_lambda_s3_notification_s3_object_created_for_athena.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program moves s3 object(CloudFront) for Athena."
  environment_variables = {
    TARGET_KEY_PREFIX = "Logs/CloudFront/"
  }
  function_name                 = "${var.name_prefix}s3-notification-s3-object-created-for-athena"
  handler                       = "index.handler"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  local_existing_package        = "../../lambda/outputs/nodejs_s3_notification_s3_object_created_for_athena.zip"
  logging_application_log_level = "INFO"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 128
  publish                       = false
  runtime                       = "nodejs22.x"
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc_us_east_1.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id_us_east_1] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc_us_east_1.private_subnets : var.common_lambda.vpc.exists.private_subnets_us_east_1 : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc_us_east_1
  ]
}
