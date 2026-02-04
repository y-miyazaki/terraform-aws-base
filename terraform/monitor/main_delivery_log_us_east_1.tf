#--------------------------------------------------------------
# For Application Log - Using CloudWatch Delivery Module
# NOTE: Disabled when default region is us-east-1 to avoid duplication
#--------------------------------------------------------------
module "log_delivery_application_us_east_1" {
  source     = "../../modules/aws/cloudwatch/delivery"
  is_enabled = !local.is_default_region_us_east_1 && var.delivery_log_us_east_1.is_enabled
  providers = {
    aws = aws.us-east-1
  }

  name_prefix                       = var.name_prefix
  create_auto_log_group_names       = var.delivery_log_us_east_1.create_auto_log_group_names
  auto_log_group_names_include_list = var.delivery_log_us_east_1.auto_log_group_names_include_list
  auto_log_group_names_exclude_list = var.delivery_log_us_east_1.auto_log_group_names_exclude_list
  log_group_names                   = var.delivery_log_us_east_1.log_group_names
  filter_pattern                    = ""
  distribution                      = "Random"

  s3_bucket_arn        = module.s3_application_log.s3_bucket_arn
  lambda_processor_arn = !local.is_default_region_us_east_1 ? module.aws_lambda_create_lambda_kinesis_data_firehose_cloudwatch_logs_processor_us_east_1.lambda_function_arn : null

  aws_kinesis_firehose_delivery_stream = merge(var.delivery_log_us_east_1.aws_kinesis_firehose_delivery_stream, {
    server_side_encryption = {
      enabled  = true
      key_type = "CUSTOMER_MANAGED_CMK"
      key_arn  = module.kms_key_us_east_1["monitor"].key_arn
    }
  })

  aws_iam_role_cloudwatch_logs   = var.delivery_log_us_east_1.aws_iam_role_cloudwatch_logs
  aws_iam_policy_cloudwatch_logs = var.delivery_log_us_east_1.aws_iam_policy_cloudwatch_logs

  aws_iam_role_kinesis_firehose   = var.delivery_log_us_east_1.aws_iam_role_kinesis_firehose
  aws_iam_policy_kinesis_firehose = var.delivery_log_us_east_1.aws_iam_policy_kinesis_firehose

  account_id = data.aws_caller_identity.current.account_id
  region     = "us-east-1"

  tags = var.tags
}
