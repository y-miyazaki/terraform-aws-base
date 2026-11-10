#--------------------------------------------------------------
# Create Lambda function
# For Kinesis Data Firehose Cloudwatch Logs Processor
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
module "aws_lambda_create_lambda_kinesis_data_firehose_cloudwatch_logs_processor" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.13.0"

  region = var.region.primary

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
  cloudwatch_logs_kms_key_id              = module.kms_key["primary"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.common_lambda_kinesis_data_firehose_cloudwatch_logs_processor.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "An Amazon Kinesis Firehose stream processor that extracts individual log events from records sent by Cloudwatch Logs subscription filters."
  # The processor does not read any environment variable.
  environment_variables = {}
  function_name         = "${var.name_prefix}kinesis-data-firehose-cloudwatch-logs-processor"
  handler               = "index.handler"
  lambda_role           = module.aws_iam_role_lambda.arn
  layers                = []
  # cd /workspace/nodejs/kinesis_data_firehose_cloudwatch_logs_processor && npm install && zip -r /workspace/lambda/outputs/nodejs_kinesis_data_firehose_cloudwatch_logs_processor.zip .
  local_existing_package        = "../../lambda/outputs/nodejs_kinesis_data_firehose_cloudwatch_logs_processor.zip"
  logging_application_log_level = "WARN"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 256
  publish                       = false
  runtime                       = "nodejs24.x"
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc["primary"].default_security_group_id] : [var.common_lambda.vpc.exists[var.region.primary].security_group_id] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc["primary"].private_subnets : var.common_lambda.vpc.exists[var.region.primary].private_subnets : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc
  ]
}

#--------------------------------------------------------------
# Create Lambda function
# For CloudFront Logs moves object key.
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
module "aws_lambda_create_lambda_s3_notification_s3_object_created_for_athena" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.13.0"

  region = var.region.primary

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
  cloudwatch_logs_kms_key_id              = module.kms_key["primary"].key_arn
  cloudwatch_logs_retention_in_days       = coalesce(try(var.cloudwatch_log_group.override.common_lambda_s3_notification_s3_object_created_for_athena.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program moves s3 object(CloudFront) for Athena."
  environment_variables = {
    TARGET_KEY_PREFIX = "Logs/CloudFront/"
  }
  function_name = "${var.name_prefix}s3-notification-s3-object-created-for-athena"
  handler       = "index.handler"
  lambda_role   = module.aws_iam_role_lambda.arn
  layers        = []
  # cd /workspace/nodejs/s3_notification_s3_object_created_for_athena && npm install && zip -r /workspace/lambda/outputs/nodejs_s3_notification_s3_object_created_for_athena.zip .
  local_existing_package        = "../../lambda/outputs/nodejs_s3_notification_s3_object_created_for_athena.zip"
  logging_application_log_level = "INFO"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = 128
  publish                       = false
  runtime                       = "nodejs24.x"
  timeout                       = 300
  tracing_mode                  = "PassThrough"
  vpc_security_group_ids        = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc["primary"].default_security_group_id] : [var.common_lambda.vpc.exists[var.region.primary].security_group_id] : []
  vpc_subnet_ids                = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc["primary"].private_subnets : var.common_lambda.vpc.exists[var.region.primary].private_subnets : []

  tags = var.tags

  depends_on = [
    module.lambda_vpc
  ]
}
