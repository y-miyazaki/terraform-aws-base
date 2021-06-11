#--------------------------------------------------------------
# For Application Log
#--------------------------------------------------------------
locals {
  aws_kms_key_application_log = merge(var.metric_application_log.aws_kms_key, {
    alias_name = "alias/${var.name_prefix}${lookup(var.metric_application_log.aws_kms_key, "alias_name")}"
    }
  )
  aws_sns_topic_application_log = merge(var.metric_application_log.aws_sns_topic, {
    name = "${var.name_prefix}${lookup(var.metric_application_log.aws_sns_topic, "name")}"
    }
  )
  aws_sns_topic_subscription_application_log = merge(var.metric_application_log.aws_sns_topic_subscription, {
    endpoint = module.aws_recipes_lambda_create_application_log.arn
    }
  )
  aws_cloudwatch_log_metric_filter_application_log = flatten([
    for r in var.metric_application_log.log_group_name : {
      name           = "${var.name_prefix}${lookup(var.metric_application_log.aws_cloudwatch_log_metric_filter, "name")}-${replace(replace(r, "/", "-"), "/^-/", "")}"
      pattern        = lookup(var.metric_application_log.aws_cloudwatch_log_metric_filter, "pattern")
      log_group_name = r
      metric_transformation = [
        {
          name      = "${var.name_prefix}${lookup(var.metric_application_log.aws_cloudwatch_log_metric_filter, "name")}-${replace(replace(r, "/", "-"), "/^-/", "")}"
          namespace = lookup(var.metric_application_log.aws_cloudwatch_log_metric_filter.metric_transformation[0], "namespace")
          value     = lookup(var.metric_application_log.aws_cloudwatch_log_metric_filter.metric_transformation[0], "value")
        }
      ]
    }
  ])
  aws_cloudwatch_metric_alarm_application_log = flatten([
    for r in var.metric_application_log.log_group_name : {
      alarm_name                            = "${var.name_prefix}${lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "alarm_name")}-${replace(replace(r, "/", "-"), "/^-/", "")}"
      comparison_operator                   = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "comparison_operator")
      evaluation_periods                    = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "evaluation_periods")
      metric_name                           = "${var.name_prefix}${lookup(var.metric_application_log.aws_cloudwatch_log_metric_filter, "name")}-${replace(replace(r, "/", "-"), "/^-/", "")}"
      namespace                             = lookup(var.metric_application_log.aws_cloudwatch_log_metric_filter.metric_transformation[0], "namespace")
      period                                = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "period")
      statistic                             = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "statistic")
      threshold                             = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "threshold", null)
      threshold_metric_id                   = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "threshold_metric_id", null)
      actions_enabled                       = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "actions_enabled")
      alarm_description                     = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "alarm_description")
      datapoints_to_alarm                   = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "datapoints_to_alarm", null)
      dimensions                            = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "dimensions", null)
      insufficient_data_actions             = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "insufficient_data_actions", null)
      ok_actions                            = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "ok_actions", null)
      unit                                  = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "unit", null)
      extended_statistic                    = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "extended_statistic", null)
      treat_missing_data                    = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "treat_missing_data", null)
      evaluate_low_sample_count_percentiles = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "evaluate_low_sample_count_percentiles", null)
      metric_query                          = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "metric_query", [])
      extended_statistic                    = lookup(var.metric_application_log.aws_cloudwatch_metric_alarm, "extended_statistic", null)
      alarm_actions                         = var.metric_application_log.is_enabled ? [module.aws_recipes_sns_subscription_application_log[0].arn] : null
    }
  ])
  aws_cloudwatch_log_subscription_filter_application_log = flatten([
    for k, r in var.metric_application_log.log_group_name : {
      name            = "${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}"
      destination_arn = lookup(module.aws_recipes_kinesis_firehose_s3_application_log[0].aws_kinesis_firehose_delivery_stream_arn, "${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}", null)
      filter_pattern  = ""
      log_group_name  = r
      distribution    = "Random"
    }
  ])
  aws_kinesis_firehose_delivery_stream_application_log = flatten([
    for r in var.metric_application_log.log_group_name : {
      name                   = "${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}"
      server_side_encryption = []
      extended_s3_configuration = [
        {
          bucket_arn         = module.aws_recipes_s3_bucket_log_logging.arn
          buffer_size        = lookup(var.metric_application_log.aws_kinesis_firehose_delivery_stream, "buffer_size", 5)
          buffer_interval    = lookup(var.metric_application_log.aws_kinesis_firehose_delivery_stream, "buffer_interval", 60)
          prefix             = lookup(var.metric_application_log.aws_kinesis_firehose_delivery_stream, "prefix", "/Application")
          compression_format = lookup(var.metric_application_log.aws_kinesis_firehose_delivery_stream, "compression_format", "GZIP")
          cloudwatch_logging_options = lookup(var.metric_application_log.aws_kinesis_firehose_delivery_stream, "cloudwatch_logging_options", [
            {
              enabled = false
            }
          ])
        }
      ]
    }
  ])
  aws_iam_role_kinesis_firehose_application_log = merge(var.metric_application_log.aws_iam_role_kinesis_firehose, {
    name = "${var.name_prefix}${lookup(var.metric_application_log.aws_iam_role_kinesis_firehose, "name")}"
    }
  )
  aws_iam_policy_kinesis_firehose_application_log = merge(var.metric_application_log.aws_iam_policy_kinesis_firehose, {
    name = "${var.name_prefix}${lookup(var.metric_application_log.aws_iam_policy_kinesis_firehose, "name")}"
    }
  )
  aws_iam_role_cloudwatch_logs_application_log = merge(var.metric_application_log.aws_iam_role_cloudwatch_logs, {
    name = "${var.name_prefix}${lookup(var.metric_application_log.aws_iam_role_cloudwatch_logs, "name")}"
    }
  )
  aws_iam_policy_cloudwatch_logs_application_log = merge(var.metric_application_log.aws_iam_policy_cloudwatch_logs, {
    name = "${var.name_prefix}${lookup(var.metric_application_log.aws_iam_policy_cloudwatch_logs, "name")}"
    }
  )
}

