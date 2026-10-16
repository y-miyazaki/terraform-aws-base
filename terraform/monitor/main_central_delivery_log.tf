#--------------------------------------------------------------
# For Application Log - Using CloudWatch Delivery Module
#--------------------------------------------------------------
module "log_delivery_application" {
  source = "../../modules/aws/cloudwatch/delivery"

  is_enabled = var.delivery_log.is_enabled
  region     = var.region.primary

  account_id                        = data.aws_caller_identity.current.account_id
  auto_log_group_names_exclude_list = var.delivery_log.auto_log_group_names_exclude_list
  auto_log_group_names_include_list = var.delivery_log.auto_log_group_names_include_list
  aws_iam_policy_cloudwatch_logs    = var.delivery_log.aws_iam_policy_cloudwatch_logs
  aws_iam_policy_kinesis_firehose   = var.delivery_log.aws_iam_policy_kinesis_firehose
  aws_iam_role_cloudwatch_logs      = var.delivery_log.aws_iam_role_cloudwatch_logs
  aws_iam_role_kinesis_firehose     = var.delivery_log.aws_iam_role_kinesis_firehose
  aws_kinesis_firehose_delivery_stream = merge(var.delivery_log.aws_kinesis_firehose_delivery_stream, {
    server_side_encryption = {
      enabled  = var.kms["monitor"].is_enabled
      key_arn  = var.kms["monitor"].is_enabled ? module.kms_key["primary"].key_arn : null
      key_type = var.kms["monitor"].is_enabled ? "CUSTOMER_MANAGED_CMK" : null
    }
  })
  create_auto_log_group_names = var.delivery_log.create_auto_log_group_names
  distribution                = "Random"
  filter_pattern              = ""
  lambda_processor_arn        = module.aws_lambda_create_lambda_kinesis_data_firehose_cloudwatch_logs_processor.lambda_function_arn
  log_group_names             = var.delivery_log.log_group_names
  name_prefix                 = var.name_prefix
  s3_bucket_arn               = module.s3_application_log.s3_bucket_arn

  tags = var.tags
}
