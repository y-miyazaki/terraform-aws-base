#--------------------------------------------------------------
# For Application Log
#--------------------------------------------------------------
locals {
  aws_cloudwatch_log_subscription_filter_log_application = flatten([
    for k, r in var.delivery_log.log_group_names : {
      name            = "${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}"
      destination_arn = lookup(module.aws_recipes_kinesis_firehose_s3_log_application[0].aws_kinesis_firehose_delivery_stream_arn, "${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}", null)
      filter_pattern  = ""
      log_group_name  = r
      distribution    = "Random"
    }
  ])
  aws_kinesis_firehose_delivery_stream_log_application = flatten([
    for r in var.delivery_log.log_group_names : {
      name                   = "${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}"
      server_side_encryption = []
      extended_s3_configuration = [
        {
          bucket_arn         = module.aws_recipes_s3_bucket_log_application.arn
          buffer_size        = lookup(var.delivery_log.aws_kinesis_firehose_delivery_stream, "buffer_size", 5)
          buffer_interval    = lookup(var.delivery_log.aws_kinesis_firehose_delivery_stream, "buffer_interval", 60)
          prefix             = lookup(var.delivery_log.aws_kinesis_firehose_delivery_stream, "prefix", "/Application")
          compression_format = lookup(var.delivery_log.aws_kinesis_firehose_delivery_stream, "compression_format", "GZIP")
          cloudwatch_logging_options = lookup(var.delivery_log.aws_kinesis_firehose_delivery_stream, "cloudwatch_logging_options", [
            {
              enabled = false
            }
          ])
        }
      ]
    }
  ])
  aws_iam_role_kinesis_firehose_log_application = merge(var.delivery_log.aws_iam_role_kinesis_firehose, {
    name = "${var.name_prefix}${lookup(var.delivery_log.aws_iam_role_kinesis_firehose, "name")}"
    }
  )
  aws_iam_policy_kinesis_firehose_log_application = merge(var.delivery_log.aws_iam_policy_kinesis_firehose, {
    name = "${var.name_prefix}${lookup(var.delivery_log.aws_iam_policy_kinesis_firehose, "name")}"
    }
  )
  aws_iam_role_cloudwatch_logs = merge(var.delivery_log.aws_iam_role_cloudwatch_logs, {
    name = "${var.name_prefix}${lookup(var.delivery_log.aws_iam_role_cloudwatch_logs, "name")}"
    }
  )
  aws_iam_policy_cloudwatch_logs = merge(var.delivery_log.aws_iam_policy_cloudwatch_logs, {
    name = "${var.name_prefix}${lookup(var.delivery_log.aws_iam_policy_cloudwatch_logs, "name")}"
    }
  )
}
#--------------------------------------------------------------
# Provides a CloudWatch Logs subscription filter resource.
#--------------------------------------------------------------
module "aws_recipes_cloudwatch_subscription_log_application" {
  count                                  = lookup(var.delivery_log, "is_enabled", true) ? 1 : 0
  source                                 = "../../modules/aws/recipes/cloudwatch/subscription"
  aws_cloudwatch_log_subscription_filter = local.aws_cloudwatch_log_subscription_filter_log_application
  aws_iam_role                           = local.aws_iam_role_cloudwatch_logs
  aws_iam_policy                         = local.aws_iam_policy_cloudwatch_logs
  account_id                             = data.aws_caller_identity.current.account_id
  region                                 = var.region
  tags                                   = var.tags
}

#--------------------------------------------------------------
# Provides a Kinesis Firehose Delivery Stream resource. Amazon Kinesis Firehose is a fully managed, elastic service to easily deliver real-time data streams to destinations such as Amazon S3 and Amazon Redshift.
#--------------------------------------------------------------
module "aws_recipes_kinesis_firehose_s3_log_application" {
  count                                = lookup(var.delivery_log, "is_enabled", true) ? 1 : 0
  source                               = "../../modules/aws/recipes/kinesis/firehose/s3"
  aws_kinesis_firehose_delivery_stream = local.aws_kinesis_firehose_delivery_stream_log_application
  aws_iam_role                         = local.aws_iam_role_kinesis_firehose_log_application
  aws_iam_policy                       = local.aws_iam_policy_kinesis_firehose_log_application
  tags                                 = var.tags
}
