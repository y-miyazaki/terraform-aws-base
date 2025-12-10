#--------------------------------------------------------------
# Module outputs
#--------------------------------------------------------------
output "kinesis_firehose_delivery_stream_arns" {
  description = "ARNs of the Kinesis Firehose delivery streams."
  value       = var.is_enabled ? module.aws_kinesis_firehose_s3[0].aws_kinesis_firehose_delivery_stream_arn : {}
}

output "iam_role_kinesis_firehose_arn" {
  description = "ARN of the IAM role for Kinesis Firehose."
  value       = var.is_enabled ? module.aws_kinesis_firehose_s3[0].aws_iam_role_arn : null
}
