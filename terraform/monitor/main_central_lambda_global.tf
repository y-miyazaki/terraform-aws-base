#--------------------------------------------------------------
# Create Lambda function
# For Kinesis Data Firehose Cloudwatch Logs Processor
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
module "aws_lambda_create_lambda_kinesis_data_firehose_cloudwatch_logs_processor_us_east_1" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.13.2"

  create = local.is_enabled_global
  region = "us-east-1"

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
  cloudwatch_logs_kms_key_id              = module.kms_key[local.is_enabled_global ? "global" : "primary"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.common_lambda_kinesis_data_firehose_cloudwatch_logs_processor.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = true
  create_role                             = false
  description                             = "An Amazon Kinesis Firehose stream processor that extracts individual log events from records sent by Cloudwatch Logs subscription filters."
  # The processor does not read any environment variable.
  environment_variables = {}
  function_name         = "${var.name_prefix}kinesis-data-firehose-cloudwatch-logs-processor"
  handler               = "index.handler"
  # Same source_path as the primary-region function: use a different hash to avoid concurrent writes to one zip.
  hash_extra                    = "us_east_1"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  # Each invocation gunzips, JSON-parses and base64-encodes a whole Firehose transformation buffer (up to ~6MB) at once,
  # so memory usage scales with the Firehose transfer (buffer) size. 256MB was at its limit and caused Runtime.OutOfMemory/timeouts; with a 256KB buffer the observed peak is ~366MB, hence 512MB.
  # If the Firehose transfer (buffer) size is increased, review this memory size as well.
  memory_size            = 512
  publish                = false
  runtime                = "nodejs24.x"
  source_path            = local.nodejs_lambda_source_path["kinesis_data_firehose_cloudwatch_logs_processor"]
  timeout                = 300
  tracing_mode           = "PassThrough"
  vpc_security_group_ids = local.lambda_vpc_security_group_ids[local.lambda_vpc_global_key]
  vpc_subnet_ids         = local.lambda_vpc_subnet_ids[local.lambda_vpc_global_key]

  tags = var.tags

  # Both functions build from the same source_path (npm install into the same node_modules).
  # Run the builds sequentially: concurrent builds fail with npm ENOTEMPTY and corrupt the zip (source_code_hash mismatch).
  depends_on = [module.aws_lambda_create_lambda_kinesis_data_firehose_cloudwatch_logs_processor]
}

#--------------------------------------------------------------
# Create Lambda function
# For CloudFront Logs moves object key.
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
# NOTE: Skip creation if default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
module "aws_lambda_create_lambda_s3_notification_s3_object_created_for_athena_us_east_1" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.13.2"

  create = local.is_enabled_global
  region = "us-east-1"

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
  cloudwatch_logs_kms_key_id              = module.kms_key[local.is_enabled_global ? "global" : "primary"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.common_lambda_s3_notification_s3_object_created_for_athena.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = true
  create_role                             = false
  description                             = "This program moves s3 object(CloudFront) for Athena."
  environment_variables = {
    TARGET_KEY_PREFIX = "Logs/CloudFront/"
  }
  function_name = "${var.name_prefix}s3-notification-s3-object-created-for-athena"
  handler       = "index.handler"
  # Same source_path as the primary-region function: use a different hash to avoid concurrent writes to one zip.
  hash_extra                    = "us_east_1"
  lambda_role                   = module.aws_iam_role_lambda.arn
  layers                        = []
  logging_application_log_level = "INFO"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 128
  publish                       = false
  runtime                       = "nodejs24.x"
  source_path                   = local.nodejs_lambda_source_path["s3_notification_s3_object_created_for_athena"]
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = local.lambda_vpc_security_group_ids[local.lambda_vpc_global_key]
  vpc_subnet_ids                = local.lambda_vpc_subnet_ids[local.lambda_vpc_global_key]

  tags = var.tags
}
