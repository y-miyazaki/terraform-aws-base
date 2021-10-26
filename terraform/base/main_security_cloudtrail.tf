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
      is_enabled              = lookup(var.security_cloudtrail.aws_kms_key.cloudtrail, "is_enabled")
      enable_key_rotation     = lookup(var.security_cloudtrail.aws_kms_key.cloudtrail, "enable_key_rotation")
      alias_name              = "alias/${var.name_prefix}${lookup(var.security_cloudtrail.aws_kms_key.cloudtrail, "alias_name")}"
    }
    sns = {
      description             = lookup(var.security_cloudtrail.aws_kms_key.sns, "description", null)
      deletion_window_in_days = lookup(var.security_cloudtrail.aws_kms_key.sns, "deletion_window_in_days", 7)
      is_enabled              = lookup(var.security_cloudtrail.aws_kms_key.sns, "is_enabled")
      enable_key_rotation     = lookup(var.security_cloudtrail.aws_kms_key.sns, "enable_key_rotation")
      alias_name              = "alias/${var.name_prefix}${lookup(var.security_cloudtrail.aws_kms_key.sns, "alias_name")}"
    }
    }
  )
  aws_cloudwatch_log_metric_filter_cloudtrail = flatten([
    for r in var.security_cloudtrail.aws_cloudwatch_log_metric_filter : {
      name           = "${var.name_prefix}${lookup(r, "name")}"
      pattern        = lookup(r, "pattern", null)
      log_group_name = module.aws_recipes_security_cloudtrail.log_group_name
      metric_transformation = [
        {
          name      = "${var.name_prefix}${lookup(r.metric_transformation[0], "name", null)}"
          namespace = lookup(r.metric_transformation[0], "namespace", null)
          value     = lookup(r.metric_transformation[0], "value", null)
        }
      ]
    }
  ])
  aws_cloudwatch_metric_alarm_cloudtrail = flatten([
    for k, r in var.security_cloudtrail.aws_cloudwatch_metric_alarm : {
      alarm_name                            = "${var.name_prefix}${lookup(r, "alarm_name")}"
      comparison_operator                   = lookup(r, "comparison_operator", null)
      evaluation_periods                    = lookup(r, "evaluation_periods", null)
      metric_name                           = "${var.name_prefix}${lookup(var.security_cloudtrail.aws_cloudwatch_log_metric_filter[k].metric_transformation[0], "name")}"
      namespace                             = lookup(var.security_cloudtrail.aws_cloudwatch_log_metric_filter[k].metric_transformation[0], "namespace")
      period                                = lookup(r, "period", null)
      statistic                             = lookup(r, "statistic", null)
      threshold                             = lookup(r, "threshold", null)
      threshold_metric_id                   = lookup(r, "threshold_metric_id", null)
      actions_enabled                       = lookup(r, "actions_enabled", null)
      alarm_description                     = lookup(r, "alarm_description", null)
      datapoints_to_alarm                   = lookup(r, "datapoints_to_alarm", null)
      dimensions                            = lookup(r, "dimensions", null)
      insufficient_data_actions             = lookup(r, "insufficient_data_actions", null)
      ok_actions                            = lookup(r, "ok_actions", null)
      unit                                  = lookup(r, "unit", null)
      extended_statistic                    = lookup(r, "extended_statistic", null)
      treat_missing_data                    = lookup(r, "treat_missing_data", null)
      evaluate_low_sample_count_percentiles = lookup(r, "evaluate_low_sample_count_percentiles", null)
      metric_query                          = lookup(r, "metric_query", [])
      extended_statistic                    = lookup(r, "extended_statistic", null)
      alarm_actions                         = [module.aws_recipes_security_cloudtrail.sns_topic_arn]
    }
  ])
  aws_sns_topic_cloudtrail = merge(var.security_cloudtrail.aws_sns_topic, {
    name = "${var.name_prefix}${lookup(var.security_cloudtrail.aws_sns_topic, "name")}"
    }
  )
  aws_sns_topic_subscription_cloudtrail = merge(var.security_cloudtrail.aws_sns_topic_subscription, {
    endpoint = module.aws_recipes_lambda_create_cloudtrail.arn
    }
  )
  aws_cloudwatch_log_group_cloudtrail = merge(var.security_cloudtrail.aws_cloudwatch_log_group, {
    name = "${var.name_prefix}${lookup(var.security_cloudtrail.aws_cloudwatch_log_group, "name")}"
    }
  )
  aws_iam_role_cloudtrail = merge(var.security_cloudtrail.aws_iam_role, {
    name = "${var.name_prefix}${lookup(var.security_cloudtrail.aws_iam_role, "name")}"
    }
  )
  aws_iam_policy_cloudtrail = merge(var.security_cloudtrail.aws_iam_policy, {
    name = "${var.name_prefix}${lookup(var.security_cloudtrail.aws_iam_policy, "name")}"
    }
  )
  #   aws_s3_bucket_cloudtrail = merge(var.security_cloudtrail.aws_s3_bucket, {
  #     bucket = "${var.name_prefix}${var.security_cloudtrail.aws_s3_bucket.bucket}-${random_id.this.dec}"
  #     logging = [
  #       {
  #         target_bucket = module.aws_recipes_s3_bucket_log_cloudtrail.id
  #         target_prefix = "CloudTrail/"
  #       }
  #     ]
  #     }
  #   )
  aws_cloudtrail_cloudtrail = merge(var.security_cloudtrail.aws_cloudtrail, {
    name = "${var.name_prefix}${lookup(var.security_cloudtrail.aws_cloudtrail, "name")}"
    }
  )
}

