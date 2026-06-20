#--------------------------------------------------------------
# Module: aws/cloudwatch/delivery
# Purpose: Create CloudWatch Logs subscription filters and Kinesis Firehose delivery streams for log delivery to S3.
# Notes: Supports multiple log groups with automatic name transformation and Lambda processing integration.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
  # Default exclude patterns to prevent log loops
  default_exclude_patterns = [
    "kinesis-data-firehose-cloudwatch-logs-processor"
  ]

  # Merge user-defined exclude list with default patterns
  merged_exclude_list = concat(local.default_exclude_patterns, var.auto_log_group_names_exclude_list)
}

#--------------------------------------------------------------
# Auto-discovery metric filter module
#--------------------------------------------------------------
module "filter" {
  source = "../../_internal/auto_discovery_filter"

  is_enabled  = var.is_enabled
  create_auto = var.create_auto_log_group_names

  source_list       = data.aws_cloudwatch_log_groups.this.log_group_names
  include_list      = var.auto_log_group_names_include_list
  exclude_list      = local.merged_exclude_list
  manual_dimensions = var.log_group_names
}

#--------------------------------------------------------------
# Locals - Continued
#--------------------------------------------------------------
locals {
  # Use filtered results from helper module
  auto_log_group_names = module.filter.filtered_list
  safe_log_group_names = module.filter.safe_manual_dimensions

  # Manual log group names with default exclusions applied
  manual_log_group_names = [
    for v in local.safe_log_group_names : v
    if v != null && v != "" && !anytrue([for el in local.default_exclude_patterns : strcontains(v, el)])
  ]

  # Final log group names list
  final_log_group_names = var.create_auto_log_group_names ? local.auto_log_group_names : local.manual_log_group_names

  aws_cloudwatch_log_subscription_filter = flatten([
    for k, r in local.final_log_group_names : {
      name            = "${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}"
      destination_arn = try(module.aws_kinesis_firehose_s3[0].aws_kinesis_firehose_delivery_stream_arn[substr("${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}", 0, 63)], null)
      filter_pattern  = var.filter_pattern
      log_group_name  = r
      distribution    = var.distribution
    }
  ])

  aws_kinesis_firehose_delivery_stream = flatten([
    for r in local.final_log_group_names : {
      # Name length must be in the range (1 - 64)
      name = substr("${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}", 0, 63)
      server_side_encryption = [
        {
          enabled  = try(var.aws_kinesis_firehose_delivery_stream.server_side_encryption.enabled, false)
          key_type = try(var.aws_kinesis_firehose_delivery_stream.server_side_encryption.key_type, null)
          key_arn  = try(var.aws_kinesis_firehose_delivery_stream.server_side_encryption.key_arn, null)
        }
      ]
      extended_s3_configuration = [
        {
          bucket_arn         = var.s3_bucket_arn
          buffering_size     = try(var.aws_kinesis_firehose_delivery_stream.extended_s3_configuration.buffering_size, 5)
          buffering_interval = try(var.aws_kinesis_firehose_delivery_stream.extended_s3_configuration.buffering_interval, 60)
          prefix             = format("%s/%s/", trimsuffix(try(var.aws_kinesis_firehose_delivery_stream.extended_s3_configuration.prefix, "Log/"), "/"), "${var.name_prefix}${replace(replace(r, "/", "-"), "/^-/", "")}")
          compression_format = try(var.aws_kinesis_firehose_delivery_stream.extended_s3_configuration.compression_format, "GZIP")
          cloudwatch_logging_options = try(var.aws_kinesis_firehose_delivery_stream.extended_s3_configuration.cloudwatch_logging_options, [
            {
              enabled = false
            }
          ])
          processing_configuration = var.lambda_processor_arn != null ? [
            {
              enabled = true
              processors = [
                {
                  type = "Lambda"
                  parameters = [
                    {
                      parameter_name  = "LambdaArn"
                      parameter_value = "${var.lambda_processor_arn}:$LATEST"
                    },
                    {
                      parameter_name  = "BufferSizeInMBs"
                      parameter_value = try(var.aws_kinesis_firehose_delivery_stream.lambda_buffer_size_mb, "2")
                    },
                    {
                      parameter_name  = "BufferIntervalInSeconds"
                      parameter_value = try(var.aws_kinesis_firehose_delivery_stream.lambda_buffer_interval_seconds, 900)
                    },
                  ]
                }
              ]
            }
          ] : []
        }
      ]
    }
  ])
}

#--------------------------------------------------------------
# Provides a CloudWatch Logs subscription filter resource.
#--------------------------------------------------------------
module "aws_cloudwatch_subscription" {
  count = var.is_enabled ? 1 : 0

  source = "../subscription"

  region                                 = local.region
  aws_cloudwatch_log_subscription_filter = local.aws_cloudwatch_log_subscription_filter
  aws_iam_role = merge(var.aws_iam_role_cloudwatch_logs, {
    name = "${var.name_prefix}${var.aws_iam_role_cloudwatch_logs.name}"
  })
  aws_iam_policy = merge(var.aws_iam_policy_cloudwatch_logs, {
    name = "${var.name_prefix}${var.aws_iam_policy_cloudwatch_logs.name}"
  })
  account_id = var.account_id

  tags = var.tags
}

#--------------------------------------------------------------
# Provides a Kinesis Firehose Delivery Stream resource.
#--------------------------------------------------------------
module "aws_kinesis_firehose_s3" {
  count = var.is_enabled ? 1 : 0

  source = "../../kinesis/firehose/s3"

  region = local.region

  account_id                           = var.account_id
  aws_kinesis_firehose_delivery_stream = local.aws_kinesis_firehose_delivery_stream
  aws_iam_role = merge(var.aws_iam_role_kinesis_firehose, {
    name = "${var.name_prefix}${var.aws_iam_role_kinesis_firehose.name}"
  })
  aws_iam_policy = merge(var.aws_iam_policy_kinesis_firehose, {
    name = "${var.name_prefix}${var.aws_iam_policy_kinesis_firehose.name}"
  })

  tags = var.tags
}
