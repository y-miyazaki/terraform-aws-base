#--------------------------------------------------------------
# IAM role of Lambda for alarm monitoring
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_iam_policy_lambda = merge(var.common_lambda.aws_iam_policy, {
    name = "${var.name_prefix}${lookup(var.common_lambda.aws_iam_policy, "name")}"
    # Note: remove logs:CreateLogGroup from Action.
    # https://advancedweb.hu/how-to-manage-lambda-log-groups-with-terraform/
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudWatchLogs",
      "Action": [
        "logs:CreateLogGroup",
        "logs:DescribeLogStreams",
        "logs:PutRetentionPolicy",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeMetricFilters",
        "logs:FilterLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*"
    },
    {
      "Sid": "AllowS3FullAccess",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${module.s3_application_log.s3_bucket_arn}",
        "${module.s3_application_log.s3_bucket_arn}/*"
      ]
    },
    {
      "Sid": "AllowKinesisDataFirehoseCloudwatchLogsProcessor",
      "Action": [
        "firehose:PutRecordBatch"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:firehose:${var.region}:${data.aws_caller_identity.current.account_id}:deliverystream/*"
    },
    {
      "Sid": "AllowSupports",
      "Action": [
        "support:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
    }
  )
  aws_kms_key_lambda_metric = merge(var.common_lambda.metric.aws_kms_key, {
    description             = lookup(var.common_lambda.metric.aws_kms_key, "description", null)
    deletion_window_in_days = lookup(var.common_lambda.metric.aws_kms_key, "deletion_window_in_days", 7)
    is_enabled              = lookup(var.common_lambda.metric.aws_kms_key, "is_enabled")
    enable_key_rotation     = lookup(var.common_lambda.metric.aws_kms_key, "enable_key_rotation")
    alias_name              = "alias/${var.name_prefix}${lookup(var.common_lambda.metric.aws_kms_key, "alias_name")}"
    }
  )
  aws_kms_key_lambda_log = merge(var.common_lambda.log.aws_kms_key, {
    description             = lookup(var.common_lambda.log.aws_kms_key, "description", null)
    deletion_window_in_days = lookup(var.common_lambda.log.aws_kms_key, "deletion_window_in_days", 7)
    is_enabled              = lookup(var.common_lambda.log.aws_kms_key, "is_enabled")
    enable_key_rotation     = lookup(var.common_lambda.log.aws_kms_key, "enable_key_rotation")
    alias_name              = "alias/${var.name_prefix}${lookup(var.common_lambda.log.aws_kms_key, "alias_name")}"
    }
  )
  aws_kms_key_lambda_ses = merge(var.common_lambda.ses.aws_kms_key, {
    description             = lookup(var.common_lambda.ses.aws_kms_key, "description", null)
    deletion_window_in_days = lookup(var.common_lambda.ses.aws_kms_key, "deletion_window_in_days", 7)
    is_enabled              = lookup(var.common_lambda.ses.aws_kms_key, "is_enabled")
    enable_key_rotation     = lookup(var.common_lambda.ses.aws_kms_key, "enable_key_rotation")
    alias_name              = "alias/${var.name_prefix}${lookup(var.common_lambda.ses.aws_kms_key, "alias_name")}"
    }
  )
}

#--------------------------------------------------------------
# Create role and policy for Lambda
#--------------------------------------------------------------
module "aws_iam_role_lambda" {
  source = "../../modules/aws/iam/role/lambda"
  is_vpc = var.common_lambda.vpc.is_enabled
  aws_iam_role = merge(var.common_lambda.aws_iam_role, {
    name = "${var.name_prefix}${lookup(var.common_lambda.aws_iam_role, "name")}"
    }
  )
  aws_iam_policy = local.aws_iam_policy_lambda
  tags           = var.tags
}

#--------------------------------------------------------------
# Provides a SNS
# For Metric
#--------------------------------------------------------------
module "aws_sns_subscription_lambda_metric" {
  source      = "../../modules/aws/sns/subscription"
  aws_kms_key = local.aws_kms_key_lambda_metric
  aws_sns_topic = merge(var.common_lambda.metric.aws_sns_topic, {
    name = "${var.name_prefix}${lookup(var.common_lambda.metric.aws_sns_topic, "name")}"
    }
  )
  aws_sns_topic_subscription = {
    protocol                        = lookup(var.common_lambda.aws_sns_topic_subscription, "protocol")
    endpoint                        = module.aws_lambda_create_lambda_metric.arn
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
# For Metric
#--------------------------------------------------------------
module "aws_lambda_create_lambda_metric" {
  source                   = "../../modules/aws/lambda/create"
  is_enabled               = lookup(var.common_lambda, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.common_lambda, "aws_cloudwatch_log_group_lambda")

  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "../../lambda/outputs/go_cloudwatch_alarm_to_sns_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-alarm-metric"
    dead_letter_config             = []
    handler                        = "cloudwatch_alarm_to_sns_to_slack"
    architectures                  = ["arm64"]
    role                           = module.aws_iam_role_lambda.arn
    description                    = "This program sends the result of metrics to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "provided.al2"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("../../lambda/outputs/go_cloudwatch_alarm_to_sns_to_slack.zip")
    environment                    = lookup(var.common_lambda.metric.aws_lambda_function, "environment")
    vpc_config = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [
      {
        subnet_ids         = module.lambda_vpc.private_subnets
        security_group_ids = [module.lambda_vpc.default_security_group_id]
      }
      ] : [
      {
        subnet_ids         = var.common_lambda.vpc.exists.private_subnets
        security_group_ids = [var.common_lambda.vpc.exists.security_group_id]
      }
    ] : []
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Events Rule, SNS or S3).
  tags = var.tags
  depends_on = [
    module.lambda_vpc
  ]
}

#--------------------------------------------------------------
# Create Lambda Permission
# For Metrics
#--------------------------------------------------------------
module "aws_lambda_permission_lambda_metric" {
  source     = "../../modules/aws/lambda/permission"
  is_enabled = lookup(var.common_lambda, "is_enabled", true)
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    function_name       = module.aws_lambda_create_lambda_metric.function_name
    principal           = "sns.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = module.aws_sns_subscription_lambda_metric.arn
    statement_id        = "MetricDetectUnexpectedUsage"
    statement_id_prefix = null
  }
}
#--------------------------------------------------------------
# Provides a SNS
# For Log
#--------------------------------------------------------------
module "aws_sns_subscription_lambda_log" {
  source      = "../../modules/aws/sns/subscription"
  aws_kms_key = local.aws_kms_key_lambda_log
  aws_sns_topic = merge(var.common_lambda.log.aws_sns_topic, {
    name = "${var.name_prefix}${lookup(var.common_lambda.log.aws_sns_topic, "name")}"
    }
  )
  aws_sns_topic_subscription = {
    protocol                        = lookup(var.common_lambda.aws_sns_topic_subscription, "protocol")
    endpoint                        = module.aws_lambda_create_lambda_log.arn
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
# For Log
#--------------------------------------------------------------
module "aws_lambda_create_lambda_log" {
  source                   = "../../modules/aws/lambda/create"
  is_enabled               = lookup(var.common_lambda, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.common_lambda, "aws_cloudwatch_log_group_lambda")

  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "../../lambda/outputs/go_cloudwatch_alarm_to_sns_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-alarm-log"
    dead_letter_config             = []
    handler                        = "cloudwatch_alarm_to_sns_to_slack"
    architectures                  = ["arm64"]
    role                           = module.aws_iam_role_lambda.arn
    description                    = "This program sends the result of log to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "provided.al2"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("../../lambda/outputs/go_cloudwatch_alarm_to_sns_to_slack.zip")
    environment                    = lookup(var.common_lambda.log.aws_lambda_function, "environment")
    vpc_config = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [
      {
        subnet_ids         = module.lambda_vpc.private_subnets
        security_group_ids = [module.lambda_vpc.default_security_group_id]
      }
      ] : [
      {
        subnet_ids         = var.common_lambda.vpc.exists.private_subnets
        security_group_ids = [var.common_lambda.vpc.exists.security_group_id]
      }
    ] : []
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Events Rule, SNS or S3).
  tags = var.tags
  depends_on = [
    module.lambda_vpc
  ]
}
#--------------------------------------------------------------
# Create Lambda Permission
# For Log
#--------------------------------------------------------------
module "aws_lambda_permission_lambda_log" {
  source     = "../../modules/aws/lambda/permission"
  is_enabled = lookup(var.common_lambda, "is_enabled", true)
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    function_name       = module.aws_lambda_create_lambda_log.function_name
    principal           = "sns.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = module.aws_sns_subscription_lambda_log.arn
    statement_id        = "LogDetectUnexpectedUsage"
    statement_id_prefix = null
  }
}
#--------------------------------------------------------------
# Provides a SNS
# For SES
#--------------------------------------------------------------
module "aws_sns_subscription_lambda_ses" {
  source      = "../../modules/aws/sns/subscription"
  aws_kms_key = local.aws_kms_key_lambda_ses
  aws_sns_topic = merge(var.common_lambda.ses.aws_sns_topic, tomap({
    name   = "${var.name_prefix}${lookup(var.common_lambda.ses.aws_sns_topic, "name")}",
    policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "SESAllow",
      "Effect": "Allow",
      "Principal": {
        "Service": "ses.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${var.name_prefix}${lookup(var.common_lambda.ses.aws_sns_topic, "name")}",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        },
        "StringLike": {
          "AWS:SourceArn": "arn:aws:ses:*"
        }
      }
    }
  ]
}
POLICY
    })
  )
  aws_sns_topic_subscription = {
    protocol                        = lookup(var.common_lambda.aws_sns_topic_subscription, "protocol")
    endpoint                        = module.aws_lambda_create_lambda_ses.arn
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
# For SES
#--------------------------------------------------------------
module "aws_lambda_create_lambda_ses" {
  source                   = "../../modules/aws/lambda/create"
  is_enabled               = lookup(var.common_lambda, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.common_lambda, "aws_cloudwatch_log_group_lambda")

  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "../../lambda/outputs/go_cloudwatch_alarm_to_sns_ses_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-alarm-ses"
    dead_letter_config             = []
    handler                        = "cloudwatch_alarm_to_sns_ses_to_slack"
    architectures                  = ["arm64"]
    role                           = module.aws_iam_role_lambda.arn
    description                    = "This program sends the result of SES to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "provided.al2"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("../../lambda/outputs/go_cloudwatch_alarm_to_sns_ses_to_slack.zip")
    environment                    = lookup(var.common_lambda.ses.aws_lambda_function, "environment")
    vpc_config = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [
      {
        subnet_ids         = module.lambda_vpc.private_subnets
        security_group_ids = [module.lambda_vpc.default_security_group_id]
      }
      ] : [
      {
        subnet_ids         = var.common_lambda.vpc.exists.private_subnets
        security_group_ids = [var.common_lambda.vpc.exists.security_group_id]
      }
    ] : []
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Events Rule, SNS or S3).
  tags = var.tags
  depends_on = [
    module.lambda_vpc
  ]
}
#--------------------------------------------------------------
# Create Lambda Permission
# For SES
#--------------------------------------------------------------
module "aws_lambda_permission_lambda_ses" {
  source     = "../../modules/aws/lambda/permission"
  is_enabled = lookup(var.common_lambda, "is_enabled", true)
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    function_name       = module.aws_lambda_create_lambda_ses.function_name
    principal           = "sns.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = module.aws_sns_subscription_lambda_ses.arn
    statement_id        = "SESDetectUnexpectedUsage"
    statement_id_prefix = null
  }
}

#--------------------------------------------------------------
# Create Lambda function
# For Kinesis Data Firehose Cloudwatch Logs Processor
#--------------------------------------------------------------
module "aws_lambda_create_lambda_kinesis_data_firehose_cloudwatch_logs_processor" {
  source                   = "../../modules/aws/lambda/create"
  is_enabled               = lookup(var.common_lambda, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.common_lambda, "aws_cloudwatch_log_group_lambda")
  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    # cd /workspace/nodejs/kinesis_data_firehose_cloudwatch_logs_processor; zip /workspace/lambda/outputs/nodejs_kinesis_data_firehose_cloudwatch_logs_processor.zip index.mjs
    filename                       = "../../lambda/outputs/nodejs_kinesis_data_firehose_cloudwatch_logs_processor.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}kinesis-data-firehose-cloudwatch-logs-processor"
    dead_letter_config             = []
    handler                        = "index.handler"
    architectures                  = ["arm64"]
    role                           = module.aws_iam_role_lambda.arn
    description                    = "An Amazon Kinesis Firehose stream processor that extracts individual log events from records sent by Cloudwatch Logs subscription filters."
    layers                         = []
    memory_size                    = 256
    runtime                        = "nodejs18.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("../../lambda/outputs/nodejs_kinesis_data_firehose_cloudwatch_logs_processor.zip")
    environment                    = lookup(var.common_lambda.metric.aws_lambda_function, "environment")
    vpc_config = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [
      {
        subnet_ids         = module.lambda_vpc.private_subnets
        security_group_ids = [module.lambda_vpc.default_security_group_id]
      }
      ] : [
      {
        subnet_ids         = var.common_lambda.vpc.exists.private_subnets
        security_group_ids = [var.common_lambda.vpc.exists.security_group_id]
      }
    ] : []
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Events Rule, SNS or S3).
  tags = var.tags
  depends_on = [
    module.lambda_vpc
  ]
}
#--------------------------------------------------------------
# Create Lambda Permission
# For Kinesis Data Firehose Cloudwatch Logs Processor
#--------------------------------------------------------------
module "aws_lambda_permission_lambda_kinesis_data_firehose_cloudwatch_logs_processor" {
  source     = "../../modules/aws/lambda/permission"
  is_enabled = lookup(var.common_lambda, "is_enabled", true)
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    function_name       = module.aws_lambda_create_lambda_kinesis_data_firehose_cloudwatch_logs_processor.function_name
    principal           = "lambda.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = null
    statement_id        = "KinesisDataFirehoseCloudwatchLogsProcessorDetectUnexpectedUsage"
    statement_id_prefix = null
  }
}

#--------------------------------------------------------------
# Create Lambda function
# For CloudFront Logs moves object key.
#--------------------------------------------------------------
module "aws_lambda_create_lambda_s3_notification_s3_object_created_for_athena" {
  source                   = "../../modules/aws/lambda/create"
  is_enabled               = lookup(var.common_lambda, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.common_lambda, "aws_cloudwatch_log_group_lambda")

  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    # cd /workspace/nodejs/s3_notification_s3_object_created_for_athena; zip /workspace/lambda/outputs/nodejs_s3_notification_s3_object_created_for_athena.zip index.mjs
    filename                       = "../../lambda/outputs/nodejs_s3_notification_s3_object_created_for_athena.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}s3-notification-s3-object-created-for-athena"
    dead_letter_config             = []
    handler                        = "index.handler"
    architectures                  = ["arm64"]
    role                           = module.aws_iam_role_lambda.arn
    description                    = "This program moves s3 object(CloudFront) for Athena."
    layers                         = []
    memory_size                    = 128
    runtime                        = "nodejs20.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("../../lambda/outputs/nodejs_s3_notification_s3_object_created_for_athena.zip")
    environment = {
      TARGET_KEY_PREFIX = "Logs/CloudFront/"
    }
    vpc_config = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [
      {
        subnet_ids         = module.lambda_vpc.private_subnets
        security_group_ids = [module.lambda_vpc.default_security_group_id]
      }
      ] : [
      {
        subnet_ids         = var.common_lambda.vpc.exists.private_subnets
        security_group_ids = [var.common_lambda.vpc.exists.security_group_id]
      }
    ] : []
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Events Rule, SNS or S3).
  tags = var.tags
  depends_on = [
    module.lambda_vpc
  ]
}

#--------------------------------------------------------------
# Create Lambda Permission
# For S3 notification
#--------------------------------------------------------------
module "aws_lambda_permission_lambda_s3_notification_s3_object_created_for_athena" {
  source     = "../../modules/aws/lambda/permission"
  is_enabled = lookup(var.common_lambda, "is_enabled", true)
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    function_name       = module.aws_lambda_create_lambda_s3_notification_s3_object_created_for_athena.function_name
    principal           = "lambda.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = null
    statement_id        = "S3NotificationS3ObjectCreatedForAthenaProcessorDetectUnexpectedUsage"
    statement_id_prefix = null
  }
}
