output "arn" {
  description = "The Amazon Resource Name (ARN) identifying your Lambda Function."
  value       = var.is_enabled ? aws_lambda_function.this[0].arn : null
}