#--------------------------------------------------------------
# Provides a SNS for application logs.
#--------------------------------------------------------------
module "aws_recipes_sns_subscription_application_log" {
  count                      = var.metric_application_log.is_enabled ? 1 : 0
  source                     = "../../modules/aws/recipes/sns/subscription"
  aws_kms_key                = local.aws_kms_key_application_log
  aws_sns_topic              = local.aws_sns_topic_application_log
  aws_sns_topic_subscription = local.aws_sns_topic_subscription_application_log
  account_id                 = data.aws_caller_identity.current.account_id
  region                     = var.region
  user                       = var.deploy_user
  tags                       = var.tags
}
#--------------------------------------------------------------
# Provides a Kinesis Firehose Delivery Stream resource. Amazon Kinesis Firehose is a fully managed, elastic service to easily deliver real-time data streams to destinations such as Amazon S3 and Amazon Redshift.
#--------------------------------------------------------------
module "aws_recipes_kinesis_firehose_s3_application_log" {
  count                                = lookup(var.metric_application_log, "is_enabled", true) ? 1 : 0
  source                               = "../../modules/aws/recipes/kinesis/firehose/s3"
  aws_kinesis_firehose_delivery_stream = local.aws_kinesis_firehose_delivery_stream_application_log
  aws_iam_role                         = local.aws_iam_role_kinesis_firehose_application_log
  aws_iam_policy                       = local.aws_iam_policy_kinesis_firehose_application_log
  tags                                 = var.tags
}

#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter And Alarm resource.
#--------------------------------------------------------------
module "aws_recipes_cloudwatch_alarm_application_log" {
  count                            = lookup(var.metric_application_log, "is_enabled", true) ? 1 : 0
  source                           = "../../modules/aws/recipes/cloudwatch/alarm/log"
  aws_cloudwatch_log_metric_filter = local.aws_cloudwatch_log_metric_filter_application_log
  aws_cloudwatch_metric_alarm      = local.aws_cloudwatch_metric_alarm_application_log
  tags                             = var.tags
}
#--------------------------------------------------------------
# Provides a CloudWatch Logs subscription filter resource.
#--------------------------------------------------------------
module "aws_recipes_cloudwatch_subscription_application_log" {
  count                                  = lookup(var.metric_application_log, "is_enabled", true) ? 1 : 0
  source                                 = "../../modules/aws/recipes/cloudwatch/subscription"
  aws_cloudwatch_log_subscription_filter = local.aws_cloudwatch_log_subscription_filter_application_log
  aws_iam_role                           = local.aws_iam_role_cloudwatch_logs_application_log
  aws_iam_policy                         = local.aws_iam_policy_cloudwatch_logs_application_log
  account_id                             = data.aws_caller_identity.current.account_id
  region                                 = var.region
  tags                                   = var.tags
}

#--------------------------------------------------------------
# Create Lambda function
#--------------------------------------------------------------
module "aws_recipes_lambda_create_application_log" {
  source                   = "../../modules/aws/recipes/lambda/create"
  is_enabled               = lookup(var.metric_application_log, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.metric_application_log, "aws_cloudwatch_log_group_lambda")

  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "../../lambda/outputs/cloudwatch_alarm_to_sns_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-alarm-application-log"
    dead_letter_config             = []
    handler                        = "cloudwatch_alarm_to_sns_to_slack"
    role                           = module.aws_recipes_iam_lambda.arn
    description                    = "This program sends the result of application log to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "go1.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    vpc_config                     = []
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("../../lambda/outputs/cloudwatch_alarm_to_sns_to_slack.zip")
    environment                    = lookup(var.metric_application_log.aws_lambda_function, "environment")
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Event Rule, SNS or S3).
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    principal           = "sns.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = var.metric_application_log.is_enabled ? module.aws_recipes_sns_subscription_application_log[0].arn : null
    statement_id        = "ApplicationLogDetectUnexpectedUsage"
    statement_id_prefix = null
  }
  tags = var.tags
}
