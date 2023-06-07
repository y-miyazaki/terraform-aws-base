#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  aws_kinesis_firehose_delivery_stream = {
    for k, v in var.aws_kinesis_firehose_delivery_stream : v.name => v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides a Kinesis Firehose Delivery Stream resource. Amazon Kinesis Firehose is a fully managed, elastic service to easily deliver real-time data streams to destinations such as Amazon S3 and Amazon Redshift.
#--------------------------------------------------------------
resource "aws_kinesis_firehose_delivery_stream" "this" {
  for_each = local.aws_kinesis_firehose_delivery_stream
  name     = lookup(each.value, "name")
  tags     = local.tags
  dynamic "server_side_encryption" {
    for_each = lookup(each.value, "server_side_encryption", [])
    content {
      enabled  = lookup(server_side_encryption.value, "enabled", false)
      key_type = lookup(server_side_encryption.value, "key_type", null)
      key_arn  = lookup(server_side_encryption.value, "key_arn", null)
    }
  }
  destination = "extended_s3"
  dynamic "extended_s3_configuration" {
    for_each = lookup(each.value, "extended_s3_configuration", [])
    content {
      # base
      role_arn           = aws_iam_role.this[0].arn
      bucket_arn         = lookup(extended_s3_configuration.value, "bucket_arn", null)
      prefix             = lookup(extended_s3_configuration.value, "prefix", null)
      buffer_size        = lookup(extended_s3_configuration.value, "buffer_size", null)
      buffer_interval    = lookup(extended_s3_configuration.value, "buffer_interval", null)
      compression_format = lookup(extended_s3_configuration.value, "compression_format", null)
      kms_key_arn        = lookup(extended_s3_configuration.value, "kms_key_arn", null)
      dynamic "cloudwatch_logging_options" {
        for_each = lookup(extended_s3_configuration.value, "cloudwatch_logging_options", [])
        content {
          enabled         = lookup(cloudwatch_logging_options.value, "enabled", null)
          log_group_name  = lookup(cloudwatch_logging_options.value, "log_group_name", null)
          log_stream_name = lookup(cloudwatch_logging_options.value, "log_stream_name", null)
        }
      }
      # extended
      #   data_format_conversion_configuration = lookup(extended_s3_configuration.value, "data_format_conversion_configuration", null)
      error_output_prefix = lookup(extended_s3_configuration.value, "error_output_prefix", null)
      s3_backup_mode      = lookup(extended_s3_configuration.value, "s3_backup_mode", null)
      dynamic "processing_configuration" {
        for_each = lookup(extended_s3_configuration.value, "processing_configuration", [])
        content {
          enabled = lookup(processing_configuration.value, "enabled", null)
          dynamic "processors" {
            for_each = lookup(processing_configuration.value, "processors", [])
            content {
              type = lookup(processors.value, "type", null)
              dynamic "parameters" {
                for_each = lookup(processors.value, "parameters", [])
                content {
                  parameter_name  = lookup(parameters.value, "parameter_name", null)
                  parameter_value = lookup(parameters.value, "parameter_value", null)
                }
              }
            }
          }
        }
      }
      dynamic "s3_backup_configuration" {
        for_each = lookup(extended_s3_configuration.value, "s3_backup_configuration", [])
        content {
          # base
          role_arn           = aws_iam_role.this.arn
          bucket_arn         = lookup(extended_s3_configuration.value, "bucket_arn", null)
          prefix             = lookup(extended_s3_configuration.value, "prefix", null)
          buffer_size        = lookup(extended_s3_configuration.value, "buffer_size", null)
          buffer_interval    = lookup(extended_s3_configuration.value, "buffer_interval", null)
          compression_format = lookup(extended_s3_configuration.value, "compression_format", null)
          kms_key_arn        = lookup(extended_s3_configuration.value, "kms_key_arn", null)
          dynamic "cloudwatch_logging_options" {
            for_each = lookup(extended_s3_configuration.value, "cloudwatch_logging_options", [])
            content {
              enabled         = lookup(cloudwatch_logging_options.value, "enabled", null)
              log_group_name  = lookup(cloudwatch_logging_options.value, "log_group_name", null)
              log_stream_name = lookup(cloudwatch_logging_options.value, "log_stream_name", null)
            }
          }
        }
      }
    }
  }
}
#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  count              = length(var.aws_kinesis_firehose_delivery_stream) > 0 ? 1 : 0
  description        = lookup(var.aws_iam_role, "description", null)
  name               = lookup(var.aws_iam_role, "name")
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
  path               = lookup(var.aws_iam_role, "path", "/")
  tags               = local.tags
}
#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
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
      lookup(var.aws_kinesis_firehose_delivery_stream[0].extended_s3_configuration[0], "bucket_arn"),
      "${lookup(var.aws_kinesis_firehose_delivery_stream[0].extended_s3_configuration[0], "bucket_arn")}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]
    #tfsec:ignore:AWS099
    resources = [
      "*"
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
      "*"
    ]
  }
}
#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
#tfsec:ignore:AWS099
resource "aws_iam_policy" "this" {
  count       = length(var.aws_kinesis_firehose_delivery_stream) > 0 ? 1 : 0
  description = lookup(var.aws_iam_policy, "description", null)
  name        = lookup(var.aws_iam_policy, "name")
  path        = lookup(var.aws_iam_policy, "path", "/")
  policy      = data.aws_iam_policy_document.this[0].json
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  count      = length(var.aws_kinesis_firehose_delivery_stream) > 0 ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}
