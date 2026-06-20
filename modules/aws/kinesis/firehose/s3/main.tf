#--------------------------------------------------------------
# Module: aws/kinesis/firehose/s3
# Purpose: Create Kinesis Firehose delivery streams targeting S3 with optional encryption, processing, and backup configuration.
# Notes: Assumes uniform first stream values for IAM policy scoping; future improvement: per-stream policy generation.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
  aws_kinesis_firehose_delivery_stream = {
    for k, v in var.aws_kinesis_firehose_delivery_stream : v.name => v
  }
}

#--------------------------------------------------------------
# Provides a Kinesis Firehose Delivery Stream resource. Amazon Kinesis Firehose is a fully managed, elastic service to easily deliver real-time data streams to destinations such as Amazon S3 and Amazon Redshift.
#--------------------------------------------------------------
resource "aws_kinesis_firehose_delivery_stream" "this" {
  for_each = local.aws_kinesis_firehose_delivery_stream

  region = local.region
  name   = each.value.name
  dynamic "server_side_encryption" {
    for_each = try(each.value.server_side_encryption, [])

    content {
      enabled  = try(server_side_encryption.value.enabled, false)
      key_type = try(server_side_encryption.value.key_type, null)
      key_arn  = try(server_side_encryption.value.key_arn, null)
    }
  }
  destination = "extended_s3"
  dynamic "extended_s3_configuration" {
    for_each = try(each.value.extended_s3_configuration, [])

    content {
      # base
      role_arn           = aws_iam_role.this[0].arn
      bucket_arn         = try(extended_s3_configuration.value.bucket_arn, null)
      prefix             = try(extended_s3_configuration.value.prefix, null)
      buffering_size     = try(extended_s3_configuration.value.buffering_size, null)
      buffering_interval = try(extended_s3_configuration.value.buffering_interval, null)
      compression_format = try(extended_s3_configuration.value.compression_format, null)
      kms_key_arn        = try(extended_s3_configuration.value.kms_key_arn, null)
      dynamic "cloudwatch_logging_options" {
        for_each = try(extended_s3_configuration.value.cloudwatch_logging_options, [])

        content {
          enabled         = try(cloudwatch_logging_options.value.enabled, null)
          log_group_name  = try(cloudwatch_logging_options.value.log_group_name, null)
          log_stream_name = try(cloudwatch_logging_options.value.log_stream_name, null)
        }
      }
      # extended
      #   data_format_conversion_configuration = try(extended_s3_configuration.value.data_format_conversion_configuration, null)
      error_output_prefix = try(extended_s3_configuration.value.error_output_prefix, null)
      s3_backup_mode      = try(extended_s3_configuration.value.s3_backup_mode, null)
      dynamic "processing_configuration" {
        for_each = try(extended_s3_configuration.value.processing_configuration, [])

        content {
          enabled = try(processing_configuration.value.enabled, null)
          dynamic "processors" {
            for_each = try(processing_configuration.value.processors, [])

            content {
              type = try(processors.value.type, null)
              dynamic "parameters" {
                for_each = try(processors.value.parameters, [])

                content {
                  parameter_name  = try(parameters.value.parameter_name, null)
                  parameter_value = try(parameters.value.parameter_value, null)
                }
              }
            }
          }
        }
      }
      dynamic "s3_backup_configuration" {
        for_each = try(extended_s3_configuration.value.s3_backup_configuration, [])

        content {
          # base
          role_arn           = aws_iam_role.this[0].arn
          bucket_arn         = try(extended_s3_configuration.value.bucket_arn, null)
          prefix             = try(extended_s3_configuration.value.prefix, null)
          buffering_size     = try(extended_s3_configuration.value.buffering_size, null)
          buffering_interval = try(extended_s3_configuration.value.buffering_interval, null)
          compression_format = try(extended_s3_configuration.value.compression_format, null)
          kms_key_arn        = try(extended_s3_configuration.value.kms_key_arn, null)
          dynamic "cloudwatch_logging_options" {
            for_each = try(extended_s3_configuration.value.cloudwatch_logging_options, [])

            content {
              enabled         = try(cloudwatch_logging_options.value.enabled, null)
              log_group_name  = try(cloudwatch_logging_options.value.log_group_name, null)
              log_stream_name = try(cloudwatch_logging_options.value.log_stream_name, null)
            }
          }
        }
      }
    }
  }

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  count = length(var.aws_kinesis_firehose_delivery_stream) > 0 ? 1 : 0

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  description           = try(var.aws_iam_role.description, null)
  force_detach_policies = true
  name                  = var.aws_iam_role.name
  path                  = try(var.aws_iam_role.path, "/")

  tags = var.tags
}

#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
# https://docs.aws.amazon.com/firehose/latest/dev/controlling-access.html#using-iam-s3
#--------------------------------------------------------------
data "aws_iam_policy_document" "this" {
  count = length(var.aws_kinesis_firehose_delivery_stream) > 0 ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      var.aws_kinesis_firehose_delivery_stream[0].extended_s3_configuration[0].bucket_arn,
      "${var.aws_kinesis_firehose_delivery_stream[0].extended_s3_configuration[0].bucket_arn}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards",
    ]
    resources = [
      "arn:aws:kinesis:${local.region}:${var.account_id}:stream/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]
    #tfsec:ignore:AWS099
    resources = [
      "arn:aws:kms:${local.region}:${var.account_id}:key/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "s3.${local.region}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"
      values = [
        var.aws_kinesis_firehose_delivery_stream[0].extended_s3_configuration[0].bucket_arn,
        "${var.aws_kinesis_firehose_delivery_stream[0].extended_s3_configuration[0].bucket_arn}/*"
      ]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]
    #tfsec:ignore:AWS099
    resources = [
      "arn:aws:logs:${local.region}:${var.account_id}:log-group/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]
    #tfsec:ignore:AWS099
    resources = [
      "arn:aws:lambda:${local.region}:${var.account_id}:function:*",
    ]
  }
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
#tfsec:ignore:AWS099
resource "aws_iam_policy" "this" {
  count = length(var.aws_kinesis_firehose_delivery_stream) > 0 ? 1 : 0

  description = try(var.aws_iam_policy.description, null)
  name        = var.aws_iam_policy.name
  path        = try(var.aws_iam_policy.path, "/")
  policy      = data.aws_iam_policy_document.this[0].json

  tags = var.tags
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  count = length(var.aws_kinesis_firehose_delivery_stream) > 0 ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}
