#--------------------------------------------------------------
# For Application Log - Using CloudWatch Delivery Module
#--------------------------------------------------------------
module "log_delivery_application" {
  source = "../../modules/aws/cloudwatch/delivery"

  is_enabled = var.delivery_log.is_enabled

  name_prefix                       = var.name_prefix
  create_auto_log_group_names       = var.delivery_log.create_auto_log_group_names
  auto_log_group_names_include_list = var.delivery_log.auto_log_group_names_include_list
  auto_log_group_names_exclude_list = var.delivery_log.auto_log_group_names_exclude_list
  log_group_names                   = var.delivery_log.log_group_names
  filter_pattern                    = ""
  distribution                      = "Random"

  s3_bucket_arn        = module.s3_application_log.s3_bucket_arn
  lambda_processor_arn = module.aws_lambda_create_lambda_kinesis_data_firehose_cloudwatch_logs_processor.lambda_function_arn

  aws_kinesis_firehose_delivery_stream = merge(var.delivery_log.aws_kinesis_firehose_delivery_stream, {
    server_side_encryption = {
      enabled  = true
      key_type = "CUSTOMER_MANAGED_CMK"
      key_arn  = module.kms_key["primary"].key_arn
    }
  })

  aws_iam_role_cloudwatch_logs   = var.delivery_log.aws_iam_role_cloudwatch_logs
  aws_iam_policy_cloudwatch_logs = var.delivery_log.aws_iam_policy_cloudwatch_logs

  aws_iam_role_kinesis_firehose   = var.delivery_log.aws_iam_role_kinesis_firehose
  aws_iam_policy_kinesis_firehose = var.delivery_log.aws_iam_policy_kinesis_firehose

  account_id = data.aws_caller_identity.current.account_id
  region     = var.region.primary

  tags = var.tags
}
