#--------------------------------------------------------------
# For Application Log(us-east-1)
# CloudFront, SES etc...
#--------------------------------------------------------------
locals {
  aws_cloudwatch_log_subscription_filter_log_application_us_east_1 = flatten([
    for k, r in var.delivery_log_us_east_1.log_group_names : {
      name            = "${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}"
      destination_arn = lookup(module.aws_recipes_kinesis_firehose_s3_log_application_us_east_1[0].aws_kinesis_firehose_delivery_stream_arn, "${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}", null)
      filter_pattern  = ""
      log_group_name  = r
      distribution    = "Random"
    }
  ])
  aws_kinesis_firehose_delivery_stream_log_application_us_east_1 = flatten([
    for r in var.delivery_log_us_east_1.log_group_names : {
      name                   = "${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}"
      server_side_encryption = []
      extended_s3_configuration = [
        {
          bucket_arn         = module.s3_application_log.s3_bucket_arn
          buffer_size        = lookup(var.delivery_log_us_east_1.aws_kinesis_firehose_delivery_stream, "buffer_size", 5)
          buffer_interval    = lookup(var.delivery_log_us_east_1.aws_kinesis_firehose_delivery_stream, "buffer_interval", 60)
          prefix             = format("%s/%s/", trimsuffix(lookup(var.delivery_log_us_east_1.aws_kinesis_firehose_delivery_stream, "prefix", "Log/"), "/"), "${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}")
          compression_format = lookup(var.delivery_log_us_east_1.aws_kinesis_firehose_delivery_stream, "compression_format", "GZIP")
          cloudwatch_logging_options = lookup(var.delivery_log_us_east_1.aws_kinesis_firehose_delivery_stream, "cloudwatch_logging_options", [
            {
              enabled = false
            }
          ])
          processing_configuration = [
            {
              enabled = "true"
              processors = [
                {
                  type = "Lambda"
                  parameters = [
                    {
                      parameter_name  = "LambdaArn"
                      parameter_value = "${module.aws_recipes_lambda_create_lambda_kinesis_data_firehose_cloudwatch_logs_processor_us_east_1.arn}:$LATEST"
                    },
                    {
                      parameter_name  = "BufferSizeInMBs"
                      parameter_value = "2"
                    },
                    {
                      parameter_name  = "BufferIntervalInSeconds"
                      parameter_value = 900
                    },
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ])
}
#--------------------------------------------------------------
# Provides a CloudWatch Logs subscription filter resource.
#--------------------------------------------------------------
module "aws_recipes_cloudwatch_subscription_log_application_us_east_1" {
  count  = lookup(var.delivery_log_us_east_1, "is_enabled", true) ? 1 : 0
  source = "../../modules/aws/recipes/cloudwatch/subscription"
  providers = {
    aws = aws.us-east-1
  }
  aws_cloudwatch_log_subscription_filter = local.aws_cloudwatch_log_subscription_filter_log_application_us_east_1
  aws_iam_role = merge(var.delivery_log_us_east_1.aws_iam_role_cloudwatch_logs, {
    name = "${var.name_prefix}${lookup(var.delivery_log_us_east_1.aws_iam_role_cloudwatch_logs, "name")}"
    }
  )
  aws_iam_policy = merge(var.delivery_log_us_east_1.aws_iam_policy_cloudwatch_logs, {
    name = "${var.name_prefix}${lookup(var.delivery_log_us_east_1.aws_iam_policy_cloudwatch_logs, "name")}"
    }
  )
  account_id = data.aws_caller_identity.current.account_id
  region     = "us-east-1"
  tags       = var.tags
}

#--------------------------------------------------------------
# Provides a Kinesis Firehose Delivery Stream resource. Amazon Kinesis Firehose is a fully managed, elastic service to easily deliver real-time data streams to destinations such as Amazon S3 and Amazon Redshift.
# for us-east-1
#--------------------------------------------------------------
module "aws_recipes_kinesis_firehose_s3_log_application_us_east_1" {
  count  = lookup(var.delivery_log_us_east_1, "is_enabled", true) ? 1 : 0
  source = "../../modules/aws/recipes/kinesis/firehose/s3"
  providers = {
    aws = aws.us-east-1
  }
  aws_kinesis_firehose_delivery_stream = local.aws_kinesis_firehose_delivery_stream_log_application_us_east_1
  aws_iam_role = merge(var.delivery_log_us_east_1.aws_iam_role_kinesis_firehose, {
    name = "${var.name_prefix}${lookup(var.delivery_log_us_east_1.aws_iam_role_kinesis_firehose, "name")}"
    }
  )
  aws_iam_policy = merge(var.delivery_log_us_east_1.aws_iam_policy_kinesis_firehose, {
    name = "${var.name_prefix}${lookup(var.delivery_log_us_east_1.aws_iam_policy_kinesis_firehose, "name")}"
    }
  )
  tags = var.tags
}
