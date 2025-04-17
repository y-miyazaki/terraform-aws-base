output "aws_iam_role_arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = length(var.aws_kinesis_firehose_delivery_stream) > 0 ? aws_iam_role.this[0].arn : null
}
output "aws_kinesis_firehose_delivery_stream_arn" {
  description = "arn of the role."
  value = length(var.aws_kinesis_firehose_delivery_stream) > 0 ? tomap({
    for k, v in aws_kinesis_firehose_delivery_stream.this : v.name => v.arn
  }) : null
}
