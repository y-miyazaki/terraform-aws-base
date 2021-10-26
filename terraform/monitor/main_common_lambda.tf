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
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeMetricFilters",
        "logs:FilterLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
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
  aws_sns_topic_lambda_metric = merge(var.common_lambda.metric.aws_sns_topic, {
    name = "${var.name_prefix}${lookup(var.common_lambda.metric.aws_sns_topic, "name")}"
    }
  )
  aws_sns_topic_lambda_log = merge(var.common_lambda.log.aws_sns_topic, {
    name = "${var.name_prefix}${lookup(var.common_lambda.log.aws_sns_topic, "name")}"
    }
  )
  aws_sns_topic_subscription_metric = merge(var.common_lambda.aws_sns_topic_subscription, {
    endpoint = module.aws_recipes_lambda_create_lambda_metric.arn
    }
  )
  aws_sns_topic_subscription_log = merge(var.common_lambda.aws_sns_topic_subscription, {
    endpoint = module.aws_recipes_lambda_create_lambda_log.arn
    }
  )
}
#--------------------------------------------------------------
# Create role and policy for Lambda
#--------------------------------------------------------------
module "aws_recipes_iam_role_lambda" {
  source = "../../modules/aws/recipes/iam/role/lambda"
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
module "aws_recipes_sns_subscription_lambda_metric" {
  source        = "../../modules/aws/recipes/sns/subscription"
  aws_kms_key   = local.aws_kms_key_lambda_metric
  aws_sns_topic = local.aws_sns_topic_lambda_metric
  aws_sns_topic_subscription = {
    protocol                        = lookup(var.common_lambda.aws_sns_topic_subscription, "protocol")
    endpoint                        = module.aws_recipes_lambda_create_lambda_log.arn
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
module "aws_recipes_lambda_create_lambda_metric" {
  source                   = "../../modules/aws/recipes/lambda/create"
  is_enabled               = lookup(var.common_lambda, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.common_lambda, "aws_cloudwatch_log_group_lambda")

  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "../../lambda/outputs/cloudwatch_alarm_to_sns_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-alarm-metric"
    dead_letter_config             = []
    handler                        = "cloudwatch_alarm_to_sns_to_slack"
    role                           = module.aws_recipes_iam_role_lambda.arn
    description                    = "This program sends the result of metrics to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "go1.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    vpc_config                     = []
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("../../lambda/outputs/cloudwatch_alarm_to_sns_to_slack.zip")
    environment                    = lookup(var.common_lambda.metric.aws_lambda_function, "environment")
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Event Rule, SNS or S3).
  tags = var.tags
}

#--------------------------------------------------------------
# Create Lambda Permission
# For Metrics
#--------------------------------------------------------------
module "aws_recipes_lambda_permission_lambda_metric" {
  source     = "../../modules/aws/recipes/lambda/permission"
  is_enabled = lookup(var.common_lambda, "is_enabled", true)
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    function_name       = module.aws_recipes_lambda_create_lambda_metric.function_name
    principal           = "sns.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = module.aws_recipes_sns_subscription_lambda_metric.arn
    statement_id        = "MetricDetectUnexpectedUsage"
    statement_id_prefix = null
  }
}
#--------------------------------------------------------------
# Provides a SNS
# For Log
#--------------------------------------------------------------
module "aws_recipes_sns_subscription_lambda_log" {
  source        = "../../modules/aws/recipes/sns/subscription"
  aws_kms_key   = local.aws_kms_key_lambda_log
  aws_sns_topic = local.aws_sns_topic_lambda_log
  aws_sns_topic_subscription = {
    protocol                        = lookup(var.common_lambda.aws_sns_topic_subscription, "protocol")
    endpoint                        = module.aws_recipes_lambda_create_lambda_log.arn
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
module "aws_recipes_lambda_create_lambda_log" {
  source                   = "../../modules/aws/recipes/lambda/create"
  is_enabled               = lookup(var.common_lambda, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.common_lambda, "aws_cloudwatch_log_group_lambda")

  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "../../lambda/outputs/cloudwatch_alarm_to_sns_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-alarm-log"
    dead_letter_config             = []
    handler                        = "cloudwatch_alarm_to_sns_to_slack"
    role                           = module.aws_recipes_iam_role_lambda.arn
    description                    = "This program sends the result of log to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "go1.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    vpc_config                     = []
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("../../lambda/outputs/cloudwatch_alarm_to_sns_to_slack.zip")
    environment                    = lookup(var.common_lambda.log.aws_lambda_function, "environment")
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Event Rule, SNS or S3).
  tags = var.tags
}
#--------------------------------------------------------------
# Create Lambda Permission
# For Log
#--------------------------------------------------------------
module "aws_recipes_lambda_permission_lambda_log" {
  source     = "../../modules/aws/recipes/lambda/permission"
  is_enabled = lookup(var.common_lambda, "is_enabled", true)
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    function_name       = module.aws_recipes_lambda_create_lambda_log.function_name
    principal           = "sns.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = module.aws_recipes_sns_subscription_lambda_log.arn
    statement_id        = "LogDetectUnexpectedUsage"
    statement_id_prefix = null
  }
}