#--------------------------------------------------------------
# Provides a CloudTrail.
#--------------------------------------------------------------
module "aws_recipes_security_cloudtrail" {
  source                     = "../../modules/aws/recipes/security/cloudtrail"
  is_enabled                 = lookup(var.security_cloudtrail, "is_enabled", true)
  is_s3_enabled              = lookup(var.security_cloudtrail, "is_s3_enabled", false)
  aws_kms_key                = local.aws_kms_key_cloudtrail
  aws_sns_topic              = local.aws_sns_topic_cloudtrail
  aws_sns_topic_subscription = local.aws_sns_topic_subscription_cloudtrail
  aws_cloudwatch_log_group   = local.aws_cloudwatch_log_group_cloudtrail
  aws_iam_role               = local.aws_iam_role_cloudtrail
  aws_iam_policy             = local.aws_iam_policy_cloudtrail
  #   aws_s3_bucket              = local.aws_s3_bucket_cloudtrail
  aws_s3_bucket_existing = {
    # The S3 bucket id
    bucket_id = module.aws_recipes_s3_bucket_log_cloudtrail.id
    # The S3 bucket arn
    bucket_arn = module.aws_recipes_s3_bucket_log_cloudtrail.arn
  }
  aws_cloudtrail  = local.aws_cloudtrail_cloudtrail
  cis_name_prefix = var.name_prefix
  account_id      = data.aws_caller_identity.current.account_id
  region          = var.region
  user            = var.deploy_user
  tags            = var.tags
  depends_on = [
    module.aws_recipes_s3_bucket_log_cloudtrail,
    module.aws_recipes_s3_policy_cloudtrail_cloudtrail
  ]
}

#--------------------------------------------------------------
# Provides a CloudWatch Log Metric Filter And Alerm resource.
#--------------------------------------------------------------
module "aws_recipes_cloudwatch_alarm_cloudtrail" {
  count                            = lookup(var.security_cloudtrail, "is_enabled", true) ? 1 : 0
  source                           = "../../modules/aws/recipes/cloudwatch/alarm/log"
  aws_cloudwatch_log_metric_filter = local.aws_cloudwatch_log_metric_filter_cloudtrail
  aws_cloudwatch_metric_alarm      = local.aws_cloudwatch_metric_alarm_cloudtrail
  tags                             = var.tags
}
#--------------------------------------------------------------
# Create Lambda function
#--------------------------------------------------------------
module "aws_recipes_lambda_create_cloudtrail" {
  source                   = "../../modules/aws/recipes/lambda/create"
  is_enabled               = lookup(var.security_cloudtrail, "is_enabled", true)
  aws_cloudwatch_log_group = lookup(var.security_cloudtrail, "aws_cloudwatch_log_group_lambda")

  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "../../lambda/outputs/cloudwatch_alarm_to_sns_to_slack.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}cloudwatch-alarm-cloudtrail"
    dead_letter_config             = []
    handler                        = "cloudwatch_alarm_to_sns_to_slack"
    role                           = module.aws_recipes_iam_lambda.arn
    description                    = "This program sends the result of CloudTrail to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "go1.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    vpc_config                     = []
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("../../lambda/outputs/cloudwatch_alarm_to_sns_to_slack.zip")
    environment                    = lookup(var.security_cloudtrail.aws_lambda_function, "environment")
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Event Rule, SNS or S3).
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    principal           = "sns.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = module.aws_recipes_security_cloudtrail.sns_topic_arn
    statement_id        = "CloudTrailDetectUnexpectedUsage"
    statement_id_prefix = null
  }
  tags = var.tags
}
